package com.chronis.task.repository;

import com.chronis.task.domain.Task;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface TaskRepository extends JpaRepository<Task, Long>, JpaSpecificationExecutor<Task> {

    Optional<Task> findByTaskCode(String taskCode);

    List<Task> findByAssignedToId(Long userId);

    List<Task> findByProjectId(Long projectId);

    boolean existsByTaskCode(String taskCode);
}
