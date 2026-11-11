package com.chronis.attendance.domain;

import com.chronis.common.audit.BaseEntity;
import com.chronis.auth.domain.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Entity
@Table(name = "attendance_sessions", uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "work_date"}))
@Getter
@Setter
public class AttendanceSession extends BaseEntity {

    public enum Status { PRESENT, ABSENT, LEAVE, HALF_DAY }

    @ManyToOne(optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "work_date", nullable = false)
    private java.time.LocalDate workDate;

    @Column(name = "check_in_time")
    private Instant checkInTime;

    @Column(name = "check_out_time")
    private Instant checkOutTime;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private Status status = Status.ABSENT;

    @Column(name = "attendance_duration_minutes")
    private Long attendanceDurationMinutes;

    @Column(name = "break_duration_minutes")
    private Long breakDurationMinutes;

    @Column(name = "net_working_duration_minutes")
    private Long netWorkingDurationMinutes;

    @Column(name = "overtime_duration_minutes")
    private Long overtimeDurationMinutes;

    @Column(name = "scheduled_duration_minutes")
    private Long scheduledDurationMinutes;

    @Column(name = "is_late")
    private Boolean isLate = false;

    @Column(name = "early_departure")
    private Boolean earlyDeparture = false;

    @Column(name = "deleted_at")
    private Instant deletedAt;
}
