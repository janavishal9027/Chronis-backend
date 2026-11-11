package com.chronis.auth.controller;

import com.chronis.auth.dto.ChangePasswordRequest;
import com.chronis.auth.dto.ForgotPasswordRequest;
import com.chronis.auth.dto.FacebookLoginRequest;
import com.chronis.auth.dto.EmailRequest;
import com.chronis.auth.dto.EmailVerificationRequest;
import com.chronis.auth.dto.GoogleLoginRequest;
import com.chronis.auth.dto.LoginRequest;
import com.chronis.auth.dto.LoginResponse;
import com.chronis.auth.dto.RefreshTokenRequest;
import com.chronis.auth.dto.RefreshTokenResponse;
import com.chronis.auth.dto.ResetPasswordRequest;
import com.chronis.auth.dto.SignupRequest;
import com.chronis.auth.service.AuthService;
import com.chronis.auth.service.GoogleAuthenticationService;
import com.chronis.auth.service.FacebookAuthenticationService;
import com.chronis.auth.service.RegistrationService;
import com.chronis.auth.service.SignupEmailVerificationService;
import com.chronis.auth.dto.SignupEmailCodeRequest;
import com.chronis.auth.dto.SignupEmailChallengeResponse;
import com.chronis.auth.dto.SignupEmailProofResponse;
import com.chronis.common.dto.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "Login, refresh, logout, password reset")
public class AuthController {

    private final AuthService authService;
    private final com.chronis.auth.repository.UserRepository userRepository;
    private final RegistrationService registrationService;
    private final GoogleAuthenticationService googleAuthenticationService;
    private final FacebookAuthenticationService facebookAuthenticationService;
    private final SignupEmailVerificationService signupEmailVerificationService;

    @PostMapping("/signup/email/send-code")
    @Operation(summary = "Send an email OTP before creating an account")
    public ResponseEntity<ApiResponse<SignupEmailChallengeResponse>> sendSignupEmailCode(
            @Valid @RequestBody EmailRequest request, jakarta.servlet.http.HttpServletRequest servletRequest) {
        return ResponseEntity.ok(ApiResponse.success("Check your email for the verification code.",
                signupEmailVerificationService.send(request.getEmail(), servletRequest.getRemoteAddr())));
    }

    @PostMapping("/signup/email/verify-code")
    @Operation(summary = "Verify the signup email OTP and issue a single-use signup proof")
    public ResponseEntity<ApiResponse<SignupEmailProofResponse>> verifySignupEmailCode(
            @Valid @RequestBody SignupEmailCodeRequest request) {
        return ResponseEntity.ok(ApiResponse.success("Email verified.", signupEmailVerificationService.verify(request)));
    }

    @PostMapping("/signup")
    @Operation(summary = "Create an account with a previously verified email")
    public ResponseEntity<ApiResponse<Void>> signup(@Valid @RequestBody SignupRequest request) {
        registrationService.signup(request);
        return ResponseEntity.status(201).body(ApiResponse.success("Account created. You can now sign in.", null));
    }

    @PostMapping("/verify-email")
    @Operation(summary = "Verify an account email with the one-time code")
    public ResponseEntity<ApiResponse<Void>> verifyEmail(@Valid @RequestBody EmailVerificationRequest request) {
        if (!registrationService.verify(request)) {
            return ResponseEntity.badRequest().body(ApiResponse.error("The verification code is invalid or expired."));
        }
        return ResponseEntity.ok(ApiResponse.success("Email verified. You can now sign in.", null));
    }

    @PostMapping("/google")
    @Operation(summary = "Authenticate using a verified Google identity token")
    public ResponseEntity<ApiResponse<LoginResponse>> google(@Valid @RequestBody GoogleLoginRequest request) {
        return ResponseEntity.ok(ApiResponse.success("Sign-in successful", googleAuthenticationService.login(request)));
    }

    @PostMapping("/facebook")
    @Operation(summary = "Authenticate using a verified Facebook access token")
    public ResponseEntity<ApiResponse<LoginResponse>> facebook(@Valid @RequestBody FacebookLoginRequest request) {
        return ResponseEntity.ok(ApiResponse.success("Sign-in successful", facebookAuthenticationService.login(request)));
    }

    @PostMapping("/login")
    @Operation(summary = "Authenticate account and issue JWT tokens")
    public ResponseEntity<ApiResponse<LoginResponse>> login(@Valid @RequestBody LoginRequest request) {
        LoginResponse response = authService.login(request);
        return ResponseEntity.ok(ApiResponse.success("Login successful", response));
    }

    @PostMapping("/refresh")
    @Operation(summary = "Refresh access token using refresh token")
    public ResponseEntity<ApiResponse<RefreshTokenResponse>> refresh(
            @Valid @RequestBody RefreshTokenRequest request) {
        RefreshTokenResponse response = authService.refreshToken(request);
        return ResponseEntity.ok(ApiResponse.success("Token refreshed", response));
    }

    @PostMapping("/logout")
    @Operation(summary = "Logout and revoke refresh tokens")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<ApiResponse<Void>> logout(@AuthenticationPrincipal UserDetails userDetails) {
        authService.logout(userDetails.getUsername());
        return ResponseEntity.ok(ApiResponse.success("Logged out successfully", null));
    }

    @PostMapping("/forgot-password")
    @Operation(summary = "Initiate password reset flow")
    public ResponseEntity<ApiResponse<Void>> forgotPassword(
            @Valid @RequestBody ForgotPasswordRequest request) {
        authService.forgotPassword(request);
        return ResponseEntity.ok(ApiResponse.success("If the email exists, a reset link has been sent", null));
    }

    @PostMapping("/reset-password")
    @Operation(summary = "Reset password using reset token")
    public ResponseEntity<ApiResponse<Void>> resetPassword(
            @Valid @RequestBody ResetPasswordRequest request) {
        authService.resetPassword(request);
        return ResponseEntity.ok(ApiResponse.success("Password reset successfully", null));
    }

    @PostMapping("/change-password")
    @Operation(summary = "Change password for authenticated user")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<ApiResponse<Void>> changePassword(
            @AuthenticationPrincipal org.springframework.security.core.userdetails.UserDetails userDetails,
            @Valid @RequestBody ChangePasswordRequest request) {
        com.chronis.auth.domain.User user = userRepository.findByUsername(userDetails.getUsername())
                .or(() -> userRepository.findByEmail(userDetails.getUsername()))
                .orElseThrow(() -> new com.chronis.common.exception.AppException(
                        com.chronis.common.exception.ErrorCode.AUTH_USER_NOT_FOUND.getCode(),
                        "User not found"));
        authService.changePassword(user.getId(), request);
        return ResponseEntity.ok(ApiResponse.success("Password changed successfully", null));
    }
}
