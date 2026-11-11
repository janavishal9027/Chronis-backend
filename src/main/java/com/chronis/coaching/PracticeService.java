package com.chronis.coaching;

import com.chronis.engineering.*;
import com.fasterxml.jackson.databind.*;
import com.fasterxml.jackson.databind.node.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import java.time.*;
import java.util.*;

@Service
@Transactional
public class PracticeService {
    private final CoachingStore store; private final CoachSettingsService settings; private final CoachingProvider provider; private final StudyService study;
    public PracticeService(CoachingStore store,CoachSettingsService settings,CoachingProvider provider,StudyService study){this.store=store;this.settings=settings;this.provider=provider;this.study=study;}
    private Instant now(){return store.clock().instant();}
    private ZonedDateTime local(){return now().atZone(EngineeringPolicy.ZONE);}
    private static ResponseStatusException conflict(String message){return new ResponseStatusException(HttpStatus.CONFLICT,message);}
    private CoachingStore.Record required(long user,String id){return store.locked(user,"PRACTICE",id).orElseThrow(()->new ResponseStatusException(HttpStatus.NOT_FOUND,"Practice session not found"));}
    private Instant cutoff(ObjectNode session){return Instant.parse(session.path("activeSince").asText()).atZone(EngineeringPolicy.ZONE).toLocalDate().atTime(17,0).atZone(EngineeringPolicy.ZONE).toInstant();}
    public static long elapsed(ObjectNode session,Instant instant){
        long used=session.path("usedSeconds").asLong();
        if(session.path("status").asText().equals("ACTIVE")&&session.hasNonNull("activeSince")){
            Instant start=Instant.parse(session.path("activeSince").asText());Instant stop=start.atZone(EngineeringPolicy.ZONE).toLocalDate().atTime(17,0).atZone(EngineeringPolicy.ZONE).toInstant();
            Instant end=instant.isBefore(stop)?instant:stop;
            if(session.hasNonNull("lastSeenAt")){Instant presenceEnd=Instant.parse(session.path("lastSeenAt").asText()).plusSeconds(60);if(presenceEnd.isBefore(end))end=presenceEnd;}
            used+=Math.max(0,Duration.between(start,end).getSeconds());
        }
        return Math.min(1800,used);
    }
    public static int answered(ObjectNode session){int n=0;for(JsonNode question:session.path("questions"))if(question.has("answer"))n++;return n;}
    public static boolean canComplete(ObjectNode session,Instant instant){return elapsed(session,instant)>=900&&answered(session)>=3;}
    public static int confidence(ObjectNode session){
        double sum=0;int count=0;
        for(JsonNode question:session.path("questions"))if(question.has("answer")){
            JsonNode evaluation=question.path("answer").path("evaluation");sum+=(evaluation.path("correctness").asDouble()*40+evaluation.path("reasoning").asDouble()*30+evaluation.path("clarity").asDouble()*15+evaluation.path("coverage").asDouble()*15)/4;count++;
        }
        return count==0?0:(int)Math.round(sum/count);
    }
    public ObjectNode publicState(CoachingStore.Record record){
        ObjectNode data=record.data().deepCopy();data.remove("reportSnapshot");
        for(JsonNode question:data.path("questions"))if(question instanceof ObjectNode q)q.remove("referenceAnswer");
        long used=elapsed(record.data(),now());int count=answered(record.data());
        data.put("id",record.key()).put("version",record.version()).put("serverTime",now().toString()).put("elapsedSeconds",used).put("remainingSeconds",Math.max(0,data.path("durationMinutes").asInt(20)*60-used)).put("answeredQuestions",count).put("confidencePercent",confidence(record.data())).put("confidenceProvisional",!canComplete(record.data(),now()));
        data.put("providerConfigured",settings.config(record.data().path("userId").asLong()).path("savedKeys").path(data.path("provider").asText()).asBoolean());
        data.remove("userId");return data;
    }
    public List<ObjectNode> summaries(long user){return store.list(user,"PRACTICE").stream().limit(40).map(record->{var row=record.data().path("status").asText().equals("ACTIVE")?checkpoint(user,required(user,record.key())):record;var d=publicState(row);d.remove("questions");return d;}).toList();}
    private void practiceCarry(long user,String id,ObjectNode session){
        int minutes=(int)Math.ceil(Math.max(0,session.path("durationMinutes").asInt(20)*60-elapsed(session,now()))/60.0);
        if(minutes==0)minutes=1;
        var data=store.mapper().createObjectNode().put("sourceDay",session.path("dayNumber").asInt()).put("title","Interview practice · Day "+session.path("dayNumber").asInt()).put("targetDate",session.path("scheduledDate").asText()).put("estimatedMinutes",minutes).put("cause","PRACTICE").put("status","OPEN").put("domain","INTERVIEW").put("practiceSessionId",id).put("notes","Continue the saved one-on-one session; logout stays at 17:00.");
        store.replace(user,"CARRYOVER","practice-"+id,data);
    }
    private void resolvePracticeCarry(long user,String id){store.get(user,"CARRYOVER","practice-"+id).ifPresent(row->{var data=row.data().deepCopy();data.put("status","DONE");store.put(user,"CARRYOVER",row.key(),row.version(),data);});}
    private ObjectNode stopActive(ObjectNode original){var data=original.deepCopy();data.put("usedSeconds",elapsed(original,now()));data.remove("activeSince");return data;}
    private CoachingStore.Record checkpoint(long user,CoachingStore.Record row){
        ObjectNode data=row.data();if(!data.path("status").asText().equals("ACTIVE"))return row;
        boolean idle=data.hasNonNull("lastSeenAt")&&now().isAfter(Instant.parse(data.path("lastSeenAt").asText()).plusSeconds(60));
        if(!idle&&now().isBefore(cutoff(data))&&elapsed(data,now())<data.path("durationMinutes").asInt(20)*60&&elapsed(data,now())<1800)return row;
        var next=stopActive(data);
        if(idle&&now().isBefore(cutoff(data))){next.put("status","PAUSED");return store.put(user,"PRACTICE",row.key(),row.version(),next);}
        if(canComplete(data,now())){next.put("status","COMPLETED").put("completedAt",now().toString());resolvePracticeCarry(user,row.key());}
        else{LocalDate nextDate=Instant.parse(data.path("activeSince").asText()).atZone(EngineeringPolicy.ZONE).toLocalDate().plusDays(1);next.put("status","CARRIED").put("scheduledDate",nextDate.toString());practiceCarry(user,row.key(),next);}
        return store.put(user,"PRACTICE",row.key(),row.version(),next);
    }
    private boolean windowAvailable(){var time=local().toLocalTime();return !time.isBefore(LocalTime.of(9,0))&&time.isBefore(LocalTime.of(17,0));}
    private LocalDate nextDate(){return local().toLocalTime().isBefore(LocalTime.of(9,0))?local().toLocalDate():local().toLocalDate().plusDays(1);}
    public ObjectNode start(long user,int day){
        EngineeringPolicy.dateForDay(day);
        var reports=store.sql().query("select id,version,payload::text,submitted_at from engineering_report_submissions where user_id=? and plan_id=? and day_number=? order by version desc limit 1",(r,n)->store.mapper().createObjectNode().put("id",r.getLong(1)).put("version",r.getInt(2)).put("payload",r.getString(3)).put("submittedAt",r.getTimestamp(4).toInstant().toString()),user,EngineeringPolicy.PLAN,day);
        if(reports.isEmpty())throw conflict("Submit your saved daily report before starting the interview.");
        var report=reports.getFirst();String id="report-"+report.path("id").asLong();
        Boolean fresh=store.sql().queryForObject("select not exists(select 1 from engineering_work w where w.user_id=? and w.plan_id=? and w.day_number=? and not exists(select 1 from jsonb_array_elements(cast(? as jsonb)) e where e->>'domain'=w.domain and (e->>'version')::bigint=w.version))",Boolean.class,user,EngineeringPolicy.PLAN,day,report.path("payload").asText());
        if(!Boolean.TRUE.equals(fresh))throw conflict("Submit a report covering your latest saved work before starting its interview.");
        var existing=store.locked(user,"PRACTICE",id);if(existing.isPresent())return publicState(checkpoint(user,existing.get()));
        ObjectNode config=settings.config(user),data=store.mapper().createObjectNode().put("userId",user).put("dayNumber",day).put("reportVersion",report.path("version").asInt()).put("reportId",report.path("id").asLong()).put("reportSubmittedAt",report.path("submittedAt").asText()).put("durationMinutes",config.path("durationMinutes").asInt(20)).put("provider",config.path("provider").asText()).put("model",config.path("model").asText()).put("transcriptionModel",config.path("transcriptionModel").asText()).put("usedSeconds",0).put("createdAt",now().toString()).put("status","READY");
        try{data.set("reportSnapshot",store.mapper().readTree(report.path("payload").asText()));}catch(Exception ex){throw new IllegalStateException("Saved report cannot be read");}
        data.putArray("questions");
        if(!windowAvailable()||Duration.between(now(),local().toLocalDate().atTime(17,0).atZone(EngineeringPolicy.ZONE).toInstant()).toMinutes()<15){data.put("status","SCHEDULED").put("scheduledDate",nextDate().toString());}
        var row=store.put(user,"PRACTICE",id,0,data);
        if(data.path("status").asText().equals("SCHEDULED")){practiceCarry(user,id,data);return publicState(row);}
        return activate(user,row);
    }
    private ObjectNode compactContext(ObjectNode session){
        ObjectNode context=store.mapper().createObjectNode();int day=session.path("dayNumber").asInt();context.set("DAY_TOPIC",study.roadmap().path("days").path(day-1));
        ArrayNode snapshot=context.putArray("REPORT_SNAPSHOT");int budget=22000;
        for(JsonNode row:session.path("reportSnapshot")){
            ObjectNode record=snapshot.addObject().put("domain",row.path("domain").asText());JsonNode data=row.path("data");record.put("status",data.path("status").asText());
            for(String key:List.of("notes","code","evidence","complexity","edgeCases","testOutput","gitReference","blockers","nextSteps")){String value=data.path(key).asText();int length=Math.min(Math.min(value.length(),1800),Math.max(0,budget));record.put(key,value.substring(0,length));budget-=length;}
        }
        ArrayNode history=context.putArray("INTERVIEW_HISTORY");int size=session.path("questions").size();for(int i=Math.max(0,size-4);i<size;i++)history.add(session.path("questions").get(i));return context;
    }
    private String nextKind(ObjectNode session){return session.path("questions").size()%3==2?"CODING":"ORAL";}
    private void appendQuestion(ObjectNode session,JsonNode result){
        ObjectNode question=((ObjectNode)result.path("question")).deepCopy();question.put("id",UUID.randomUUID().toString()).put("askedAt",now().toString());((ArrayNode)session.path("questions")).add(question);
    }
    private boolean otherActive(long user,String id){return store.list(user,"PRACTICE").stream().anyMatch(r->!r.key().equals(id)&&r.data().path("status").asText().equals("ACTIVE")&&now().isBefore(cutoff(r.data()))&&elapsed(r.data(),now())<1800);}
    private ObjectNode activate(long user,CoachingStore.Record row){
        var data=row.data().deepCopy();
        if(Set.of("COMPLETED","ACTIVE").contains(data.path("status").asText()))return publicState(row);
        if(data.hasNonNull("scheduledDate")&&LocalDate.parse(data.path("scheduledDate").asText()).isAfter(local().toLocalDate()))throw conflict("This interview is scheduled for "+data.path("scheduledDate").asText()+". Logout remains at 17:00.");
        if(!windowAvailable()){
            data.put("status","CARRIED").put("scheduledDate",nextDate().toString());practiceCarry(user,row.key(),data);return publicState(store.put(user,"PRACTICE",row.key(),row.version(),data));
        }
        if(otherActive(user,row.key()))throw conflict("Pause the active interview before starting another report's session.");
        if(data.path("questions").isEmpty()){
            var config=settings.config(user);data.put("provider",config.path("provider").asText()).put("model",config.path("model").asText()).put("transcriptionModel",config.path("transcriptionModel").asText());
            if(!config.path("savedKeys").path(data.path("provider").asText()).asBoolean())return publicState(row);
            CoachSettingsService.requireFreeProvider(data.path("provider").asText());var turn=provider.turn(data.path("provider").asText(),data.path("model").asText(),settings.key(user,data.path("provider").asText()),compactContext(data),nextKind(data));appendQuestion(data,turn);
        }
        if(data.path("questions").size()>0&&data.path("questions").get(data.path("questions").size()-1).has("answer")){CoachSettingsService.requireFreeProvider(data.path("provider").asText());var turn=provider.turn(data.path("provider").asText(),data.path("model").asText(),settings.key(user,data.path("provider").asText()),compactContext(data),nextKind(data));appendQuestion(data,turn);}
        data.put("status","ACTIVE").put("activeSince",now().toString()).put("lastSeenAt",now().toString());if(!data.has("startedAt"))data.put("startedAt",now().toString());data.remove("scheduledDate");
        return publicState(store.put(user,"PRACTICE",row.key(),row.version(),data));
    }
    public ObjectNode get(long user,String id){var row=checkpoint(user,required(user,id));if(row.data().path("status").asText().equals("ACTIVE"))row=store.touchPractice(user,row);return publicState(row);}
    public ObjectNode action(long user,String id,String action){
        var row=checkpoint(user,required(user,id));
        if(action.equals("resume"))return activate(user,row);
        if(action.equals("complete")){
            if(!canComplete(row.data(),now()))throw conflict("Practice needs at least 15 active minutes and three evaluated answers before completion.");
            var data=stopActive(row.data()).put("status","COMPLETED").put("completedAt",now().toString());resolvePracticeCarry(user,id);return publicState(store.put(user,"PRACTICE",id,row.version(),data));
        }
        if(action.equals("pause")){if(!row.data().path("status").asText().equals("ACTIVE"))return publicState(row);return publicState(store.put(user,"PRACTICE",id,row.version(),stopActive(row.data()).put("status","PAUSED")));}
        if(action.equals("carry")){
            var data=stopActive(row.data()).put("status","CARRIED").put("scheduledDate",local().toLocalDate().plusDays(1).toString());practiceCarry(user,id,data);return publicState(store.put(user,"PRACTICE",id,row.version(),data));
        }
        throw new IllegalArgumentException("Unknown practice action");
    }
    private ObjectNode currentQuestion(ObjectNode data,String questionId){
        if(!data.path("status").asText().equals("ACTIVE"))throw conflict("Resume the interview before answering. At 17:00 unfinished practice is carried forward.");
        JsonNode last=data.path("questions").path(data.path("questions").size()-1);if(!(last instanceof ObjectNode q)||!q.path("id").asText().equals(questionId)||q.has("answer"))throw conflict("This question changed or was already answered. Refresh the session; your device answer is retained.");return q;
    }
    public Map<String,String> transcribe(long user,String id,String questionId,byte[] audio,String mime){
        var row=checkpoint(user,required(user,id));var q=currentQuestion(row.data(),questionId);if(!q.path("kind").asText().equals("ORAL"))throw new IllegalArgumentException("This is a coding question; use the code editor");
        String p=row.data().path("provider").asText();CoachSettingsService.requireFreeProvider(p);String model=CoachSettingsService.FREE_AUDIO_MODEL;
        String transcript=provider.transcribe(p,model,settings.key(user,p),audio,mime);String receipt=UUID.randomUUID().toString();
        store.put(user,"TRANSCRIPT",receipt,0,store.mapper().createObjectNode().put("sessionId",id).put("questionId",questionId).put("text",transcript).put("source","PROVIDER_AUDIO").put("createdAt",now().toString()));return Map.of("transcriptId",receipt,"text",transcript);
    }
    /** Device speech recognition is client-reported; it is not proof of microphone origin. */
    public Map<String,String> deviceTranscript(long user,String id,String questionId,String text){
        var row=checkpoint(user,required(user,id));
        var q=currentQuestion(row.data(),questionId);
        if(!q.path("kind").asText().equals("ORAL"))throw new IllegalArgumentException("This is a coding question; use the code editor");
        String clean=text==null?"":text.strip();
        if(clean.isBlank()||clean.length()>16000)throw new IllegalArgumentException("Speak an answer of up to 16,000 characters");
        String receipt=UUID.randomUUID().toString();
        store.put(user,"TRANSCRIPT",receipt,0,store.mapper().createObjectNode().put("sessionId",id).put("questionId",questionId).put("text",clean).put("source","CLIENT_SPEECH_RECOGNITION").put("createdAt",now().toString()));
        return Map.of("transcriptId",receipt,"text",clean);
    }
    public ObjectNode answer(long user,String id,String questionId,String transcriptId,String code,UUID mutation){
        var row=checkpoint(user,required(user,id));
        for(JsonNode q:row.data().path("questions"))if(q.path("answer").path("mutationId").asText().equals(mutation.toString()))return publicState(row);
        var data=row.data().deepCopy();var q=currentQuestion(data,questionId);String answer,source;
        if(q.path("kind").asText().equals("ORAL")){
            var transcript=store.get(user,"TRANSCRIPT",transcriptId==null?"":transcriptId).orElseThrow(()->new IllegalArgumentException("Record and transcribe your spoken answer first"));
            if(!transcript.data().path("sessionId").asText().equals(id)||!transcript.data().path("questionId").asText().equals(questionId))throw new IllegalArgumentException("The voice transcript belongs to another question");
            answer=transcript.data().path("text").asText();source=transcript.data().path("source").asText().equals("CLIENT_SPEECH_RECOGNITION")?"CLIENT_SPEECH":"VOICE";
        }else{if(code==null||code.isBlank()||code.length()>20000)throw new IllegalArgumentException("Enter your coding solution (up to 20,000 characters)");answer=code;source="CODE";}
        ObjectNode context=compactContext(data);context.putObject("LATEST_ANSWER").put("questionId",questionId).put("source",source).put("text",answer);
        String kind=(data.path("questions").size()%3==2)?"CODING":"ORAL";
        CoachSettingsService.requireFreeProvider(data.path("provider").asText());var turn=provider.turn(data.path("provider").asText(),data.path("model").asText(),settings.key(user,data.path("provider").asText()),context,kind);
        ObjectNode record=q.putObject("answer").put("text",answer).put("source",source).put("answeredAt",now().toString()).put("mutationId",mutation.toString());record.set("evaluation",turn.path("evaluation"));data.put("lastSeenAt",now().toString());
        appendQuestion(data,turn);
        var saved=store.put(user,"PRACTICE",id,row.version(),data);return publicState(checkpoint(user,saved));
    }
    public void onLogout(long user,LocalDate workDate){
        if(!EngineeringPolicy.applies(workDate))return;
        for(var initial:store.list(user,"PRACTICE"))if(Set.of("ACTIVE","PAUSED","READY").contains(initial.data().path("status").asText())){
            var row=required(user,initial.key());var data=stopActive(row.data());
            if(canComplete(row.data(),now())){data.put("status","COMPLETED").put("completedAt",now().toString());resolvePracticeCarry(user,row.key());}
            else{data.put("status","CARRIED").put("scheduledDate",workDate.plusDays(1).toString());practiceCarry(user,row.key(),data);}
            store.put(user,"PRACTICE",row.key(),row.version(),data);
        }
    }
}
