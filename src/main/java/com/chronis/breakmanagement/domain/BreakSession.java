package com.chronis.breakmanagement.domain;

import com.chronis.attendance.domain.AttendanceSession;
import com.chronis.common.audit.BaseEntity;
import com.chronis.auth.domain.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Entity
@Table(name = "break_sessions")
@Getter
@Setter
public class BreakSession extends BaseEntity {

    public enum Type { SHORT, LUNCH, OTHER }

    @ManyToOne(optional = false)
    @JoinColumn(name = "attendance_session_id", nullable = false)
    private AttendanceSession attendanceSession;

    @Enumerated(EnumType.STRING)
    @Column(name = "break_type", nullable = false, length = 20)
    private Type breakType = Type.SHORT;

    @Column(name = "start_time", nullable = false)
    private Instant startTime;

    @Column(name = "end_time")
    private Instant endTime;

    @Column(name = "duration_minutes")
    private Long durationMinutes;

    @Column(name = "reason", length = 500)
    private String reason;
}
