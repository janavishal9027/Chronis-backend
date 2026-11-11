package com.chronis.workupdate.controller;

import com.chronis.common.dto.ApiResponse;
import com.chronis.workupdate.dto.WorkUpdateDTO;
import com.chronis.workupdate.dto.WorkUpdateRequest;
import com.chronis.workupdate.service.WorkUpdateService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/work-updates")
@RequiredArgsConstructor
@Tag(name = "WorkUpdate", description = "Daily work updates")
public class WorkUpdateController {

    private final WorkUpdateService workUpdateService;

    @GetMapping("/today")
    @Operation(summary = "Get today's work updates")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ApiResponse<List<WorkUpdateDTO>>> today() {
        return ResponseEntity.ok(ApiResponse.success(workUpdateService.getToday()));
    }

    @PostMapping
    @Operation(summary = "Create a work update")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ApiResponse<WorkUpdateDTO>> create(@Valid @RequestBody WorkUpdateRequest request) {
        return ResponseEntity.ok(ApiResponse.success(workUpdateService.create(request)));
    }
}
