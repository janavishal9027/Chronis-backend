package com.chronis.dailyreport.domain;

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

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "daily_reports")
@Getter
@Setter
public class DailyReport extends BaseEntity {

    public enum Status { DRAFT, SUBMITTED, REVIEWED, APPROVED, REQUEST_CHANGES }

    @ManyToOne(optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "report_date", nullable = false)
    private LocalDate reportDate;

    @Column(name = "attendance_hours")
    private Double attendanceHours;

    @Column(name = "break_hours")
    private Double breakHours;

    @Column(name = "net_working_hours")
    private Double netWorkingHours;

    @Column(name = "overtime_hours")
    private Double overtimeHours;

    @Column(name = "completed_work", length = 2000)
    private String completedWork;

    @Column(name = "in_progress_work", length = 2000)
    private String inProgressWork;

    @Column(name = "pending_work", length = 2000)
    private String pendingWork;

    @Column(name = "blockers_challenges", length = 2000)
    private String blockersChallenges;

    @Column(name = "tomorrow_plans", length = 2000)
    private String tomorrowPlans;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 30)
    private Status status = Status.DRAFT;

    @Column(name = "manager_feedback", length = 2000)
    private String managerFeedback;

    @ManyToOne
    @JoinColumn(name = "reviewed_by")
    private User reviewedBy;

    @Column(name = "reviewed_at")
    private LocalDateTime reviewedAt;

    @Column(name = "revision_number")
    private Integer revisionNumber = 0;
}
