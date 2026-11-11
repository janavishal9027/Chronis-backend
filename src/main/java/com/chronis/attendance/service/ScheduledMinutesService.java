package com.chronis.attendance.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import java.time.LocalDate;

/** Preserves the former default schedule's daily totals without schedule tables. */
@Service
public class ScheduledMinutesService {
    static final String CONFIG_KEY = "attendance.scheduled_minutes_by_weekday";
    private final JdbcTemplate jdbc;
    private final ObjectMapper mapper;
    public ScheduledMinutesService(JdbcTemplate jdbc, ObjectMapper mapper) {
        this.jdbc = jdbc;
        this.mapper = mapper;
    }
    public long forDate(LocalDate date) {
        int day = date.getDayOfWeek().getValue() % 7;
        var rows = jdbc.query("select value from configuration where key=?",
                (rs, index) -> rs.getString(1), CONFIG_KEY);
        if (rows.isEmpty()) return day >= 1 && day <= 5 ? 400L : 0L;
        try {
            var value = mapper.readTree(rows.getFirst()).path(Integer.toString(day));
            if (!value.isIntegralNumber() || value.asLong() < 0) throw new IllegalStateException("Invalid scheduled minutes");
            return value.asLong();
        } catch (java.io.IOException ex) {
            throw new IllegalStateException("Invalid scheduled minutes configuration", ex);
        }
    }
}
