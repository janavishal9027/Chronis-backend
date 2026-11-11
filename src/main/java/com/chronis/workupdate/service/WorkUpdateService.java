package com.chronis.workupdate.service;

import com.chronis.auth.domain.User;
import com.chronis.auth.repository.UserRepository;
import com.chronis.common.exception.AppException;
import com.chronis.common.exception.ErrorCode;
import com.chronis.workupdate.domain.WorkUpdate;
import com.chronis.workupdate.dto.WorkUpdateDTO;
import com.chronis.workupdate.dto.WorkUpdateRequest;
import com.chronis.workupdate.repository.WorkUpdateRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class WorkUpdateService {

    private final WorkUpdateRepository workUpdateRepository;
    private final UserRepository userRepository;
    private final com.chronis.common.security.AccessScope access;
    private final com.chronis.project.repository.ProjectRepository projects;
    private final com.chronis.task.repository.TaskRepository tasks;

    private User currentUser() {
        return access.currentUser();
    }

    public List<WorkUpdateDTO> getToday() {
        User user = currentUser();
        java.time.LocalDate today = java.time.LocalDate.now(ZoneIdOf(user));
        return workUpdateRepository.findByUserIdAndWorkDate(user.getId(), today).stream()
                .map(this::toDto).collect(Collectors.toList());
    }

    @Transactional
    public WorkUpdateDTO create(WorkUpdateRequest request) {
        User user = currentUser();
        WorkUpdate wu = new WorkUpdate();
        if (request.getStartTime() != null && request.getEndTime() != null && request.getEndTime().isBefore(request.getStartTime()))
            throw new IllegalArgumentException("End time cannot precede start time");
        if (request.getProjectId() != null) {
            var project = projects.findById(request.getProjectId()).orElseThrow(() -> new AppException(ErrorCode.PROJECT_NOT_FOUND.getCode(), "Project not found"));
            access.requireProject(project);
            wu.setProject(project);
        }
        if (request.getTaskId() != null) {
            var task = tasks.findById(request.getTaskId()).orElseThrow(() -> new AppException(ErrorCode.TASK_NOT_FOUND.getCode(), "Task not found"));
            access.requireOwner(task.getAssignedTo().getId());
            if (wu.getProject() != null && (task.getProject() == null || !wu.getProject().getId().equals(task.getProject().getId())))
                throw new IllegalArgumentException("Task does not belong to the selected project");
            wu.setTask(task);
            wu.setProject(task.getProject());
        }
        wu.setUser(user);
        wu.setWorkDate(request.getWorkDate());
        wu.setWorkCategory(request.getWorkCategory());
        wu.setWorkDescription(request.getWorkDescription());
        wu.setStartTime(request.getStartTime());
        wu.setEndTime(request.getEndTime());
        wu.setTimeSpentMinutes(request.getTimeSpentMinutes());
        if (request.getStartTime() != null && request.getEndTime() != null)
            wu.setTimeSpentMinutes(java.time.Duration.between(request.getStartTime(), request.getEndTime()).toMinutes());
        wu.setProgressPercentage(request.getProgressPercentage());
        wu.setWorkCompleted(request.getWorkCompleted() != null ? request.getWorkCompleted() : false);
        wu.setChallenges(request.getChallenges());
        wu.setBlockers(request.getBlockers());
        wu.setNextSteps(request.getNextSteps());
        wu.setAttachmentUrl(request.getAttachmentUrl());
        wu.setStatus(WorkUpdate.Status.DRAFT);
        return toDto(workUpdateRepository.save(wu));
    }

    private java.time.ZoneId ZoneIdOf(User e) {
        return java.time.ZoneId.of(e.getTimezone() != null ? e.getTimezone() : "Asia/Kolkata");
    }

    private WorkUpdateDTO toDto(WorkUpdate w) {
        return WorkUpdateDTO.builder()
                .id(w.getId()).userId(w.getUser().getId()).workDate(w.getWorkDate())
                .projectId(w.getProject() != null ? w.getProject().getId() : null)
                .taskId(w.getTask() != null ? w.getTask().getId() : null)
                .workCategory(w.getWorkCategory()).workDescription(w.getWorkDescription())
                .startTime(w.getStartTime()).endTime(w.getEndTime()).timeSpentMinutes(w.getTimeSpentMinutes())
                .progressPercentage(w.getProgressPercentage()).workCompleted(w.getWorkCompleted())
                .challenges(w.getChallenges()).blockers(w.getBlockers()).nextSteps(w.getNextSteps())
                .attachmentUrl(w.getAttachmentUrl()).status(w.getStatus()).build();
    }
}
