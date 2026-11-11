package com.chronis.task.controller;

import com.chronis.common.dto.ApiResponse;
import com.chronis.task.dto.TaskDTO;
import com.chronis.task.domain.Task;
import com.chronis.task.service.TaskService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/tasks")
@RequiredArgsConstructor
@Tag(name = "Task", description = "Task management")
public class TaskController {

    private final TaskService taskService;



    @GetMapping("/my-tasks")
    @Operation(summary = "Get my tasks")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ApiResponse<List<TaskDTO>>> myTasks() {
        return ResponseEntity.ok(ApiResponse.success(taskService.getByAssignee(null)));
    }


    @PatchMapping("/{id}/status")
    @Operation(summary = "Update task status")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ApiResponse<TaskDTO>> updateStatus(@PathVariable Long id,
                                                             @RequestParam Task.Status status) {
        return ResponseEntity.ok(ApiResponse.success(taskService.updateStatus(id, status)));
    }
}
