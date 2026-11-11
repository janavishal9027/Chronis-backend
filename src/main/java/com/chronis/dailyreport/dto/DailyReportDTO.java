package com.chronis.dailyreport.dto;

import com.chronis.dailyreport.domain.DailyReport;
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
public class DailyReportDTO {
    private Long id;
    private Long userId;
    private LocalDate reportDate;
    private Double attendanceHours;
    private Double breakHours;
    private Double netWorkingHours;
    private Double overtimeHours;
    private String completedWork;
    private String inProgressWork;
    private String pendingWork;
    private String blockersChallenges;
    private String tomorrowPlans;
    private DailyReport.Status status;
    private String managerFeedback;
    private Long reviewedBy;
    private LocalDateTime reviewedAt;
    private Integer revisionNumber;
}
