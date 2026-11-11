package com.chronis.engineering;

import com.chronis.common.security.AccessScope;
import com.chronis.auth.repository.UserRepository;
import com.chronis.attendance.repository.AttendanceSessionRepository;
import com.fasterxml.jackson.databind.*;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;
import java.time.*;
import java.util.*;
import java.sql.Timestamp;
import static com.chronis.engineering.StudyWorkRequest.Domain;

@Service
@Transactional(readOnly=true)
public class StudyService {
    private final JdbcTemplate jdbc;
    private final ObjectMapper mapper;
    private final AccessScope access;
    private final UserRepository users;
    private final AttendanceSessionRepository attendance;
    private final EngineeringPolicy policy;
    public StudyService(JdbcTemplate jdbc,ObjectMapper mapper,AccessScope access,UserRepository users,AttendanceSessionRepository attendance,EngineeringPolicy policy) {
        this.jdbc=jdbc;this.mapper=mapper;this.access=access;this.users=users;this.attendance=attendance;this.policy=policy;
    }
    public JsonNode roadmap(){
        var rows = jdbc.query("select payload::text from engineering_curricula where plan_id=?",
                (rs,n)->rs.getString(1), EngineeringPolicy.PLAN);
        if(rows.isEmpty()) throw new IllegalStateException("Engineering roadmap is missing from the database");
        JsonNode curriculum=json(rows.getFirst());
        if(curriculum.path("days").size()!=92 || curriculum.path("projects").size()!=50 || curriculum.path("phases").size()!=8)
            throw new IllegalStateException("Invalid engineering curriculum in the database");
        return curriculum;
    }
    public Map<String,Object> overview() {
        Long user=access.currentUser().getId();
        Long submittedDays=jdbc.queryForObject(
            "select count(distinct day_number) from engineering_report_submissions where user_id=? and plan_id=?",
            Long.class,user,EngineeringPolicy.PLAN);
        var work=jdbc.query(
            "select day_number,domain,version,payload::text from engineering_work where user_id=? and plan_id=? order by day_number,domain",
            (rs,n)->Map.<String,Object>of("dayNumber",rs.getInt(1),"domain",rs.getString(2),"version",rs.getLong(3),"data",json(rs.getString(4))),
            user,EngineeringPolicy.PLAN);
        var reports=jdbc.query(
            "select distinct on (day_number) day_number,version,payload::text,submitted_at from engineering_report_submissions where user_id=? and plan_id=? order by day_number,version desc",
            (rs,n)->Map.<String,Object>of("dayNumber",rs.getInt(1),"version",rs.getInt(2),"data",json(rs.getString(3)),"submittedAt",rs.getTimestamp(4).toInstant()),
            user,EngineeringPolicy.PLAN);
        var reportHistory=jdbc.query(
            "select day_number,version,payload::text,submitted_at from engineering_report_submissions where user_id=? and plan_id=? order by day_number,version",
            (rs,n)->Map.<String,Object>of("dayNumber",rs.getInt(1),"version",rs.getInt(2),"data",json(rs.getString(3)),"submittedAt",rs.getTimestamp(4).toInstant()),
            user,EngineeringPolicy.PLAN);
        var attendanceDates=jdbc.query(
            "select distinct work_date from attendance_sessions where user_id=? and work_date between ? and ? and check_in_time is not null and deleted_at is null order by work_date",
            (rs,n)->rs.getDate(1).toLocalDate().toString(),user,EngineeringPolicy.START,EngineeringPolicy.END);
        return Map.of("submittedDays",submittedDays==null?0:submittedDays,"work",work,"reports",reports,"reportHistory",reportHistory,"attendanceDates",attendanceDates);
    }
    public Map<String,Object> progress(int day) {
        EngineeringPolicy.dateForDay(day);Long user=access.currentUser().getId();
        return Map.of("dayNumber",day,"serverTime",policy.now(),"work",workRows(user,day),"reports",reportRows(user,day));
    }
    private List<Map<String,Object>> workRows(Long user,int day){
        return jdbc.query("select id,domain,version,payload::text,updated_at from engineering_work where user_id=? and plan_id=? and day_number=? order by domain",
            (rs,n)->Map.<String,Object>of("id",rs.getLong(1),"domain",rs.getString(2),"version",rs.getLong(3),"data",json(rs.getString(4)),"updatedAt",rs.getTimestamp(5).toInstant()),user,EngineeringPolicy.PLAN,day);
    }
    private List<Map<String,Object>> reportRows(Long user,int day){
        return jdbc.query("select id,version,payload::text,submitted_at from engineering_report_submissions where user_id=? and plan_id=? and day_number=? order by version desc",
            (rs,n)->Map.<String,Object>of("id",rs.getLong(1),"version",rs.getInt(2),"data",json(rs.getString(3)),"submittedAt",rs.getTimestamp(4).toInstant()),user,EngineeringPolicy.PLAN,day);
    }
    private JsonNode json(String text){try{return mapper.readTree(text);}catch(Exception ex){throw new IllegalStateException("Invalid stored study data",ex);}}
    private Long lock(){Long id=access.currentUser().getId();users.findLockedById(id).orElseThrow();return id;}
    private void writableDay(Long user,int day,String correction){
        LocalDate date=EngineeringPolicy.dateForDay(day),today=policy.today();
        if(date.isAfter(today))throw new ResponseStatusException(HttpStatus.CONFLICT,"Future lessons may be read but not reported as work already performed");
        if(date.isBefore(today) && !EngineeringPolicy.emergency(correction))throw new ResponseStatusException(HttpStatus.CONFLICT,"A past-day correction requires a reason of at least 10 characters");
        if(date.equals(today) && attendance.findFirstByUserIdAndCheckOutTimeIsNullAndCheckInTimeIsNotNullOrderByCheckInTimeDesc(user).filter(s->s.getWorkDate().equals(date)).isEmpty())
            throw new ResponseStatusException(HttpStatus.CONFLICT,"Study login is required before saving today's work. Drafts can be kept on your device until you check in.");
    }
    @Transactional
    public Map<String,Object> save(int day,Domain domain,StudyWorkRequest request){
        Long user=lock();writableDay(user,day,request.correctionReason());
        boolean replay=Boolean.TRUE.equals(jdbc.queryForObject("select exists(select 1 from engineering_work_revisions where user_id=? and mutation_id=?)",Boolean.class,user,request.mutationId()));
        if(replay)return progress(day);
        var old=workRows(user,day).stream().filter(w->w.get("domain").equals(domain.name())).findFirst();
        long version=old.map(w->(Long)w.get("version")).orElse(0L);
        if(version!=request.expectedVersion())throw new ResponseStatusException(HttpStatus.CONFLICT,"This work was changed on another device. Refresh, compare the server record with your draft, then save again.");
        ObjectNode payload=mapper.valueToTree(request);payload.remove(List.of("expectedVersion","mutationId"));
        long next=version+1;Timestamp now=Timestamp.from(policy.now());long id;
        if(old.isEmpty())id=Objects.requireNonNull(jdbc.queryForObject("insert into engineering_work(user_id,plan_id,day_number,domain,version,payload,updated_at) values(?,?,?,?,?,cast(? as jsonb),?) returning id",Long.class,user,EngineeringPolicy.PLAN,day,domain.name(),next,payload.toString(),now));
        else{id=(Long)old.get().get("id");jdbc.update("update engineering_work set version=?,payload=cast(? as jsonb),updated_at=? where id=?",next,payload.toString(),now,id);}
        jdbc.update("insert into engineering_work_revisions(work_id,user_id,mutation_id,version,payload,recorded_at) values(?,?,?,?,cast(? as jsonb),?)",id,user,request.mutationId(),next,payload.toString(),now);
        policy.record(user,"STUDY_WORK_SAVED",EngineeringPolicy.dateForDay(day),domain.name()+" revision "+next);
        return progress(day);
    }
    public static List<String> validateReport(List<Map<String,Object>> work){
        List<String> issues=new ArrayList<>();
        for(Domain domain:List.of(Domain.CONCEPT,Domain.BASIC_CODING,Domain.SCENARIO,Domain.PROJECT,Domain.INTERVIEW)){
            var row=work.stream().filter(w->w.get("domain").equals(domain.name())).findFirst();
            if(row.isEmpty()){issues.add(domain+": save a work update or an explicit skip reason");continue;}
            JsonNode d=(JsonNode)row.get().get("data");String status=d.path("status").asText();
            if(status.equals("NOT_STARTED")){if(d.path("skipReason").asText().trim().length()<3)issues.add(domain+": give a skip reason");continue;}
            if(d.path("evidence").asText().isBlank() && d.path("skipReason").asText().trim().length()<3)issues.add(domain+": provide evidence or an explicit evidence skip reason");
            if((domain==Domain.CONCEPT||domain==Domain.INTERVIEW)&&d.path("confidence").asInt()<1)issues.add(domain+": choose confidence 1–5");
            if(domain==Domain.BASIC_CODING&&status.equals("DONE")&&d.path("testOutput").asText().isBlank())issues.add(domain+": paste test output");
            if(domain==Domain.SCENARIO&&(status.equals("DONE")||status.equals("PARTIAL"))&&(d.path("complexity").asText().isBlank()||d.path("edgeCases").asText().isBlank()))issues.add(domain+": include complexity and edge cases");
            if(domain==Domain.PROJECT&&(status.equals("DONE")||status.equals("PARTIAL"))&&d.path("gitReference").asText().isBlank())issues.add(domain+": include a Git commit or demo reference");
            if(status.equals("BLOCKED")&&d.path("blockers").asText().isBlank())issues.add(domain+": explain the blocker");
        }
        return issues;
    }
    @Transactional
    public Map<String,Object> submit(int day,String correction){
        Long user=lock();writableDay(user,day,correction);var work=workRows(user,day);var issues=validateReport(work);
        if(!issues.isEmpty())throw new IllegalArgumentException(String.join("; ",issues));
        var payload=mapper.valueToTree(work);var reports=reportRows(user,day);
        if(!reports.isEmpty()){
            Set<String> currentVersions=new HashSet<>(),submittedVersions=new HashSet<>();
            for(var row:work)currentVersions.add(row.get("domain")+":"+row.get("version"));
            for(JsonNode row:(JsonNode)reports.getFirst().get("data"))submittedVersions.add(row.path("domain").asText()+":"+row.path("version").asLong());
            if(currentVersions.equals(submittedVersions))return progress(day);
        }
        int version=reports.size()+1;
        jdbc.update("insert into engineering_report_submissions(user_id,plan_id,day_number,version,payload,submitted_at) values(?,?,?,?,cast(? as jsonb),?)",user,EngineeringPolicy.PLAN,day,version,payload.toString(),Timestamp.from(policy.now()));
        policy.record(user,"STUDY_REPORT_SUBMITTED",EngineeringPolicy.dateForDay(day),"Version "+version);
        return progress(day);
    }
    public List<Map<String,Object>> history(int day,Domain domain){
        EngineeringPolicy.dateForDay(day);Long user=access.currentUser().getId();
        return jdbc.query("select r.version,r.payload::text,r.recorded_at from engineering_work_revisions r join engineering_work w on w.id=r.work_id where w.user_id=? and w.plan_id=? and w.day_number=? and w.domain=? order by r.version desc",
            (rs,n)->Map.<String,Object>of("version",rs.getLong(1),"data",json(rs.getString(2)),"recordedAt",rs.getTimestamp(3).toInstant()),user,EngineeringPolicy.PLAN,day,domain.name());
    }
}
