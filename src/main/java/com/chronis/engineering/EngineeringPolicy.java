package com.chronis.engineering;

import java.time.*;
import java.time.temporal.ChronoUnit;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;

/** Authoritative study attendance policy. No client clock can bypass these checks. */
@Service
public class EngineeringPolicy {
    public static final String PLAN = "chronis-ai-engineering-2026-11-05";
    public static final ZoneId ZONE = ZoneId.of("Asia/Kolkata");
    public static final LocalDate START = LocalDate.of(2026,11,5), END = LocalDate.of(2027,2,4);
    private final JdbcTemplate jdbc;
    private final Clock clock;
    public EngineeringPolicy(JdbcTemplate jdbc, Clock clock) { this.jdbc=jdbc; this.clock=clock; }
    public Instant now() { return clock.instant(); }
    public LocalDate today() { return now().atZone(ZONE).toLocalDate(); }
    public static boolean applies(LocalDate date) { return !date.isBefore(START) && !date.isAfter(END); }
    public static int dayNumber(LocalDate date) { return Math.toIntExact(ChronoUnit.DAYS.between(START,date)+1); }
    public static LocalDate dateForDay(int day) {
        if(day<1 || day>92) throw new IllegalArgumentException("Day must be between 1 and 92");
        return START.plusDays(day-1);
    }
    public static boolean emergency(String reason) { return reason!=null && reason.trim().length()>=10 && reason.length()<=1000; }
    public static void validateLogin(LocalDate workDate, Instant now, String reason) {
        if(!applies(workDate)) return;
        LocalTime time=now.atZone(ZONE).toLocalTime();
        if(!time.isBefore(LocalTime.of(17,0)) && !emergency(reason))
            throw new ResponseStatusException(HttpStatus.CONFLICT,"Study login closes at 17:00 IST. An exceptional login after 17:00 requires a recorded reason of at least 10 characters.");
    }
    public static void validateLogout(LocalDate workDate, Instant now, boolean reportSubmitted, String reason) {
        if(!applies(workDate)) return;
        var local=now.atZone(ZONE);
        boolean timeAllowed=local.toLocalDate().equals(workDate) && !local.toLocalTime().isBefore(LocalTime.of(16,55)) && !local.toLocalTime().isAfter(LocalTime.of(17,0));
        if((!timeAllowed || !reportSubmitted) && !emergency(reason))
            throw new ResponseStatusException(HttpStatus.CONFLICT,"Normal study logout requires 16:55–17:00 IST and a submitted five-domain report. Use emergency logout with a recorded reason if necessary.");
    }
    public void beforeLogin(Long user, LocalDate date, String reason) {
        validateLogin(date,now(),reason);
        if(applies(date)) record(user,"STUDY_LOGIN",date,"Planned 09:00 IST; actual server time "+now()+(emergency(reason)?"; override: "+reason.trim():""));
    }
    public void beforeLogout(Long user, LocalDate date, String reason) {
        if(!applies(date)) return;
        boolean submitted=Boolean.TRUE.equals(jdbc.queryForObject("select exists(select 1 from engineering_report_submissions r where r.user_id=? and r.plan_id=? and r.day_number=? and not exists(select 1 from engineering_work w where w.user_id=r.user_id and w.plan_id=r.plan_id and w.day_number=r.day_number and not exists(select 1 from jsonb_array_elements(r.payload) e where e->>'domain'=w.domain and (e->>'version')::bigint=w.version)))",Boolean.class,user,PLAN,dayNumber(date)));
        validateLogout(date,now(),submitted,reason);
        record(user,emergency(reason)?"STUDY_EMERGENCY_LOGOUT":"STUDY_LOGOUT",date,"Planned 16:55 IST; actual server time "+now()+(emergency(reason)?"; reason: "+reason.trim():""));
    }
    public void record(Long user,String type,LocalDate date,String detail) {
        jdbc.update("insert into engineering_events(user_id,event_type,work_date,detail,recorded_at) values(?,?,?,?,?)",user,type,date,detail,java.sql.Timestamp.from(now()));
    }
}
