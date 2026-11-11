package com.chronis.dailyreport.controller;

import com.chronis.common.dto.ApiResponse;
import com.chronis.dailyreport.dto.DailyReportDTO;
import com.chronis.dailyreport.dto.DailyReportRequest;
import com.chronis.dailyreport.service.DailyReportService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;


@RestController
@RequestMapping("/api/v1/daily-reports")
@RequiredArgsConstructor
@Tag(name = "DailyReport", description = "Daily work reports")
public class DailyReportController {

    private final DailyReportService dailyReportService;


    @GetMapping("/today")
    @Operation(summary = "Get today's daily report")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ApiResponse<DailyReportDTO>> today() {
        return ResponseEntity.ok(ApiResponse.success(dailyReportService.getToday()));
    }

    @PostMapping
    @Operation(summary = "Create daily report")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ApiResponse<DailyReportDTO>> create(@Valid @RequestBody DailyReportRequest request) {
        return ResponseEntity.ok(ApiResponse.success(dailyReportService.create(request)));
    }

    @PostMapping("/{id}/submit")
    @Operation(summary = "Submit daily report")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ApiResponse<DailyReportDTO>> submit(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(dailyReportService.submit(id)));
    }
}
