package com.chronis.coaching;

import com.chronis.common.security.AccessScope;
import com.fasterxml.jackson.databind.node.ObjectNode;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.util.*;

@RestController
@RequestMapping("/api/v1/coaching")
@PreAuthorize("isAuthenticated()")
public class CoachingSettingsController {
    private final AccessScope access; private final CoachSettingsService settings; private final CoachingStore store; private final CoachingProvider provider;
    public CoachingSettingsController(AccessScope access, CoachSettingsService settings, CoachingStore store, CoachingProvider provider) { this.access=access; this.settings=settings; this.store=store; this.provider=provider; }
    private long user(){return access.currentUser().getId();}
    @GetMapping("/settings") public ObjectNode settings(){return settings.config(user());}
    @PutMapping("/settings") public ObjectNode settings(@RequestBody ObjectNode body){return settings.save(user(),body);}
    @DeleteMapping("/settings/keys/{provider}") public ObjectNode removeKey(@PathVariable String provider){return settings.remove(user(),provider);}
    @PostMapping("/settings/test") public Map<String,Object> test(){long user=user();var config=settings.config(user);String p=config.path("provider").asText(),m=config.path("model").asText();CoachSettingsService.requireFreeProvider(p);provider.turn(p,m,settings.key(user,p),store.mapper().createObjectNode().put("purpose","Connection test. Ask one short generic AI engineering interview question; placeholder evaluation only."),"ORAL");return Map.of("connected",true,"provider",p,"model",m);}
}
