package com.chronis.attendance.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import java.time.LocalDate;
import java.util.List;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class ScheduledMinutesServiceTest {
    @Test void migratedTargetsPreserveTheOldSchedule() {
        JdbcTemplate jdbc = mock(JdbcTemplate.class);
        when(jdbc.query(anyString(), org.mockito.ArgumentMatchers.<RowMapper<String>>any(), anyString()))
                .thenReturn(List.of("{\"0\":0,\"1\":330,\"2\":400,\"3\":400,\"4\":400,\"5\":400,\"6\":0}"));
        var service = new ScheduledMinutesService(jdbc, new ObjectMapper());
        assertEquals(330, service.forDate(LocalDate.of(2026, 11, 9)));
        assertEquals(0, service.forDate(LocalDate.of(2026, 11, 8)));
    }
    @Test void freshDatabaseUsesTheFormerSeededWeekdayDefault() {
        JdbcTemplate jdbc = mock(JdbcTemplate.class);
        when(jdbc.query(anyString(), org.mockito.ArgumentMatchers.<RowMapper<String>>any(), anyString()))
                .thenReturn(List.of());
        var service = new ScheduledMinutesService(jdbc, new ObjectMapper());
        assertEquals(400, service.forDate(LocalDate.of(2026, 11, 9)));
        assertEquals(0, service.forDate(LocalDate.of(2026, 11, 8)));
    }
}
