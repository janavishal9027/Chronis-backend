package com.chronis.dailyreport.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DailyReportRequest {
    @NotBlank
    private String completedWork;
    private String inProgressWork;
    private String pendingWork;
    private String blockersChallenges;
    private String tomorrowPlans;
    private Double attendanceHours;
    private Double breakHours;
    private Double netWorkingHours;
    private Double overtimeHours;
}
