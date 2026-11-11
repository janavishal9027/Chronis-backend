package com.chronis.auth.dto;

import java.util.UUID;

public record SignupEmailChallengeResponse(UUID challengeId, long resendAfterSeconds, long expiresInSeconds) {}
