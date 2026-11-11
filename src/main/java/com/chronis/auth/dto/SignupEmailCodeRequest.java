package com.chronis.auth.dto;

import jakarta.validation.constraints.*;
import java.util.UUID;

public record SignupEmailCodeRequest(
        @NotNull UUID challengeId,
        @NotBlank @Email @Size(max = 200) String email,
        @NotBlank @Pattern(regexp = "[0-9]{6}") String code) {
    @Override public String toString() { return "SignupEmailCodeRequest[code=REDACTED]"; }
}
