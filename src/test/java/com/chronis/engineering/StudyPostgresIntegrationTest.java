package com.chronis.engineering;

import com.chronis.auth.domain.User;
import com.chronis.auth.repository.UserRepository;
import com.chronis.auth.service.AccountProvisioningService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import java.time.*;
import java.util.*;
import static org.junit.jupiter.api.Assertions.*;

/** Opt-in isolated PostgreSQL schema; never uses the installation's business tables. */
@SpringBootTest(webEnvironment=SpringBootTest.WebEnvironment.MOCK)
@org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
@EnabledIfEnvironmentVariable(named="CHRONIS_STUDY_IT",matches="true")
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class StudyPostgresIntegrationTest {
    private static final String SCHEMA="chronis_study_it_"+UUID.randomUUID().toString().replace("-","");
    @DynamicPropertySource static void config(DynamicPropertyRegistry r){
        r.add("spring.datasource.url",()->System.getenv("CHRONIS_TEST_DB_URL"));
        r.add("spring.datasource.username",()->System.getenv("CHRONIS_TEST_DB_USER"));
        r.add("spring.datasource.password",()->System.getenv("CHRONIS_TEST_DB_PASSWORD"));
        com.chronis.support.PostgresTestSchema.create(SCHEMA);r.add("spring.jpa.properties.hibernate.default_schema",()->SCHEMA);
        r.add("spring.datasource.hikari.connection-init-sql",()->"SET search_path TO "+SCHEMA);
        
        r.add("app.bootstrap.password",()->"");r.add("app.jwt.secret",()->"Chronis-Integration-Only-Secret-At-Least-32-Bytes");
        r.add("JWT_SECRET",()->"Chronis-Integration-Only-Secret-At-Least-32-Bytes");
        r.add("management.health.mail.enabled",()->false);r.add("spring.mail.host",()->"");
    }
    static final class MutableClock extends Clock {
        Instant value=Instant.parse("2026-11-05T03:30:00Z");
        public ZoneId getZone(){return ZoneOffset.UTC;} public Clock withZone(ZoneId z){return this;}public Instant instant(){return value;}
    }
    @TestConfiguration static class Config {@Bean @Primary MutableClock testClock(){return new MutableClock();}}
    @Autowired StudyService study;
    @Autowired EngineeringPolicy policy;
    @Autowired com.chronis.attendance.service.AttendanceService attendance;
    @Autowired AccountProvisioningService accounts;
    @Autowired UserRepository users;
    @Autowired JdbcTemplate jdbc;
    @Autowired MutableClock clock;
    @Autowired org.springframework.test.web.servlet.MockMvc mvc;
    @Autowired ObjectMapper mapper;

    private void signIn(User user){SecurityContextHolder.getContext().setAuthentication(new UsernamePasswordAuthenticationToken(user,null,List.of(new org.springframework.security.core.authority.SimpleGrantedAuthority("ROLE_EMPLOYEE"))));}
    @AfterAll void removeOnlyThisTestSchema(){
        if(!SCHEMA.matches("chronis_study_it_[a-f0-9]{32}"))throw new IllegalStateException("Invalid test schema");
        jdbc.execute("drop schema "+SCHEMA+" cascade");
    }
    private StudyWorkRequest request(UUID mutation,long version){return new StudyWorkRequest(mutation,version,StudyWorkRequest.Status.NOT_STARTED,"","","",0,"Test skip: no study claimed",0,"","","","","","","");}
    @Test void jwtAuthenticatedHttpWorkUpdatesUseTheExistingLogin() throws Exception {
        clock.value=Instant.parse("2026-11-05T03:30:00Z");
        String email="study-http-"+UUID.randomUUID()+"@example.invalid";
        accounts.createAccount("Study HTTP Test",email,"Integration-Password-Only",true,null);
        String response=mvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post("/api/v1/auth/login")
            .contentType("application/json").content(mapper.writeValueAsString(Map.of("username",email,"password","Integration-Password-Only"))))
            .andExpect(org.springframework.test.web.servlet.result.MockMvcResultMatchers.status().isOk()).andReturn().getResponse().getContentAsString();
        String token=mapper.readTree(response).path("data").path("accessToken").asText();assertFalse(token.isBlank());
        mvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get("/api/v1/engineering/roadmap"))
            .andExpect(org.springframework.test.web.servlet.result.MockMvcResultMatchers.status().isUnauthorized());
        mvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get("/api/v1/engineering/roadmap").header("Authorization","Bearer "+token))
            .andExpect(org.springframework.test.web.servlet.result.MockMvcResultMatchers.status().isOk())
            .andExpect(org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath("$.days.length()").value(92));
        mvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post("/api/v1/attendance/check-in").header("Authorization","Bearer "+token))
            .andExpect(org.springframework.test.web.servlet.result.MockMvcResultMatchers.status().isOk());
        mvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put("/api/v1/engineering/days/1/work/CONCEPT").header("Authorization","Bearer "+token)
            .contentType("application/json").content(mapper.writeValueAsString(request(UUID.randomUUID(),0))))
            .andExpect(org.springframework.test.web.servlet.result.MockMvcResultMatchers.status().isOk());
        mvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get("/api/v1/engineering/days/1/progress").header("Authorization","Bearer "+token))
            .andExpect(org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath("$.work.length()").value(1));
        mvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get("/api/v1/engineering/overview"))
            .andExpect(org.springframework.test.web.servlet.result.MockMvcResultMatchers.status().isUnauthorized());
        mvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get("/api/v1/engineering/overview").header("Authorization","Bearer "+token))
            .andExpect(org.springframework.test.web.servlet.result.MockMvcResultMatchers.status().isOk())
            .andExpect(org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath("$.submittedDays").value(0))
            .andExpect(org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath("$.work.length()").value(1));
        SecurityContextHolder.clearContext();
    }
    @Test void realPostgresPreservesUpdatesRevisionsOwnershipReportsAndAttendance(){
        clock.value=Instant.parse("2026-11-05T03:30:00Z");
        User a=accounts.createAccount("Study Integration A","study-a-"+UUID.randomUUID()+"@example.invalid","Integration-Password-Only",true,null);
        signIn(a);assertEquals(92,study.roadmap().path("days").size());
        assertThrows(Exception.class,()->study.save(1,StudyWorkRequest.Domain.CONCEPT,request(UUID.randomUUID(),0)));
        attendance.checkIn();
        UUID mutation=UUID.randomUUID();study.save(1,StudyWorkRequest.Domain.CONCEPT,request(mutation,0));study.save(1,StudyWorkRequest.Domain.CONCEPT,request(mutation,0));
        assertEquals(1,study.history(1,StudyWorkRequest.Domain.CONCEPT).size());
        assertThrows(Exception.class,()->study.save(1,StudyWorkRequest.Domain.CONCEPT,request(UUID.randomUUID(),0)));
        assertThrows(Exception.class,()->study.submit(1,null));
        for(var d:List.of(StudyWorkRequest.Domain.BASIC_CODING,StudyWorkRequest.Domain.SCENARIO,StudyWorkRequest.Domain.PROJECT,StudyWorkRequest.Domain.INTERVIEW))study.save(1,d,request(UUID.randomUUID(),0));
        study.save(1,StudyWorkRequest.Domain.REVIEW,request(UUID.randomUUID(),0));
        study.submit(1,null);study.submit(1,null);
        assertEquals(1,((List<?>)study.progress(1).get("reports")).size());
        var submitted=((Map<?,?>)((List<?>)study.progress(1).get("reports")).getFirst()).get("data").toString();
        assertTrue(submitted.contains("\"domain\":\"REVIEW\""));
        clock.value=Instant.parse("2026-11-05T11:24:00Z");assertThrows(Exception.class,()->attendance.checkOut());
        clock.value=Instant.parse("2026-11-05T11:25:00Z");
        study.save(1,StudyWorkRequest.Domain.CONCEPT,request(UUID.randomUUID(),1));assertThrows(Exception.class,()->attendance.checkOut());
        study.submit(1,null);assertNotNull(attendance.checkOut().getCheckOutTime());
        assertEquals(2,study.history(1,StudyWorkRequest.Domain.CONCEPT).size());
        assertEquals(1L,study.overview().get("submittedDays"));
        assertEquals(6,((List<?>)study.overview().get("work")).size());
        assertEquals(1,((List<?>)study.overview().get("reports")).size());
        assertEquals(2,((Map<?,?>)((List<?>)study.overview().get("reports")).getFirst()).get("version"));
        assertEquals(List.of("2026-11-05"),study.overview().get("attendanceDates"));
        assertEquals(2,((List<?>)study.overview().get("reportHistory")).size());
        User b=accounts.createAccount("Study Integration B","study-b-"+UUID.randomUUID()+"@example.invalid","Integration-Password-Only",true,null);signIn(b);
        assertTrue(((List<?>)study.progress(1).get("work")).isEmpty());assertTrue(study.history(1,StudyWorkRequest.Domain.CONCEPT).isEmpty());
        assertEquals(0L,study.overview().get("submittedDays"));
        assertTrue(((List<?>)study.overview().get("work")).isEmpty());
        assertTrue(((List<?>)study.overview().get("reports")).isEmpty());
        assertTrue(((List<?>)study.overview().get("reportHistory")).isEmpty());
        assertTrue(((List<?>)study.overview().get("attendanceDates")).isEmpty());
        assertEquals(2,jdbc.queryForObject("select count(*) from "+SCHEMA+".engineering_report_submissions",Integer.class));
        SecurityContextHolder.clearContext();
    }
}
