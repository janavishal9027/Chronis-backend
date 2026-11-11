package com.chronis.attendance.controller;

import com.chronis.attendance.dto.AttendanceDTO;
import com.chronis.attendance.service.AttendanceService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;


@RestController
@RequestMapping("/api/v1/attendance")
@RequiredArgsConstructor
@Tag(name = "Attendance", description = "Check-in/check-out and attendance tracking")
public class AttendanceController {

    public record AttendanceAction(@jakarta.validation.constraints.Size(max=1000) String reason) {}

    private final AttendanceService attendanceService;

    @PostMapping("/check-in")
    @Operation(summary = "Check in / start workday")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<AttendanceDTO> checkIn(@jakarta.validation.Valid @RequestBody(required=false) AttendanceAction body) {
        return ResponseEntity.ok(attendanceService.checkIn(body == null ? null : body.reason()));
    }

    @PostMapping("/check-out")
    @Operation(summary = "Check out / end workday")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<AttendanceDTO> checkOut(@jakarta.validation.Valid @RequestBody(required=false) AttendanceAction body) {
        return ResponseEntity.ok(attendanceService.checkOut(body == null ? null : body.reason()));
    }

    @GetMapping("/today")
    @Operation(summary = "Get today's attendance")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<AttendanceDTO> today() {
        return ResponseEntity.ok(attendanceService.getToday());
    }

}
