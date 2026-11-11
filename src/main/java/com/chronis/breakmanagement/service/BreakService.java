package com.chronis.breakmanagement.service;

import com.chronis.attendance.domain.AttendanceSession;
import com.chronis.attendance.repository.AttendanceSessionRepository;
import com.chronis.breakmanagement.domain.BreakSession;
import com.chronis.breakmanagement.dto.BreakDTO;
import com.chronis.breakmanagement.dto.BreakStartRequest;
import com.chronis.breakmanagement.repository.BreakSessionRepository;
import com.chronis.common.exception.AppException;
import com.chronis.common.exception.ErrorCode;
import com.chronis.common.security.AccessScope;
import com.chronis.auth.domain.User;
import com.chronis.auth.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.*;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class BreakService {
    private final BreakSessionRepository breaks;
    private final AttendanceSessionRepository attendance;
    private final UserRepository users;
    private final AccessScope access;

    private AttendanceSession activeSession() {
        User user = users.findLockedById(access.currentUser().getId()).orElseThrow();
        return attendance.findFirstByUserIdAndCheckOutTimeIsNullAndCheckInTimeIsNotNullOrderByCheckInTimeDesc(user.getId())
                .orElseThrow(() -> new AppException(ErrorCode.ATT_NOT_CHECKED_IN.getCode(), "An active attendance session is required"));
    }

    @Transactional
    public BreakDTO startBreak(BreakStartRequest request) {
        AttendanceSession session = activeSession();
        if (breaks.findTopByAttendanceSessionIdAndEndTimeIsNullOrderByStartTimeDesc(session.getId()).isPresent())
            throw new AppException(ErrorCode.BREAK_ALREADY_ACTIVE.getCode(), "A break is already active");
        BreakSession breakSession = new BreakSession();
        breakSession.setAttendanceSession(session);
        breakSession.setBreakType(request.getBreakType() == null ? BreakSession.Type.SHORT : request.getBreakType());
        breakSession.setStartTime(Instant.now());
        breakSession.setReason(request.getReason());
        return toDto(breaks.save(breakSession));
    }

    @Transactional
    public BreakDTO endBreak() {
        AttendanceSession session = activeSession();
        BreakSession active = breaks.findTopByAttendanceSessionIdAndEndTimeIsNullOrderByStartTimeDesc(session.getId())
                .orElseThrow(() -> new AppException(ErrorCode.BREAK_NOT_ACTIVE.getCode(), "No active break to end"));
        active.setEndTime(Instant.now());
        active.setDurationMinutes(Duration.between(active.getStartTime(), active.getEndTime()).toMinutes());
        return toDto(breaks.save(active));
    }

    public List<BreakDTO> getToday() {
        User user = access.currentUser();
        LocalDate date = LocalDate.now(ZoneId.of(user.getTimezone() == null ? "Asia/Kolkata" : user.getTimezone()));
        return attendance.findFirstByUserIdAndCheckOutTimeIsNullAndCheckInTimeIsNotNullOrderByCheckInTimeDesc(user.getId())
                .or(() -> attendance.findByUserIdAndWorkDate(user.getId(), date))
                .map(s -> breaks.findByAttendanceSessionId(s.getId()).stream().map(this::toDto).toList()).orElse(List.of());
    }

    private BreakDTO toDto(BreakSession b) {
        return BreakDTO.builder().id(b.getId()).attendanceSessionId(b.getAttendanceSession().getId()).breakType(b.getBreakType())
                .startTime(b.getStartTime()).endTime(b.getEndTime())
                .durationMinutes(Duration.between(b.getStartTime(), b.getEndTime() == null ? Instant.now() : b.getEndTime()).toMinutes())
                .reason(b.getReason()).build();
    }
}
