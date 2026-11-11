package com.chronis.engineering;

import com.chronis.attendance.repository.AttendanceSessionRepository;
import com.chronis.common.security.AccessScope;
import com.chronis.auth.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import java.util.List;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class DatabaseRoadmapTest {
    private final JdbcTemplate jdbc = mock(JdbcTemplate.class);
    private final ObjectMapper json = new ObjectMapper();
    private final StudyService study = new StudyService(jdbc, json, mock(AccessScope.class),
            mock(UserRepository.class), mock(AttendanceSessionRepository.class), mock(EngineeringPolicy.class));

    @Test void servesTheCompleteDatabaseRoadmap() throws Exception {
        var seed = json.readTree(getClass().getClassLoader().getResourceAsStream("engineering-roadmap.json"));
        when(jdbc.query(anyString(), org.mockito.ArgumentMatchers.<RowMapper<String>>any(), eq(EngineeringPolicy.PLAN)))
                .thenReturn(List.of(seed.toString()));
        assertEquals(seed, study.roadmap());
        verify(jdbc).query(contains("engineering_curricula"), org.mockito.ArgumentMatchers.<RowMapper<String>>any(), eq(EngineeringPolicy.PLAN));
    }

    @Test void aMissingDatabaseRoadmapIsReported() {
        when(jdbc.query(anyString(), org.mockito.ArgumentMatchers.<RowMapper<String>>any(), eq(EngineeringPolicy.PLAN)))
                .thenReturn(List.of());
        assertThrows(IllegalStateException.class, study::roadmap);
    }
}
