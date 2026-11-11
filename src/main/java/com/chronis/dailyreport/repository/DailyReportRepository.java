package com.chronis.dailyreport.repository;

import com.chronis.dailyreport.domain.DailyReport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface DailyReportRepository extends JpaRepository<DailyReport, Long>,
        JpaSpecificationExecutor<DailyReport> {

    Optional<DailyReport> findByUserIdAndReportDate(Long userId, LocalDate reportDate);

    List<DailyReport> findByUserIdOrderByReportDateDesc(Long userId);
}
