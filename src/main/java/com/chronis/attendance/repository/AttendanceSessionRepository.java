package com.chronis.attendance.repository;

import com.chronis.attendance.domain.AttendanceSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface AttendanceSessionRepository extends JpaRepository<AttendanceSession, Long>,
        JpaSpecificationExecutor<AttendanceSession> {

    Optional<AttendanceSession> findByUserIdAndWorkDate(Long userId, LocalDate workDate);
    Optional<AttendanceSession> findFirstByUserIdAndCheckOutTimeIsNullAndCheckInTimeIsNotNullOrderByCheckInTimeDesc(Long userId);

    List<AttendanceSession> findByUserIdAndWorkDateBetween(Long userId, LocalDate start, LocalDate end);

    boolean existsByUserIdAndWorkDate(Long userId, LocalDate workDate);

    List<AttendanceSession> findByWorkDate(LocalDate workDate);
}
