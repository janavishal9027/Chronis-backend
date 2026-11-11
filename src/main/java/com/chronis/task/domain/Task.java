package com.chronis.task.domain;

import com.chronis.common.audit.BaseEntity;
import com.chronis.auth.domain.User;
import com.chronis.project.domain.Project;
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
@Table(name = "tasks")
@Getter
@Setter
public class Task extends BaseEntity {

    public enum Priority { LOW, MEDIUM, HIGH, URGENT }

    public enum Status { NOT_STARTED, IN_PROGRESS, BLOCKED, UNDER_REVIEW, COMPLETED, CANCELLED }

    @Column(name = "task_code", nullable = false, unique = true, length = 50)
    private String taskCode;

    @Column(name = "title", nullable = false, length = 200)
    private String title;

    @Column(name = "description", length = 2000)
    private String description;

    @ManyToOne
    @JoinColumn(name = "project_id")
    private Project project;

    @ManyToOne(optional = false)
    @JoinColumn(name = "assigned_to", nullable = false)
    private User assignedTo;

    @ManyToOne
    @JoinColumn(name = "assigned_by")
    private User assignedBy;

    @Column(name = "parent_task_id")
    private Long parentTaskId;

    @Enumerated(EnumType.STRING)
    @Column(name = "priority", nullable = false, length = 20)
    private Priority priority = Priority.MEDIUM;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 30)
    private Status status = Status.NOT_STARTED;

    @Column(name = "planned_start_date")
    private LocalDate plannedStartDate;

    @Column(name = "deadline")
    private LocalDate deadline;

    @Column(name = "estimated_duration_minutes")
    private Long estimatedDurationMinutes;

    @Column(name = "actual_time_spent_minutes")
    private Long actualTimeSpentMinutes;

    @Column(name = "progress_percentage")
    private Integer progressPercentage;

    @Column(name = "completion_percentage")
    private Integer completionPercentage;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;
}
