package com.chronis.attendance.service;

import com.chronis.attendance.domain.AttendanceSession;
import com.chronis.attendance.dto.AttendanceDTO;
import com.chronis.attendance.repository.AttendanceSessionRepository;
import com.chronis.breakmanagement.repository.BreakSessionRepository;
import com.chronis.common.exception.AppException;
import com.chronis.common.exception.ErrorCode;
import com.chronis.common.security.AccessScope;
import com.chronis.auth.domain.User;
import com.chronis.auth.repository.UserRepository;
import com.chronis.worksession.domain.WorkSession;
import com.chronis.worksession.repository.WorkSessionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.*;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AttendanceService {
    private final AttendanceSessionRepository attendanceRepository;
    private final UserRepository userRepository;
    private final WorkSessionRepository workSessionRepository;
    private final BreakSessionRepository breakSessionRepository;
    private final ScheduledMinutesService scheduledMinutes;
    private final AccessScope access;
    private final com.chronis.engineering.EngineeringPolicy studyPolicy;
    private final com.chronis.coaching.PracticeService practice;

    private LocalDate today(User user) {
        return LocalDate.now(ZoneId.of(user.getTimezone() == null ? "Asia/Kolkata" : user.getTimezone()));
    }

    private User lockedUser() {
        return userRepository.findLockedById(access.currentUser().getId()).orElseThrow();
    }

    @Transactional
    public AttendanceDTO checkIn() {
        return checkIn(null);
    }

    @Transactional
    public AttendanceDTO checkIn(String reason) {
        User user = lockedUser();
        LocalDate date = com.chronis.engineering.EngineeringPolicy.applies(studyPolicy.today()) ? studyPolicy.today() : today(user);
        studyPolicy.beforeLogin(user.getId(), date, reason);
        if (attendanceRepository.findFirstByUserIdAndCheckOutTimeIsNullAndCheckInTimeIsNotNullOrderByCheckInTimeDesc(user.getId()).isPresent()) {
            throw new AppException(ErrorCode.ATT_ALREADY_CHECKED_IN.getCode(), "End your active attendance session before starting another");
        }
        if (attendanceRepository.existsByUserIdAndWorkDate(user.getId(), date)) {
            throw new AppException(ErrorCode.ATT_ALREADY_CHECKED_IN.getCode(), "Already checked in today");
        }
        Instant now = studyPolicy.now();
        AttendanceSession session = new AttendanceSession();
        session.setUser(user);
        session.setWorkDate(date);
        session.setCheckInTime(now);
        session.setStatus(AttendanceSession.Status.PRESENT);
        if (com.chronis.engineering.EngineeringPolicy.applies(date)) {
            session.setScheduledDurationMinutes(360L);
            session.setIsLate(now.atZone(com.chronis.engineering.EngineeringPolicy.ZONE).toLocalTime().isAfter(LocalTime.of(9, 0)));
        }
        if (!com.chronis.engineering.EngineeringPolicy.applies(date)) {
            session.setScheduledDurationMinutes(scheduledMinutes.forDate(date));
        }
        session = attendanceRepository.save(session);
        WorkSession work = new WorkSession();
        work.setUser(user);
        work.setSessionStart(now);
        work.setStatus(WorkSession.Status.ACTIVE);
        workSessionRepository.save(work);
        return toDto(session);
    }

    @Transactional
    public AttendanceDTO checkOut() {
        return checkOut(null);
    }

    @Transactional
    public AttendanceDTO checkOut(String reason) {
        User user = lockedUser();
        AttendanceSession session = attendanceRepository.findFirstByUserIdAndCheckOutTimeIsNullAndCheckInTimeIsNotNullOrderByCheckInTimeDesc(user.getId())
                .orElseThrow(() -> new AppException(ErrorCode.ATT_NOT_CHECKED_IN.getCode(), "No active attendance session"));
        if (breakSessionRepository.findTopByAttendanceSessionIdAndEndTimeIsNullOrderByStartTimeDesc(session.getId()).isPresent()) {
            throw new AppException(ErrorCode.BREAK_ALREADY_ACTIVE.getCode(), "End your active break before checking out");
        }
        studyPolicy.beforeLogout(user.getId(), session.getWorkDate(), reason);
        practice.onLogout(user.getId(), session.getWorkDate());
        Instant now = studyPolicy.now();
        session.setCheckOutTime(now);
        AttendanceDTO totals = toDto(session);
        session.setAttendanceDurationMinutes(totals.getAttendanceDurationMinutes());
        session.setBreakDurationMinutes(totals.getBreakDurationMinutes());
        session.setNetWorkingDurationMinutes(totals.getNetWorkingDurationMinutes());
        session.setOvertimeDurationMinutes(totals.getOvertimeDurationMinutes());
        attendanceRepository.save(session);
        workSessionRepository.findByUserIdAndStatusOrderBySessionStartDesc(user.getId(), WorkSession.Status.ACTIVE)
                .ifPresent(work -> {
                    work.setSessionEnd(now);
                    work.setElapsedDurationMinutes(totals.getAttendanceDurationMinutes());
                    work.setProductiveDurationMinutes(totals.getNetWorkingDurationMinutes());
                    work.setStatus(WorkSession.Status.ENDED);
                    workSessionRepository.save(work);
                });
        return totals;
    }

    public AttendanceDTO getToday() {
        User user = access.currentUser();
        return attendanceRepository.findFirstByUserIdAndCheckOutTimeIsNullAndCheckInTimeIsNotNullOrderByCheckInTimeDesc(user.getId())
                .or(() -> attendanceRepository.findByUserIdAndWorkDate(user.getId(), today(user)))
                .map(this::toDto).orElse(null);
    }

    public List<AttendanceDTO> getHistory(Long userId, LocalDate start, LocalDate end) {
        Long scopedId = userId == null ? access.currentUser().getId() : userId;
        access.requireUser(scopedId);
        if (start == null || end == null || start.isAfter(end)) throw new IllegalArgumentException("Start date must be on or before end date");
        return attendanceRepository.findByUserIdAndWorkDateBetween(scopedId, start, end).stream()
                .sorted(java.util.Comparator.comparing(AttendanceSession::getWorkDate).reversed()).map(this::toDto).toList();
    }

    private AttendanceDTO toDto(AttendanceSession session) {
        Instant end = session.getCheckOutTime() == null ? studyPolicy.now() : session.getCheckOutTime();
        long attendance = session.getCheckInTime() == null ? 0 : Math.max(0, Duration.between(session.getCheckInTime(), end).toMinutes());
        long breakSeconds = breakSessionRepository.findByAttendanceSessionId(session.getId()).stream()
                .mapToLong(b -> Math.max(0, Duration.between(b.getStartTime(), b.getEndTime() == null ? end : b.getEndTime()).getSeconds())).sum();
        long breaks = Math.min(attendance, breakSeconds / 60);
        long working = attendance - breaks;
        Long overtime = session.getScheduledDurationMinutes() == null ? null : Math.max(0, working - session.getScheduledDurationMinutes());
        return AttendanceDTO.builder().id(session.getId()).userId(session.getUser().getId()).workDate(session.getWorkDate())
                .checkInTime(session.getCheckInTime()).checkOutTime(session.getCheckOutTime()).status(session.getStatus())
                .attendanceDurationMinutes(attendance).breakDurationMinutes(breaks).netWorkingDurationMinutes(working)
                .overtimeDurationMinutes(overtime).scheduledDurationMinutes(session.getScheduledDurationMinutes())
                .isLate(session.getIsLate()).earlyDeparture(session.getEarlyDeparture()).build();
    }
}
