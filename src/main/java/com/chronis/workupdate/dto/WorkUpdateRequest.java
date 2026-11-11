package com.chronis.workupdate.dto;

import com.chronis.workupdate.domain.WorkUpdate;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
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
public class WorkUpdateRequest {
    @NotNull
    private LocalDate workDate;
    private Long projectId;
    private Long taskId;
    private String workCategory;
    @NotBlank
    @jakarta.validation.constraints.Size(max = 2000)
    private String workDescription;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    @jakarta.validation.constraints.PositiveOrZero
    private Long timeSpentMinutes;
    @jakarta.validation.constraints.Min(0)
    @jakarta.validation.constraints.Max(100)
    private Integer progressPercentage;
    private Boolean workCompleted;
    private String challenges;
    private String blockers;
    private String nextSteps;
    private String attachmentUrl;
}
