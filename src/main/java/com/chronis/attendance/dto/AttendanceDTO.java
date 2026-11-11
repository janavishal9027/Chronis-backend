package com.chronis.attendance.dto;

import com.chronis.attendance.domain.AttendanceSession;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AttendanceDTO {
    private Long id;
    private Long userId;
    private LocalDate workDate;
    private Instant checkInTime;
    private Instant checkOutTime;
    private AttendanceSession.Status status;
    private Long attendanceDurationMinutes;
    private Long breakDurationMinutes;
    private Long netWorkingDurationMinutes;
    private Long overtimeDurationMinutes;
    private Long scheduledDurationMinutes;
    private Boolean isLate;
    private Boolean earlyDeparture;
}
