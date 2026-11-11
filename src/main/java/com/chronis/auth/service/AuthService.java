package com.chronis.auth.service;

import com.chronis.auth.domain.RefreshToken;
import com.chronis.auth.domain.User;
import com.chronis.auth.dto.ChangePasswordRequest;
import com.chronis.auth.dto.ForgotPasswordRequest;
import com.chronis.auth.dto.LoginRequest;
import com.chronis.auth.dto.LoginResponse;
import com.chronis.auth.dto.RefreshTokenRequest;
import com.chronis.auth.dto.RefreshTokenResponse;
import com.chronis.auth.dto.ResetPasswordRequest;
import com.chronis.auth.repository.RefreshTokenRepository;
import com.chronis.auth.repository.UserRepository;
import com.chronis.auth.security.JwtService;
import com.chronis.common.exception.AppException;
import com.chronis.common.exception.ErrorCode;
import java.time.Instant;
import java.util.Locale;
import java.util.UUID;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;
    private final PasswordResetMailService passwordResetMailService;

    @Transactional
    public LoginResponse login(LoginRequest request) {
        String identifier = request.getUsername().trim();
        User emailUser = userRepository.findByEmail(identifier.toLowerCase(Locale.ROOT)).orElse(null);
        if (emailUser != null && !Boolean.TRUE.equals(emailUser.getEmailVerified())) {
            throw new DisabledException("Verify your email address before signing in.");
        }
        String authenticationIdentifier = emailUser == null ? identifier : emailUser.getUsername();
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(authenticationIdentifier, request.getPassword()));
        String username = authentication.getName();
        User user = userRepository.findByUsername(username)
                .or(() -> userRepository.findByEmail(username))
                .orElseThrow(() -> new AppException(ErrorCode.AUTH_USER_NOT_FOUND.getCode(), "User not found"));

        requireActive(user);

        return createSession(user);
    }

    @Transactional
    public LoginResponse createSession(User user) {
        requireActive(user);
        String refreshToken = jwtService.generateRefreshToken(user);
        RefreshToken refreshTokenEntity = new RefreshToken();
        refreshTokenEntity.setUserId(user.getId());
        refreshTokenEntity.setToken(refreshToken);
        refreshTokenEntity.setExpiryDate(
                Instant.now().plusMillis(jwtService.getRefreshTokenExpirationMillis()));
        refreshTokenEntity = refreshTokenRepository.save(refreshTokenEntity);
        String accessToken = jwtService.generateAccessToken(user, refreshTokenEntity.getId());

        LoginResponse response = LoginResponse.from(user, accessToken, refreshToken);
        return response;
    }

    @Transactional
    public RefreshTokenResponse refreshToken(RefreshTokenRequest request) {
        RefreshToken stored = refreshTokenRepository.findByToken(request.getRefreshToken())
                .orElseThrow(() -> new BadCredentialsException("Invalid refresh token"));

        if (Boolean.TRUE.equals(stored.getRevoked()) || !stored.getExpiryDate().isAfter(Instant.now())) {
            throw new BadCredentialsException("Refresh token expired or revoked");
        }

        User user = userRepository.findById(stored.getUserId())
                .orElseThrow(() -> new AppException(ErrorCode.AUTH_USER_NOT_FOUND.getCode(),
                        "User not found"));

        requireActive(user);
        String newAccessToken = jwtService.generateAccessToken(user, stored.getId());
        String newRefreshToken = jwtService.generateRefreshToken(user);

        stored.setToken(newRefreshToken);
        stored.setExpiryDate(Instant.now().plusMillis(
                jwtService.getRefreshTokenExpirationMillis()));
        refreshTokenRepository.save(stored);

        return RefreshTokenResponse.builder()
                .accessToken(newAccessToken)
                .refreshToken(newRefreshToken)
                .build();
    }

    @Transactional
    public void logout(String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new AppException(ErrorCode.AUTH_USER_NOT_FOUND.getCode(),
                        "User not found"));
        refreshTokenRepository.revokeAllByUserId(user.getId());
    }

    @Transactional
    public void forgotPassword(ForgotPasswordRequest request) {
        passwordResetMailService.requireAvailable();
        User user = userRepository.findByEmail(request.getEmail()).orElse(null);
        // Do not disclose whether an email belongs to an account.
        if (user == null || !user.isEnabled()) {
            return;
        }

        String token = UUID.randomUUID().toString() + UUID.randomUUID();
        user.setPasswordResetToken(hashResetToken(token));
        user.setPasswordResetTokenExpiry(Instant.now().plusSeconds(30 * 60));
        userRepository.save(user);

        passwordResetMailService.send(user.getEmail(), token);
    }

    @Transactional
    public void resetPassword(ResetPasswordRequest request) {
        if (!request.getPassword().equals(request.getConfirmPassword())) {
            throw new AppException(ErrorCode.AUTH_PASSWORD_MISMATCH.getCode(),
                    "Passwords do not match");
        }

        User user = userRepository.findByPasswordResetToken(hashResetToken(request.getToken()))
                .orElseThrow(() -> new AppException(ErrorCode.AUTH_TOKEN_INVALID.getCode(),
                        "Invalid or expired reset token"));

        if (user.getPasswordResetTokenExpiry() == null
                || !user.getPasswordResetTokenExpiry().isAfter(Instant.now())) {
            throw new AppException(ErrorCode.AUTH_TOKEN_EXPIRED.getCode(), "Reset token expired");
        }

        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setPasswordChangedAt(Instant.now());
        user.setPasswordResetToken(null);
        user.setPasswordResetTokenExpiry(null);
        userRepository.save(user);

        // Revoke all existing sessions
        refreshTokenRepository.revokeAllByUserId(user.getId());
    }

    @Transactional
    public void changePassword(Long userId, ChangePasswordRequest request) {
        if (!request.getNewPassword().equals(request.getConfirmNewPassword())) {
            throw new AppException(ErrorCode.AUTH_PASSWORD_MISMATCH.getCode(),
                    "New passwords do not match");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new AppException(ErrorCode.AUTH_USER_NOT_FOUND.getCode(),
                        "User not found"));

        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            throw new AppException(ErrorCode.AUTH_PASSWORD_MISMATCH.getCode(),
                    "Current password is incorrect");
        }

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        user.setPasswordChangedAt(Instant.now());
        user.setPasswordResetToken(null);
        user.setPasswordResetTokenExpiry(null);
        userRepository.save(user);

        refreshTokenRepository.revokeAllByUserId(user.getId());
    }

    private void requireActive(User user) {
        if (!Boolean.TRUE.equals(user.getEmailVerified())) {
            throw new DisabledException("Verify your email address before signing in.");
        }
        if (!user.isEnabled() || !user.isAccountNonExpired()
                || !user.isAccountNonLocked() || !user.isCredentialsNonExpired()) {
            throw new DisabledException("Account is unavailable");
        }
    }

    static String hashResetToken(String token) {
        try {
            return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256")
                    .digest(token.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException("SHA-256 is unavailable", ex);
        }
    }
}
