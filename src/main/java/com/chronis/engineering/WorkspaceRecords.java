package com.chronis.engineering;

import com.chronis.common.security.AccessScope;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

/** Mutable account records: optimistic concurrency prevents silent cross-device loss. */
@RestController
@RequestMapping("/api/v1/workspace-records")
@PreAuthorize("isAuthenticated()")
public class WorkspaceRecords {
    public record SaveRequest(@Min(0) long expectedVersion, @NotNull ObjectNode data) {}
    public record Record(String key, long version, ObjectNode data, String updatedAt) {}
    private static final Map<String, String> KEYS = Map.of(
            "focus", "(?:[1-9]|[1-8][0-9]|9[0-2])",
            "rhythm", "(?:[1-9]|[1-8][0-9]|9[0-2])",
            "study-draft", "(?:[1-9]|[1-8][0-9]|9[0-2]):(?:CONCEPT|BASIC_CODING|SCENARIO|PROJECT|INTERVIEW|REVIEW)",
            "project-draft", "P(?:0[1-9]|[1-4][0-9]|50):(?:DESIGN|IMPLEMENTATION|SCENARIOS|TESTING|DELIVERY|REVIEW)",
            "preferences", "(?:main|appearance)",
            "reminder-activity", "main");
    private final JdbcTemplate jdbc;
    private final ObjectMapper json;
    private final AccessScope access;
    public WorkspaceRecords(JdbcTemplate jdbc, ObjectMapper json, AccessScope access) {
        this.jdbc = jdbc; this.json = json; this.access = access;
    }
    private long user() { return access.currentUser().getId(); }
    private void type(String type) {
        if (!KEYS.containsKey(type)) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unknown workspace record type");
    }
    private void key(String type, String key) {
        type(type);
        if (!key.matches(KEYS.get(type))) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid workspace record key");
    }
    private ObjectNode parse(String value) {
        try { return (ObjectNode) json.readTree(value); }
        catch (Exception ex) { throw new IllegalStateException("Invalid workspace record", ex); }
    }
    private void validate(String type, String key, ObjectNode data) {
        boolean valid = switch (type) {
            case "focus" -> data.path("completed").isIntegralNumber() && data.path("completed").asLong() >= 0
                    && data.path("session").isIntegralNumber() && data.path("session").asLong() >= 0
                    && data.path("completed").asLong() <= 86400 && data.path("session").asLong() <= 86400
                    && data.path("block").isTextual() && data.path("block").asText().length() <= 100;
            case "rhythm" -> strings(data.path("checked"), 100, 120);
            case "study-draft" -> data.path("data").isObject() && data.path("expectedVersion").isIntegralNumber()
                    && data.path("expectedVersion").asLong() >= 0 && data.path("mutationId").isTextual()
                    && data.path("mutationId").asText().length() <= 100;
            case "project-draft" -> data.path("data").isObject() && data.path("version").isIntegralNumber()
                    && data.path("version").asLong() >= 0;
            case "preferences" -> key.equals("appearance")
                    ? data.path("mode").isTextual() && List.of("light", "dark", "system").contains(data.path("mode").asText())
                    : data.path("hideEvidence").isBoolean() && data.path("speakQuestions").isBoolean()
                    && data.path("reminders").isArray() && data.path("reminders").size() == 5
                    && allBooleans(data.path("reminders"));
            case "reminder-activity" -> data.path("events").isArray() && data.path("events").size() <= 200
                    && allEvents(data.path("events"));
            default -> false;
        };
        if (!valid) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid workspace record content");
    }
    private boolean strings(JsonNode values, int maxItems, int maxLength) {
        if (!values.isArray() || values.size() > maxItems) return false;
        for (JsonNode value : values) if (!value.isTextual() || value.asText().length() > maxLength) return false;
        return true;
    }
    private boolean allBooleans(JsonNode values) {
        for (JsonNode value : values) if (!value.isBoolean()) return false;
        return true;
    }
    private boolean allEvents(JsonNode values) {
        for (JsonNode value : values) if (!value.isObject() || !value.path("id").isTextual() || value.path("id").asText().length() > 120) return false;
        return true;
    }
    @GetMapping("/{type}")
    public List<Record> list(@PathVariable String type, @RequestParam(value="key",required=false) String key) {
        type(type);
        if (key != null) {
            key(type,key);
            return jdbc.query("select record_key,version,payload::text,updated_at from engineering_workspace_records where user_id=? and record_type=? and record_key=?",
                    (r,n)->new Record(r.getString(1),r.getLong(2),parse(r.getString(3)),r.getTimestamp(4).toInstant().toString()), user(),type,key);
        }
        return jdbc.query("select record_key,version,payload::text,updated_at from engineering_workspace_records where user_id=? and record_type=? order by record_key",
                (r,n)->new Record(r.getString(1),r.getLong(2),parse(r.getString(3)),r.getTimestamp(4).toInstant().toString()), user(),type);
    }
    public List<Record> list(String type) { return list(type,null); }
    @GetMapping("/{type}/{key}")
    public Record get(@PathVariable String type, @PathVariable String key) {
        key(type,key);
        return jdbc.query("select record_key,version,payload::text,updated_at from engineering_workspace_records where user_id=? and record_type=? and record_key=?",
                (r,n)->new Record(r.getString(1),r.getLong(2),parse(r.getString(3)),r.getTimestamp(4).toInstant().toString()), user(),type,key)
                .stream().findFirst().orElseThrow(()->new ResponseStatusException(HttpStatus.NOT_FOUND,"Workspace record not found"));
    }
    @PutMapping("/{type}/{key}")
    @Transactional
    public Record put(@PathVariable String type, @PathVariable String key, @Valid @RequestBody SaveRequest request) {
        key(type,key);
        String payload=request.data().toString();
        if(payload.getBytes(StandardCharsets.UTF_8).length>128_000)
            throw new ResponseStatusException(HttpStatus.PAYLOAD_TOO_LARGE,"Workspace record exceeds 128 KB");
        validate(type,key,request.data());
        long user=user();
        int changed = request.expectedVersion()==0
                ? jdbc.update("insert into engineering_workspace_records(user_id,record_type,record_key,version,payload,updated_at) values(?,?,?,1,cast(? as jsonb),now()) on conflict do nothing",user,type,key,payload)
                : jdbc.update("update engineering_workspace_records set version=version+1,payload=cast(? as jsonb),updated_at=now() where user_id=? and record_type=? and record_key=? and version=?",payload,user,type,key,request.expectedVersion());
        if(changed!=1) throw new ResponseStatusException(HttpStatus.CONFLICT,"This record changed on another device. Your local copy has been retained.");
        return get(type,key);
    }
    @DeleteMapping("/{type}/{key}")
    @Transactional
    public void delete(@PathVariable String type, @PathVariable String key, @RequestParam @Min(1) long expectedVersion) {
        key(type,key);
        int changed=jdbc.update("delete from engineering_workspace_records where user_id=? and record_type=? and record_key=? and version=?",user(),type,key,expectedVersion);
        if(changed!=1) throw new ResponseStatusException(HttpStatus.CONFLICT,"This record changed on another device. Your local copy has been retained.");
    }
}
