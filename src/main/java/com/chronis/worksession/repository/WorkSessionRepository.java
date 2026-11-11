package com.chronis.worksession.repository;

import com.chronis.worksession.domain.WorkSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface WorkSessionRepository extends JpaRepository<WorkSession, Long> {

    Optional<WorkSession> findByUserIdAndStatusOrderBySessionStartDesc(Long userId,
                                                                          com.chronis.worksession.domain.WorkSession.Status status);

    List<WorkSession> findByUserId(Long userId);
}
