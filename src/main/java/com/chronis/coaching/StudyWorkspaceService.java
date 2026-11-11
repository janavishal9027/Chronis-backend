package com.chronis.coaching;

import com.chronis.engineering.EngineeringPolicy;
import com.fasterxml.jackson.databind.*;
import com.fasterxml.jackson.databind.node.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import java.time.*;
import java.util.*;

@Service
@Transactional(readOnly=true)
public class StudyWorkspaceService {
    public static final List<String> SECTIONS=List.of("DESIGN","IMPLEMENTATION","SCENARIOS","TESTING","DELIVERY","REVIEW");
    public static final int[][] FOCUS={{550,620},{635,695},{740,800},{815,935},{950,990},{990,1000}};
    private static final String[] DOMAINS={"CONCEPT","BASIC_CODING","SCENARIO","PROJECT","INTERVIEW","REVIEW"};
    private final CoachingStore store;
    public StudyWorkspaceService(CoachingStore store){this.store=store;}
    public LocalDate today(){return store.clock().instant().atZone(EngineeringPolicy.ZONE).toLocalDate();}
    public static String project(String id){if(id==null||!id.matches("P(?:0[1-9]|[1-4][0-9]|50)"))throw new IllegalArgumentException("Choose a roadmap project P01–P50");return id;}
    public static String section(String id){if(!SECTIONS.contains(id))throw new IllegalArgumentException("Unknown project work section");return id;}
    public List<CoachingStore.Record> project(long user,String id){String prefix=project(id)+":";return store.list(user,"PROJECT_SECTION").stream().filter(r->r.key().startsWith(prefix)).toList();}
    public List<Map<String,Object>> projectSummaries(long user){return store.list(user,"PROJECT_SECTION").stream().map(r->Map.<String,Object>of("key",r.key(),"version",r.version(),"status",r.data().path("status").asText(),"actualMinutes",r.data().path("actualMinutes").asInt(),"updatedAt",r.updatedAt())).toList();}
    @Transactional public CoachingStore.Record saveProject(long user,String id,String part,long expected,ObjectNode input){
        ObjectNode data=store.mapper().createObjectNode();
        String status=input.path("status").asText("NOT_STARTED");if(!Set.of("NOT_STARTED","IN_PROGRESS","PARTIAL","BLOCKED","DONE").contains(status))throw new IllegalArgumentException("Choose a valid project section status");
        data.put("status",status);int minutes=input.path("actualMinutes").asInt();if((input.has("actualMinutes")&&!input.path("actualMinutes").isIntegralNumber())||minutes<0||minutes>100000)throw new IllegalArgumentException("Actual project minutes must be a nonnegative whole number");data.put("actualMinutes",minutes);
        for(String key:List.of("notes","code","evidence","testOutput","complexity","edgeCases","gitReference","blockers","nextSteps")){
            String value=input.path(key).asText("");int max=key.equals("code")?20000:key.equals("notes")||key.equals("testOutput")?12000:4000;if(value.length()>max)throw new IllegalArgumentException(key+" is too long");data.put(key,value);
        }
        return store.put(user,"PROJECT_SECTION",project(id)+":"+section(part),expected,data);
    }
    public List<CoachingStore.Record> carries(long user){return store.list(user,"CARRYOVER");}
    public List<CoachingStore.Record> leaves(long user){return store.list(user,"LEAVE");}
    @Transactional public CoachingStore.Record saveCarry(long user,String id,long expected,ObjectNode input){
        if(!id.matches("[A-Za-z0-9_-]{1,100}"))throw new IllegalArgumentException("Invalid carryover ID");
        int day=input.path("sourceDay").asInt();LocalDate source=EngineeringPolicy.dateForDay(day),target=parseDate(input.path("targetDate").asText());
        if(!target.isAfter(source))throw new IllegalArgumentException("Carryover must move to a later date");
        int minutes=input.path("estimatedMinutes").asInt();if(!input.path("estimatedMinutes").isIntegralNumber()||minutes<1||minutes>1440)throw new IllegalArgumentException("Estimated time must be 1–1440 whole minutes");
        String title=input.path("title").asText().trim();if(title.isEmpty()||title.length()>500)throw new IllegalArgumentException("Enter a carryover task title");
        String cause=input.path("cause").asText("TASK_DELAY");if(!Set.of("TASK_DELAY","LATE_LOGIN","EARLY_LOGOUT","LATE_LOGOUT","LEAVE","PRACTICE").contains(cause))throw new IllegalArgumentException("Choose a carryover reason");
        String status=input.path("status").asText("OPEN");if(!Set.of("OPEN","DONE","CANCELLED").contains(status))throw new IllegalArgumentException("Invalid carryover status");
        ObjectNode clean=store.mapper().createObjectNode().put("sourceDay",day).put("targetDate",target.toString()).put("estimatedMinutes",minutes).put("title",title).put("cause",cause).put("status",status);
        for(String key:List.of("domain","notes","projectId")){String value=input.path(key).asText("");if(value.length()>2000)throw new IllegalArgumentException(key+" is too long");clean.put(key,value);}
        // A manual carryover record cannot forge a linked interview completion.
        var existing=store.get(user,"CARRYOVER",id);existing.ifPresent(r->{if(r.data().has("practiceSessionId"))clean.set("practiceSessionId",r.data().get("practiceSessionId"));});
        if(existing.isPresent()&&existing.get().data().has("practiceSessionId")&&status.equals("DONE")){
            var practice=store.get(user,"PRACTICE",existing.get().data().path("practiceSessionId").asText());
            if(practice.isEmpty()||!practice.get().data().path("status").asText().equals("COMPLETED"))throw new ResponseStatusException(HttpStatus.CONFLICT,"Complete the linked interview session before resolving its carryover.");
        }
        return store.put(user,"CARRYOVER",id,expected,clean);
    }
    public static LocalDate parseDate(String date){try{return LocalDate.parse(date);}catch(Exception ex){throw new IllegalArgumentException("Choose a valid date");}}
    @Transactional public CoachingStore.Record saveLeave(long user,String id,long expected,ObjectNode input){
        if(!id.matches("[A-Za-z0-9_-]{1,100}"))throw new IllegalArgumentException("Invalid leave ID");
        int day=input.path("dayNumber").asInt();EngineeringPolicy.dateForDay(day);
        String reason=input.path("reason").asText().trim();if(reason.length()<10||reason.length()>1000)throw new IllegalArgumentException("Explain the study leave in at least 10 characters");
        LocalTime from,to;try{from=LocalTime.parse(input.path("from").asText("09:00"));to=LocalTime.parse(input.path("to").asText("17:00"));}catch(Exception ex){throw new IllegalArgumentException("Choose valid leave times");}
        if(from.isBefore(LocalTime.of(9,0))||to.isAfter(LocalTime.of(17,0))||!from.isBefore(to))throw new IllegalArgumentException("Study leave must be within 09:00–17:00");
        String status=input.path("status").asText("PLANNED");if(!Set.of("PLANNED","CANCELLED").contains(status))throw new IllegalArgumentException("Invalid leave status");
        return store.put(user,"LEAVE",id,expected,store.mapper().createObjectNode().put("dayNumber",day).put("from",from.toString()).put("to",to.toString()).put("reason",reason).put("status",status));
    }
    public static int minute(LocalTime time){return time.getHour()*60+time.getMinute();}
    public static int focusCapacity(int from,int to,List<int[]> unavailable){
        int total=0;
        for(int m=Math.max(0,from);m<Math.min(1440,to);m++){
            boolean study=false;for(int[] interval:FOCUS)if(m>=interval[0]&&m<interval[1])study=true;
            if(study){boolean blocked=false;for(int[] interval:unavailable)if(m>=interval[0]&&m<interval[1])blocked=true;if(!blocked)total++;}
        }
        return total;
    }
    public ObjectNode plan(long user,int day){
        LocalDate date=EngineeringPolicy.dateForDay(day);var now=store.clock().instant().atZone(EngineeringPolicy.ZONE);
        var attendance=store.sql().query("select check_in_time,check_out_time from attendance_sessions where user_id=? and work_date=? order by id desc limit 1",(r,n)->{var utc=Calendar.getInstance(TimeZone.getTimeZone("UTC"));var in=r.getTimestamp(1,utc);var out=r.getTimestamp(2,utc);return new Instant[]{in==null?null:in.toInstant(),out==null?null:out.toInstant()};},user,date);
        Instant checkIn=attendance.isEmpty()?null:attendance.getFirst()[0],checkOut=attendance.isEmpty()?null:attendance.getFirst()[1];
        List<int[]> blocked=new ArrayList<>();
        for(var leave:leaves(user))if(leave.data().path("dayNumber").asInt()==day&&leave.data().path("status").asText().equals("PLANNED"))blocked.add(new int[]{minute(LocalTime.parse(leave.data().path("from").asText())),minute(LocalTime.parse(leave.data().path("to").asText()))});
        int leaveMinutes=360-focusCapacity(540,1020,blocked);
        if(checkIn!=null&&checkIn.atZone(EngineeringPolicy.ZONE).toLocalDate().equals(date))blocked.add(new int[]{540,minute(checkIn.atZone(EngineeringPolicy.ZONE).toLocalTime())});
        if(checkOut!=null&&checkOut.atZone(EngineeringPolicy.ZONE).toLocalDate().equals(date))blocked.add(new int[]{minute(checkOut.atZone(EngineeringPolicy.ZONE).toLocalTime()),1020});
        int capacity=focusCapacity(540,1020,blocked),from=now.toLocalDate().isBefore(date)?540:now.toLocalDate().isAfter(date)?1020:minute(now.toLocalTime());
        int remaining=focusCapacity(from,1020,blocked),carryIn=0,carryOut=0;
        Set<String> moved=new HashSet<>();
        for(var row:carries(user)){var d=row.data();if(!d.path("status").asText().equals("OPEN"))continue;if(d.path("targetDate").asText().equals(date.toString())&&!d.path("cause").asText().equals("PRACTICE"))carryIn+=d.path("estimatedMinutes").asInt();if(d.path("sourceDay").asInt()==day&&parseDate(d.path("targetDate").asText()).isAfter(date)){carryOut+=d.path("estimatedMinutes").asInt();moved.add(d.path("domain").asText());}}
        Map<String,JsonNode> work=new HashMap<>();store.sql().query("select domain,payload::text from engineering_work where user_id=? and plan_id=? and day_number=?",(org.springframework.jdbc.core.RowCallbackHandler)r->{work.put(r.getString(1),store.parse(r.getString(2)));},user,EngineeringPolicy.PLAN,day);
        int outstanding=0;for(int i=0;i<DOMAINS.length;i++){if(moved.contains(DOMAINS[i]))continue;JsonNode d=work.get(DOMAINS[i]);if(d!=null&&d.path("status").asText().equals("DONE"))continue;outstanding+=Math.max(0,FOCUS[i][1]-FOCUS[i][0]-(d==null?0:d.path("actualMinutes").asInt()));}
        Instant nine=date.atTime(9,0).atZone(EngineeringPolicy.ZONE).toInstant(),seventeen=date.atTime(17,0).atZone(EngineeringPolicy.ZONE).toInstant();
        return store.mapper().createObjectNode().put("dayNumber",day).put("date",date.toString()).put("serverTime",store.clock().instant().toString()).put("estimatedLogoutAt",seventeen.toString()).put("logoutTime","17:00").put("logoutPolicy","FIXED_17").put("plannedFocusMinutes",360).put("availableFocusMinutes",capacity).put("remainingFocusMinutes",remaining).put("lateLoginMinutes",checkIn==null?0:Math.max(0,Duration.between(nine,checkIn).toMinutes())).put("earlyLogoutMinutes",checkOut==null?0:Math.max(0,Duration.between(checkOut,seventeen).toMinutes())).put("lateLogoutMinutes",checkOut==null?0:Math.max(0,Duration.between(seventeen,checkOut).toMinutes())).put("leaveFocusMinutes",leaveMinutes).put("dueCarryoverMinutes",carryIn).put("carriedForwardMinutes",carryOut).put("estimatedUnfinishedMinutes",Math.max(0,outstanding+carryIn-remaining)).put("nextDate",date.plusDays(1).toString());
    }
    @Transactional public List<CoachingStore.Record> carryUnfinished(long user,int day,String targetText,String cause){
        LocalDate source=EngineeringPolicy.dateForDay(day),target=parseDate(targetText);if(!target.isAfter(source))throw new IllegalArgumentException("Choose a later target date");
        Map<String,ObjectNode> work=new HashMap<>();store.sql().query("select domain,payload::text from engineering_work where user_id=? and plan_id=? and day_number=?",(org.springframework.jdbc.core.RowCallbackHandler)r->work.put(r.getString(1),store.parse(r.getString(2))),user,EngineeringPolicy.PLAN,day);
        for(int i=0;i<DOMAINS.length;i++){
            String domain=DOMAINS[i];var d=work.get(domain);if(d!=null&&d.path("status").asText().equals("DONE"))continue;
            String key="day-"+day+"-"+domain;var existing=store.get(user,"CARRYOVER",key);if(existing.isPresent()&&existing.get().data().path("status").asText().equals("DONE"))continue;
            int estimate=Math.max(1,FOCUS[i][1]-FOCUS[i][0]-(d==null?0:d.path("actualMinutes").asInt()));
            ObjectNode data=store.mapper().createObjectNode().put("sourceDay",day).put("targetDate",target.toString()).put("estimatedMinutes",estimate).put("title","Finish "+domain.toLowerCase().replace('_',' ')+" · Day "+day).put("cause",cause).put("status","OPEN").put("domain",domain).put("notes",d==null?"":d.path("nextSteps").asText());
            saveCarry(user,key,existing.map(CoachingStore.Record::version).orElse(0L),data);
        }
        return carries(user);
    }
}
