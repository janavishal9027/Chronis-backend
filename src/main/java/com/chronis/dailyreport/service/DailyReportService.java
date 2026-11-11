package com.chronis.dailyreport.service;

import com.chronis.auth.domain.User;
import com.chronis.auth.repository.UserRepository;
import com.chronis.common.exception.AppException;
import com.chronis.common.exception.ErrorCode;
import com.chronis.dailyreport.domain.DailyReport;
import com.chronis.dailyreport.dto.DailyReportDTO;
import com.chronis.dailyreport.dto.DailyReportRequest;
import com.chronis.dailyreport.repository.DailyReportRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.ZoneId;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class DailyReportService {

    private final DailyReportRepository dailyReportRepository;
    private final UserRepository userRepository;
    private final com.chronis.common.security.AccessScope access;
    private final com.chronis.attendance.service.AttendanceService attendanceService;

    private User currentUser() {
        return access.currentUser();
    }

    public DailyReportDTO getToday() {
        User user = currentUser();
        LocalDate today = LocalDate.now(ZoneId.of(user.getTimezone() != null ? user.getTimezone() : "Asia/Kolkata"));
        return dailyReportRepository.findByUserIdAndReportDate(user.getId(), today)
                .map(this::toDto).orElse(null);
    }

    @Transactional
    public DailyReportDTO create(DailyReportRequest request) {
        User user = userRepository.findLockedById(currentUser().getId()).orElseThrow();
        LocalDate today = LocalDate.now(ZoneId.of(user.getTimezone() != null ? user.getTimezone() : "Asia/Kolkata"));
        DailyReport dr = dailyReportRepository.findByUserIdAndReportDate(user.getId(), today).orElseGet(DailyReport::new);
        if (dr.getId() != null && dr.getStatus() != DailyReport.Status.DRAFT && dr.getStatus() != DailyReport.Status.REQUEST_CHANGES)
            throw new AppException(ErrorCode.DR_ALREADY_SUBMITTED.getCode(), "This report is already submitted");
        dr.setUser(user);
        dr.setReportDate(today);
        dr.setCompletedWork(request.getCompletedWork());
        dr.setInProgressWork(request.getInProgressWork());
        dr.setPendingWork(request.getPendingWork());
        dr.setBlockersChallenges(request.getBlockersChallenges());
        dr.setTomorrowPlans(request.getTomorrowPlans());
        updateAttendanceTotals(dr);
        dr.setStatus(DailyReport.Status.DRAFT);
        dr.setRevisionNumber(dr.getRevisionNumber() == null ? 0 : dr.getRevisionNumber() + 1);
        return toDto(dailyReportRepository.save(dr));
    }

    @Transactional
    public DailyReportDTO submit(Long id) {
        DailyReport dr = dailyReportRepository.findById(id)
                .orElseThrow(() -> new AppException(ErrorCode.DR_NOT_FOUND.getCode(), "Daily report not found"));
        access.requireOwner(dr.getUser().getId());
        if (dr.getStatus() == DailyReport.Status.SUBMITTED) return toDto(dr);
        if (dr.getStatus() != DailyReport.Status.DRAFT && dr.getStatus() != DailyReport.Status.REQUEST_CHANGES)
            throw new IllegalArgumentException("Only a draft or requested revision can be submitted");
        updateAttendanceTotals(dr);
        dr.setStatus(DailyReport.Status.SUBMITTED);
        return toDto(dailyReportRepository.save(dr));
    }

    private void updateAttendanceTotals(DailyReport report) {
        var records = attendanceService.getHistory(report.getUser().getId(), report.getReportDate(), report.getReportDate());
        report.setAttendanceHours(records.stream().mapToLong(r -> r.getAttendanceDurationMinutes()).sum() / 60.0);
        report.setBreakHours(records.stream().mapToLong(r -> r.getBreakDurationMinutes()).sum() / 60.0);
        report.setNetWorkingHours(records.stream().mapToLong(r -> r.getNetWorkingDurationMinutes()).sum() / 60.0);
        report.setOvertimeHours(records.stream().mapToLong(r -> r.getOvertimeDurationMinutes() == null ? 0 : r.getOvertimeDurationMinutes()).sum() / 60.0);
    }

    private DailyReportDTO toDto(DailyReport dr) {
        return DailyReportDTO.builder()
                .id(dr.getId()).userId(dr.getUser().getId()).reportDate(dr.getReportDate())
                .attendanceHours(dr.getAttendanceHours()).breakHours(dr.getBreakHours())
                .netWorkingHours(dr.getNetWorkingHours()).overtimeHours(dr.getOvertimeHours())
                .completedWork(dr.getCompletedWork()).inProgressWork(dr.getInProgressWork())
                .pendingWork(dr.getPendingWork()).blockersChallenges(dr.getBlockersChallenges())
                .tomorrowPlans(dr.getTomorrowPlans()).status(dr.getStatus())
                .managerFeedback(dr.getManagerFeedback())
                .reviewedBy(dr.getReviewedBy() != null ? dr.getReviewedBy().getId() : null)
                .reviewedAt(dr.getReviewedAt()).revisionNumber(dr.getRevisionNumber()).build();
    }
}
