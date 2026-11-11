package com.chronis.task.service;

import com.chronis.common.exception.AppException;
import com.chronis.common.exception.ErrorCode;
import com.chronis.task.domain.Task;
import com.chronis.task.dto.TaskDTO;
import com.chronis.task.repository.TaskRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class TaskService {

    private final TaskRepository taskRepository;
    private final com.chronis.common.security.AccessScope access;

    public List<TaskDTO> getByAssignee(Long userId) {
        Long scopedId = userId == null ? access.currentUser().getId() : userId;
        access.requireUser(scopedId);
        return taskRepository.findByAssignedToId(scopedId).stream().map(this::toDto).collect(Collectors.toList());
    }

    @Transactional
    public TaskDTO updateStatus(Long id, Task.Status status) {
        Task t = taskRepository.findById(id)
                .orElseThrow(() -> new AppException(ErrorCode.TASK_NOT_FOUND.getCode(), "Task not found"));
        access.requireUser(t.getAssignedTo().getId());
        if (status == null) throw new IllegalArgumentException("Status is required");
        if (t.getStatus() == status) return toDto(t);
        boolean allowed = switch (t.getStatus()) {
            case NOT_STARTED -> status == Task.Status.IN_PROGRESS || status == Task.Status.CANCELLED;
            case IN_PROGRESS -> status == Task.Status.BLOCKED || status == Task.Status.UNDER_REVIEW
                    || status == Task.Status.COMPLETED || status == Task.Status.CANCELLED;
            case BLOCKED -> status == Task.Status.IN_PROGRESS || status == Task.Status.CANCELLED;
            case UNDER_REVIEW -> status == Task.Status.IN_PROGRESS || status == Task.Status.COMPLETED || status == Task.Status.CANCELLED;
            case COMPLETED, CANCELLED -> status == Task.Status.IN_PROGRESS;
        };
        if (!allowed) throw new AppException(ErrorCode.TASK_INVALID_STATUS_TRANSITION.getCode(), "Invalid task status transition");
        t.setStatus(status);
        if (status == Task.Status.COMPLETED) {
            t.setProgressPercentage(100);
            t.setCompletionPercentage(100);
            t.setCompletedAt(java.time.LocalDateTime.now(java.time.ZoneOffset.UTC));
        } else {
            t.setCompletedAt(null);
            if (Integer.valueOf(100).equals(t.getProgressPercentage())) t.setProgressPercentage(0);
            t.setCompletionPercentage(t.getProgressPercentage());
        }
        return toDto(taskRepository.save(t));
    }

    private TaskDTO toDto(Task t) {
        return TaskDTO.builder()
                .id(t.getId()).taskCode(t.getTaskCode()).title(t.getTitle()).description(t.getDescription())
                .projectId(t.getProject() != null ? t.getProject().getId() : null)
                .projectName(t.getProject() != null ? t.getProject().getName() : null)
                .assignedToId(t.getAssignedTo() != null ? t.getAssignedTo().getId() : null)
                .assignedToName(t.getAssignedTo() != null ? t.getAssignedTo().getFirstName() + " " + t.getAssignedTo().getLastName() : null)
                .assignedById(t.getAssignedBy() != null ? t.getAssignedBy().getId() : null)
                .parentTaskId(t.getParentTaskId()).priority(t.getPriority()).status(t.getStatus())
                .plannedStartDate(t.getPlannedStartDate()).deadline(t.getDeadline())
                .estimatedDurationMinutes(t.getEstimatedDurationMinutes())
                .actualTimeSpentMinutes(t.getActualTimeSpentMinutes())
                .progressPercentage(t.getProgressPercentage())
                .completionPercentage(t.getCompletionPercentage()).completedAt(t.getCompletedAt())
                .build();
    }
}
