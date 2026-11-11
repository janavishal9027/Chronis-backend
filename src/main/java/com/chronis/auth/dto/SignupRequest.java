package com.chronis.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import jakarta.validation.constraints.NotNull;
import java.util.UUID;
import lombok.Data;
import lombok.ToString;

@Data
public class SignupRequest {
    @NotBlank
    @Size(max = 200)
    private String fullName;

    @NotBlank
    @Email
    @Size(max = 200)
    private String email;

    @NotBlank
    @Size(min = 10, max = 72, message = "Password must be between 10 and 72 characters")
    @ToString.Exclude
    private String password;

    @NotNull
    private UUID emailVerificationId;

    @NotBlank
    @Size(min = 43, max = 43)
    @ToString.Exclude
    private String emailVerificationToken;
}
