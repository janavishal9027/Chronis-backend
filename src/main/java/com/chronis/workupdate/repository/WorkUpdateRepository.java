package com.chronis.workupdate.repository;

import com.chronis.workupdate.domain.WorkUpdate;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface WorkUpdateRepository extends JpaRepository<WorkUpdate, Long>,
        JpaSpecificationExecutor<WorkUpdate> {

    List<WorkUpdate> findByUserIdAndWorkDate(Long userId, LocalDate workDate);

    List<WorkUpdate> findByUserIdAndWorkDateBetween(Long userId, LocalDate start, LocalDate end);
}
