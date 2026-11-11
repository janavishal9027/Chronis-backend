package com.chronis.workupdate.domain;

import com.chronis.common.audit.BaseEntity;
import com.chronis.auth.domain.User;
import com.chronis.project.domain.Project;
import com.chronis.task.domain.Task;
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
@Table(name = "work_updates")
@Getter
@Setter
public class WorkUpdate extends BaseEntity {

    public enum Status { DRAFT, SUBMITTED }

    public enum Category { DEVELOPMENT, TESTING, DESIGN, MEETING, RESEARCH, ADMIN, OTHER }

    @ManyToOne(optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "work_date", nullable = false)
    private LocalDate workDate;

    @ManyToOne
    @JoinColumn(name = "project_id")
    private Project project;

    @ManyToOne
    @JoinColumn(name = "task_id")
    private Task task;

    @Column(name = "work_category", length = 50)
    private String workCategory;

    @Column(name = "work_description", length = 2000)
    private String workDescription;

    @Column(name = "start_time")
    private LocalDateTime startTime;

    @Column(name = "end_time")
    private LocalDateTime endTime;

    @Column(name = "time_spent_minutes")
    private Long timeSpentMinutes;

    @Column(name = "progress_percentage")
    private Integer progressPercentage;

    @Column(name = "work_completed")
    private Boolean workCompleted = false;

    @Column(name = "challenges", length = 1000)
    private String challenges;

    @Column(name = "blockers", length = 1000)
    private String blockers;

    @Column(name = "next_steps", length = 1000)
    private String nextSteps;

    @Column(name = "attachment_url", length = 500)
    private String attachmentUrl;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private Status status = Status.DRAFT;
}
