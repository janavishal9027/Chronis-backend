package com.chronis.workupdate.dto;

import com.chronis.workupdate.domain.WorkUpdate;
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
public class WorkUpdateDTO {
    private Long id;
    private Long userId;
    private LocalDate workDate;
    private Long projectId;
    private Long taskId;
    private String workCategory;
    private String workDescription;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private Long timeSpentMinutes;
    private Integer progressPercentage;
    private Boolean workCompleted;
    private String challenges;
    private String blockers;
    private String nextSteps;
    private String attachmentUrl;
    private WorkUpdate.Status status;
}
