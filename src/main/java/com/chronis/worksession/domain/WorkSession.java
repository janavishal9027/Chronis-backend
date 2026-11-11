package com.chronis.worksession.domain;

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
@Table(name = "work_sessions")
@Getter
@Setter
public class WorkSession extends BaseEntity {

    public enum Status { ACTIVE, ENDED }

    @ManyToOne(optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "session_start", nullable = false)
    private Instant sessionStart;

    @Column(name = "session_end")
    private Instant sessionEnd;

    @Column(name = "elapsed_duration_minutes")
    private Long elapsedDurationMinutes;

    @Column(name = "productive_duration_minutes")
    private Long productiveDurationMinutes;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private Status status = Status.ACTIVE;
}
