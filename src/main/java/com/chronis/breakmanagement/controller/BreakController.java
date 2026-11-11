package com.chronis.breakmanagement.controller;

import com.chronis.breakmanagement.dto.BreakDTO;
import com.chronis.breakmanagement.dto.BreakStartRequest;
import com.chronis.breakmanagement.service.BreakService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/breaks")
@RequiredArgsConstructor
@Tag(name = "Breaks", description = "Break start/end tracking")
public class BreakController {

    private final BreakService breakService;

    @PostMapping("/start")
    @Operation(summary = "Start a break")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<BreakDTO> startBreak(@Valid @RequestBody BreakStartRequest request) {
        return ResponseEntity.ok(breakService.startBreak(request));
    }

    @PostMapping("/end")
    @Operation(summary = "End the active break")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<BreakDTO> endBreak() {
        return ResponseEntity.ok(breakService.endBreak());
    }

    @GetMapping("/today")
    @Operation(summary = "Get today's breaks")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<BreakDTO>> today() {
        return ResponseEntity.ok(breakService.getToday());
    }
}
