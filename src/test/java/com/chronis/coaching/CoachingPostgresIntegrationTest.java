package com.chronis.coaching;

import com.chronis.auth.domain.User;
import com.chronis.auth.repository.UserRepository;
import com.chronis.auth.service.AccountProvisioningService;
import com.chronis.attendance.service.AttendanceService;
import com.chronis.engineering.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.*;
import org.springframework.context.annotation.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.context.*;
import org.springframework.test.web.servlet.MockMvc;
import java.nio.file.*;
import java.time.*;
import java.util.*;
import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.anonymous;

@SpringBootTest(webEnvironment=SpringBootTest.WebEnvironment.MOCK)
@org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
@EnabledIfEnvironmentVariable(named="CHRONIS_COACH_IT",matches="true")
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class CoachingPostgresIntegrationTest {
    static final String SCHEMA="chronis_coach_it_"+UUID.randomUUID().toString().replace("-","");
    static final Path KEYS=keyDirectory();
    static Path keyDirectory(){try{return Files.createTempDirectory("chronis-coach-it-");}catch(Exception ex){throw new RuntimeException(ex);}}
    @DynamicPropertySource static void config(DynamicPropertyRegistry r){
        r.add("spring.datasource.url",()->System.getenv("CHRONIS_TEST_DB_URL"));r.add("spring.datasource.username",()->System.getenv("CHRONIS_TEST_DB_USER"));r.add("spring.datasource.password",()->System.getenv("CHRONIS_TEST_DB_PASSWORD"));
        com.chronis.support.PostgresTestSchema.create(SCHEMA);r.add("spring.jpa.properties.hibernate.default_schema",()->SCHEMA);r.add("spring.datasource.hikari.connection-init-sql",()->"SET search_path TO "+SCHEMA);
        r.add("app.bootstrap.password",()->"");r.add("app.security.jwt.secret",()->"Coaching-Integration-Only-Secret-At-Least-32-Bytes");r.add("management.health.mail.enabled",()->false);r.add("spring.mail.host",()->"");
        r.add("app.coaching.master-key-path",()->KEYS.resolve("master.key").toString());
    }
    static final class MutableClock extends Clock {
        Instant value=Instant.parse("2026-11-06T03:30:00Z");
        public ZoneId getZone(){return ZoneOffset.UTC;}public Clock withZone(ZoneId zone){return this;}public Instant instant(){return value;}
        void at(String time){value=LocalDate.of(2026,11,6).atTime(LocalTime.parse(time)).atZone(EngineeringPolicy.ZONE).toInstant();}
    }
    static final class FakeProvider implements CoachingProvider {
        final ObjectMapper mapper;int calls=0;
        FakeProvider(ObjectMapper mapper){this.mapper=mapper;}
        public ObjectNode turn(String provider,String model,String key,ObjectNode context,String kind){calls++;assertFalse(context.toString().contains("fixture-provider-secret"));ObjectNode result=mapper.createObjectNode();result.putObject("evaluation").put("correctness",4).put("reasoning",3).put("clarity",3).put("coverage",4).put("feedback","Good explanation of the trade-offs").put("improvement","Add an empty-input example");result.putObject("question").put("kind",kind).put("text",kind.equals("CODING")?"Deduplicate while preserving order":"Explain when you choose a set").put("topic","Collections").put("language","Python").put("referenceAnswer","Private fixture reference");return result;}
        public String transcribe(String provider,String model,String key,byte[] bytes,String mime){return "Use a set for unique membership and a list when order is significant.";}
    }
    @TestConfiguration static class Config {
        @Bean @Primary MutableClock clock(){return new MutableClock();}
        @Bean @Primary FakeProvider fake(ObjectMapper mapper){return new FakeProvider(mapper);}
    }
    @Autowired ObjectMapper mapper;@Autowired JdbcTemplate jdbc;@Autowired CoachingStore store;@Autowired StudyWorkspaceService workspace;@Autowired CoachSettingsService settings;@Autowired PracticeService practice;
    @Autowired AccountProvisioningService accounts;@Autowired UserRepository users;@Autowired AttendanceService attendance;@Autowired StudyService study;@Autowired WorkspaceRecords records;@Autowired MutableClock clock;@Autowired FakeProvider provider;@Autowired MockMvc mvc;
    User user(){String email="coach-"+UUID.randomUUID()+"@example.invalid";accounts.createAccount("Coaching Test",email,"Coaching-Integration-Password",true,null);User user=users.findByEmail(email).orElseThrow();sign(user);return user;}
    void sign(User user){SecurityContextHolder.getContext().setAuthentication(new UsernamePasswordAuthenticationToken(user,null,List.of(new org.springframework.security.core.authority.SimpleGrantedAuthority("ROLE_EMPLOYEE"))));}
    long employee(User user){return user.getId();}
    void report(){
        clock.at("09:00");attendance.checkIn();
        for(var domain:List.of(StudyWorkRequest.Domain.CONCEPT,StudyWorkRequest.Domain.BASIC_CODING,StudyWorkRequest.Domain.SCENARIO,StudyWorkRequest.Domain.PROJECT,StudyWorkRequest.Domain.INTERVIEW))study.save(2,domain,new StudyWorkRequest(UUID.randomUUID(),0,StudyWorkRequest.Status.NOT_STARTED,"","","",0,"Integration-only skip; no study claimed",0,"","","","","","",""));
        clock.at("16:00");study.submit(2,null);
    }
    ObjectNode configured(long employee){return settings.save(employee,mapper.createObjectNode().put("provider","OPENROUTER").put("model",CoachSettingsService.FREE_MODEL).put("transcriptionModel",CoachSettingsService.FREE_AUDIO_MODEL).put("durationMinutes",20).put("apiKey","fixture-provider-secret-not-real"));}
    @AfterEach void clearContext(){SecurityContextHolder.clearContext();}
    @AfterAll void cleanOnlyOwnedSchema() throws Exception {if(!SCHEMA.matches("chronis_coach_it_[a-f0-9]{32}"))throw new IllegalStateException();jdbc.execute("drop schema "+SCHEMA+" cascade");Files.deleteIfExists(KEYS.resolve("master.key"));Files.deleteIfExists(KEYS);}
    @Test void projectSectionsCarryoversAndKeysAreAccountScopedAndVersioned() throws Exception {
        clock.at("09:00");User first=user();long employee=employee(first);
        ObjectNode config=configured(employee);assertTrue(config.path("savedKeys").path("OPENROUTER").asBoolean());assertFalse(config.toString().contains("fixture-provider-secret"));
        assertFalse(store.get(employee,"PROVIDER_KEY","OPENROUTER").orElseThrow().data().toString().contains("fixture-provider-secret"));
        ObjectNode section=mapper.createObjectNode().put("status","IN_PROGRESS").put("notes","API design evidence").put("actualMinutes",25);
        var saved=workspace.saveProject(employee,"P01","DESIGN",0,section);assertEquals(1,saved.version());
        assertThrows(Exception.class,()->workspace.saveProject(employee,"P01","DESIGN",0,section));assertEquals(1,store.history(employee,"PROJECT_SECTION","P01:DESIGN").size());
        var carry=mapper.createObjectNode().put("sourceDay",2).put("targetDate","2026-11-07").put("estimatedMinutes",35).put("title","Finish edge cases").put("cause","LATE_LOGIN").put("status","OPEN");workspace.saveCarry(employee,"fixture-task",0,carry);
        workspace.saveLeave(employee,"fixture-leave",0,mapper.createObjectNode().put("dayNumber",2).put("from","10:00").put("to","11:00").put("reason","Planned personal study leave"));
        ObjectNode plan=workspace.plan(employee,2);assertEquals("17:00",plan.path("logoutTime").asText());assertEquals(315,plan.path("availableFocusMinutes").asInt());
        User second=user();var auth=new UsernamePasswordAuthenticationToken(second,null,List.of(new org.springframework.security.core.authority.SimpleGrantedAuthority("ROLE_EMPLOYEE")));
        mvc.perform(get("/api/v1/coaching/projects/P01").with(authentication(auth))).andExpect(status().isOk()).andExpect(jsonPath("$.length()").value(0));
        assertFalse(settings.config(employee(second)).path("savedKeys").path("OPENROUTER").asBoolean());
    }
    @Test void reportInterviewUsesVoiceReceiptsCodingAndRealActiveMinutes(){
        User learner=user();long employee=employee(learner);configured(employee);report();
        ObjectNode session=practice.start(employee,2);assertEquals("ACTIVE",session.path("status").asText());assertEquals(0,session.path("answeredQuestions").asInt());assertFalse(session.has("reportSnapshot"));assertFalse(session.path("questions").path(0).has("referenceAnswer"));String id=session.path("id").asText();
        String firstQuestion=session.path("questions").path(0).path("id").asText();
        assertThrows(Exception.class,()->practice.answer(employee,id,firstQuestion,"forged-receipt",null,UUID.randomUUID()));
        assertThrows(Exception.class,()->practice.deviceTranscript(employee,id,firstQuestion,"   "));
        assertThrows(Exception.class,()->practice.deviceTranscript(employee,id,"wrong-question","Not this question"));
        assertThrows(Exception.class,()->practice.deviceTranscript(employee,id,firstQuestion,"x".repeat(16001)));
        var initialReceipt=practice.deviceTranscript(employee,id,firstQuestion,"  Spoken sample  ");
        var stored=store.get(employee,"TRANSCRIPT",initialReceipt.get("transcriptId")).orElseThrow();
        assertEquals("Spoken sample",stored.data().path("text").asText());
        assertEquals("CLIENT_SPEECH_RECOGNITION",stored.data().path("source").asText());
        User other=user();long otherEmployee=employee(other);
        assertThrows(Exception.class,()->practice.deviceTranscript(otherEmployee,id,firstQuestion,"Another account"));
        assertThrows(Exception.class,()->practice.answer(otherEmployee,id,firstQuestion,initialReceipt.get("transcriptId"),null,UUID.randomUUID()));
        sign(learner);
        for(int i=0;i<9;i++){
            var q=session.path("questions").path(session.path("questions").size()-1);String qid=q.path("id").asText();UUID mutation=UUID.randomUUID();String receipt=null,code=null;
            if(q.path("kind").asText().equals("ORAL"))receipt=practice.deviceTranscript(employee,id,qid,"Use a set for unique membership.").get("transcriptId");else code="def unique(xs): return list(dict.fromkeys(xs))";
            session=practice.answer(employee,id,qid,receipt,code,mutation);int count=provider.calls;
            assertEquals(i+2,session.path("questions").size(),"Each answer should generate the next question");
            assertFalse(session.path("questions").path(i+1).has("answer"));
            session=practice.answer(employee,id,qid,receipt,code,mutation);assertEquals(count,provider.calls,"Duplicate answer must not bill another model call");
        }
        assertEquals(9,session.path("answeredQuestions").asInt());assertTrue(session.path("confidenceProvisional").asBoolean());assertThrows(Exception.class,()->practice.action(employee,id,"complete"));
        for(int i=0;i<30;i++){clock.value=clock.value.plusSeconds(30);practice.get(employee,id);}
        ObjectNode completed=practice.action(employee,id,"complete");assertEquals("COMPLETED",completed.path("status").asText());assertFalse(completed.path("confidenceProvisional").asBoolean());
    }
    @Test void actualLateLoginAndEarlyLogoutReduceCapacityInIst() {
        User learner=user(); long employee=employee(learner);
        clock.at("09:45"); attendance.checkIn("Late start for this test");
        clock.at("16:10"); attendance.checkOut("Early departure for this test");
        ObjectNode plan=workspace.plan(employee,2);
        assertEquals(45,plan.path("lateLoginMinutes").asInt());
        assertEquals(50,plan.path("earlyLogoutMinutes").asInt());
        assertEquals(295,plan.path("availableFocusMinutes").asInt());
        assertEquals(0,plan.path("remainingFocusMinutes").asInt());
        assertEquals("17:00",plan.path("logoutTime").asText());
    }
    @Test void workspaceRecordsAreAccountScopedAndRejectStaleUpdates() {
        User first=user();
        var data=mapper.createObjectNode().put("completed",120).put("session",30).put("block","concept");
        var saved=records.put("focus","2",new WorkspaceRecords.SaveRequest(0,data));
        assertEquals(1,saved.version());
        assertEquals(120,records.get("focus","2").data().path("completed").asInt());
        assertThrows(Exception.class,()->records.put("focus","2",new WorkspaceRecords.SaveRequest(0,data)));
        var updated=records.put("focus","2",new WorkspaceRecords.SaveRequest(1,data.deepCopy().put("completed",180)));
        assertEquals(2,updated.version());
        assertThrows(Exception.class,()->records.delete("focus","2",1));
        assertThrows(Exception.class,()->records.put("focus","93",new WorkspaceRecords.SaveRequest(0,data)));
        assertThrows(Exception.class,()->records.put("unknown","main",new WorkspaceRecords.SaveRequest(0,data)));
        assertThrows(Exception.class,()->records.put("preferences","main",new WorkspaceRecords.SaveRequest(0,mapper.createObjectNode().put("large","x".repeat(128001)))));
        User second=user();
        assertTrue(records.list("focus").isEmpty());
        assertThrows(Exception.class,()->records.get("focus","2"));
        records.put("focus","2",new WorkspaceRecords.SaveRequest(0,data.deepCopy().put("completed",45)));
        sign(first);
        assertEquals(180,records.get("focus","2").data().path("completed").asInt());
        records.delete("focus","2",2);
        assertThrows(Exception.class,()->records.get("focus","2"));
        sign(second);
        assertEquals(45,records.get("focus","2").data().path("completed").asInt());
    }
    @Test void workspaceRecordEndpointsRequireAuthenticationAndOwnAccount() throws Exception {
        User first=user();
        var auth=new UsernamePasswordAuthenticationToken(first,null,List.of(new org.springframework.security.core.authority.SimpleGrantedAuthority("ROLE_EMPLOYEE")));
        String body="{\"expectedVersion\":0,\"data\":{\"checked\":[\"theory\"]}}";
        mvc.perform(put("/api/v1/workspace-records/rhythm/2").with(authentication(auth)).contentType("application/json").content(body))
                .andExpect(status().isOk()).andExpect(jsonPath("$.version").value(1));
        mvc.perform(get("/api/v1/workspace-records/rhythm/2").with(authentication(auth)))
                .andExpect(status().isOk()).andExpect(jsonPath("$.data.checked[0]").value("theory"));
        mvc.perform(get("/api/v1/workspace-records/rhythm").param("key","2").with(authentication(auth)))
                .andExpect(status().isOk()).andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].key").value("2"));
        mvc.perform(get("/api/v1/workspace-records/rhythm").param("key","3").with(authentication(auth)))
                .andExpect(status().isOk()).andExpect(jsonPath("$.length()").value(0));
        mvc.perform(get("/api/v1/workspace-records/rhythm").param("key","invalid").with(authentication(auth)))
                .andExpect(status().isBadRequest());
        mvc.perform(put("/api/v1/workspace-records/rhythm/2").with(authentication(auth)).contentType("application/json").content(body))
                .andExpect(status().isConflict());
        User other=user();
        var otherAuth=new UsernamePasswordAuthenticationToken(other,null,List.of(new org.springframework.security.core.authority.SimpleGrantedAuthority("ROLE_EMPLOYEE")));
        mvc.perform(get("/api/v1/workspace-records/rhythm/2").with(authentication(otherAuth)))
                .andExpect(status().isNotFound());
        mvc.perform(get("/api/v1/workspace-records/rhythm").param("key","2").with(authentication(otherAuth)))
                .andExpect(status().isOk()).andExpect(jsonPath("$.length()").value(0));
        SecurityContextHolder.clearContext();
        mvc.perform(get("/api/v1/workspace-records/rhythm/2").with(anonymous())).andExpect(status().isUnauthorized());
    }
    @Test void lateReportQueuesPracticeWithoutExtendingLogoutOrCallingAProvider(){
        User learner=user();long employee=employee(learner);configured(employee);report();clock.at("16:50");int calls=provider.calls;
        var session=practice.start(employee,2);assertEquals("SCHEDULED",session.path("status").asText());assertEquals("2026-11-07",session.path("scheduledDate").asText());assertEquals(calls,provider.calls);
        assertEquals("17:00",workspace.plan(employee,2).path("logoutTime").asText());assertThrows(Exception.class,()->practice.action(employee,session.path("id").asText(),"resume"));
        var carry=workspace.carries(employee).stream().filter(r->r.data().path("cause").asText().equals("PRACTICE")).findFirst().orElseThrow();var forged=carry.data().deepCopy().put("status","DONE");assertThrows(Exception.class,()->workspace.saveCarry(employee,carry.key(),carry.version(),forged));
        clock.at("17:00");assertNotNull(attendance.checkOut().getCheckOutTime());
    }
}
