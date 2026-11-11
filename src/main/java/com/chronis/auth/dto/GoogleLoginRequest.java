package com.chronis.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;
import lombok.ToString;

@Data
@ToString(onlyExplicitlyIncluded = true)
public class GoogleLoginRequest {
    @NotBlank
    @Size(max = 8192)
    private String idToken;
}
