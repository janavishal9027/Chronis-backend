package com.chronis.breakmanagement.dto;

import com.chronis.breakmanagement.domain.BreakSession;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BreakStartRequest {
    private BreakSession.Type breakType;
    @NotBlank
    private String reason;
}
