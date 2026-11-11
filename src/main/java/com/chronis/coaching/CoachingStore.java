package com.chronis.coaching;

import com.fasterxml.jackson.databind.*;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.web.server.ResponseStatusException;
import java.sql.Timestamp;
import java.time.Clock;
import java.util.*;

@Repository
public class CoachingStore {
    public record Record(String key,long version,ObjectNode data,String updatedAt) {}
    private final JdbcTemplate jdbc; private final ObjectMapper json; private final Clock clock;
    public CoachingStore(JdbcTemplate jdbc,ObjectMapper json,Clock clock){this.jdbc=jdbc;this.json=json;this.clock=clock;}
    public JdbcTemplate sql(){return jdbc;} public ObjectMapper mapper(){return json;} public Clock clock(){return clock;}
    public ObjectNode parse(String value){try{return (ObjectNode)json.readTree(value);}catch(Exception ex){throw new IllegalStateException("Invalid account record",ex);}}
    public Optional<Record> get(long user,String kind,String key){
        return jdbc.query("select record_key,version,payload::text,updated_at from engineering_client_records where user_id=? and record_type=? and record_key=?",(r,n)->new Record(r.getString(1),r.getLong(2),parse(r.getString(3)),r.getTimestamp(4).toInstant().toString()),user,kind,key).stream().findFirst();
    }
    public List<Record> list(long user,String kind){return jdbc.query("select record_key,version,payload::text,updated_at from engineering_client_records where user_id=? and record_type=? order by updated_at desc",(r,n)->new Record(r.getString(1),r.getLong(2),parse(r.getString(3)),r.getTimestamp(4).toInstant().toString()),user,kind);}
    public Optional<Record> locked(long user,String kind,String key){
        jdbc.queryForList("select record_key from engineering_client_records where user_id=? and record_type=? and record_key=? for update",user,kind,key);
        return get(user,kind,key);
    }
    public Record put(long user,String kind,String key,long expected,ObjectNode data){
        long current=get(user,kind,key).map(Record::version).orElse(0L);
        if(current!=expected)throw new ResponseStatusException(HttpStatus.CONFLICT,"This record changed on another device. Refresh and compare before saving.");
        var versions=jdbc.query("insert into engineering_client_records(user_id,record_type,record_key,version,payload,updated_at) values(?,?,?,1,cast(? as jsonb),?) on conflict(user_id,record_type,record_key) do update set version=engineering_client_records.version+1,payload=excluded.payload,updated_at=excluded.updated_at where engineering_client_records.version=? returning version",(r,n)->r.getLong(1),user,kind,key,data.toString(),Timestamp.from(clock.instant()),expected);
        if(versions.isEmpty())throw new ResponseStatusException(HttpStatus.CONFLICT,"This record changed on another device. Refresh before saving.");
        long version=versions.getFirst();
        jdbc.update("insert into engineering_client_revisions(user_id,record_type,record_key,version,payload,recorded_at) values(?,?,?,?,cast(? as jsonb),?)",user,kind,key,version,data.toString(),Timestamp.from(clock.instant()));
        return get(user,kind,key).orElseThrow();
    }
    public Record replace(long user,String kind,String key,ObjectNode data){return put(user,kind,key,get(user,kind,key).map(Record::version).orElse(0L),data);}
    public Record touchPractice(long user,Record row){
        ObjectNode next=row.data().deepCopy().put("lastSeenAt",clock.instant().toString());
        jdbc.update("update engineering_client_records set payload=cast(? as jsonb) where user_id=? and record_type='PRACTICE' and record_key=?",next.toString(),user,row.key());
        return new Record(row.key(),row.version(),next,row.updatedAt());
    }
    public List<Record> history(long user,String kind,String key){return jdbc.query("select record_key,version,payload::text,recorded_at from engineering_client_revisions where user_id=? and record_type=? and record_key=? order by version desc",(r,n)->new Record(r.getString(1),r.getLong(2),parse(r.getString(3)),r.getTimestamp(4).toInstant().toString()),user,kind,key);}
    public void removeSecret(long user,String provider){jdbc.update("delete from engineering_client_revisions where user_id=? and record_type='PROVIDER_KEY' and record_key=?",user,provider);jdbc.update("delete from engineering_client_records where user_id=? and record_type='PROVIDER_KEY' and record_key=?",user,provider);}
}
