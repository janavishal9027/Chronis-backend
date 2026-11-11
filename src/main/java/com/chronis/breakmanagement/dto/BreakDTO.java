package com.chronis.breakmanagement.dto;

import com.chronis.breakmanagement.domain.BreakSession;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BreakDTO {
    private Long id;
    private Long attendanceSessionId;
    private BreakSession.Type breakType;
    private Instant startTime;
    private Instant endTime;
    private Long durationMinutes;
    private String reason;
}
