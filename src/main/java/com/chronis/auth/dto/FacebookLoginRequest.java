package com.chronis.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class FacebookLoginRequest {
    @NotBlank
    @Size(max = 8192)
    private String accessToken;
}
