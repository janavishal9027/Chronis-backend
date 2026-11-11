package com.chronis.task.dto;

import com.chronis.task.domain.Task;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TaskDTO {
    private Long id;
    private String taskCode;
    private String title;
    private String description;
    private Long projectId;
    private String projectName;
    private Long assignedToId;
    private String assignedToName;
    private Long assignedById;
    private Long parentTaskId;
    private Task.Priority priority;
    private Task.Status status;
    private LocalDate plannedStartDate;
    private LocalDate deadline;
    private Long estimatedDurationMinutes;
    private Long actualTimeSpentMinutes;
    private Integer progressPercentage;
    private Integer completionPercentage;
    private LocalDateTime completedAt;
}
