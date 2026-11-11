package com.chronis.auth.dto;

import java.util.UUID;

public record SignupEmailProofResponse(UUID verificationId, String verificationToken, long expiresInSeconds) {
    @Override public String toString() { return "SignupEmailProofResponse[verificationToken=REDACTED]"; }
}
