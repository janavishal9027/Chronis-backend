package com.chronis.breakmanagement.repository;

import com.chronis.breakmanagement.domain.BreakSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface BreakSessionRepository extends JpaRepository<BreakSession, Long> {

    List<BreakSession> findByAttendanceSessionId(Long attendanceSessionId);

    Optional<BreakSession> findTopByAttendanceSessionIdAndEndTimeIsNullOrderByStartTimeDesc(Long attendanceSessionId);
}
