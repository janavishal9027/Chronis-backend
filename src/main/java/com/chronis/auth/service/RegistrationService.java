package com.chronis.auth.service;

import com.chronis.auth.domain.User;
import com.chronis.auth.dto.EmailVerificationRequest;
import com.chronis.auth.dto.SignupRequest;
import com.chronis.auth.repository.UserRepository;
import java.time.Instant;
import java.util.Locale;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
@Transactional(readOnly = true)
public class RegistrationService {
    private static final int MAX_ATTEMPTS = 5;
    private final UserRepository userRepository;
    private final AccountProvisioningService accounts;
    private final SignupEmailVerificationService emailVerifications;

    public RegistrationService(UserRepository userRepository, AccountProvisioningService accounts,
            SignupEmailVerificationService emailVerifications) {
        this.userRepository = userRepository;
        this.accounts = accounts;
        this.emailVerifications = emailVerifications;
    }

    @Transactional
    public void signup(SignupRequest request) {
        String email = normalize(request.getEmail());
        if (userRepository.existsByEmail(email)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "An account with this email already exists. Sign in or request a new verification code.");
        }
        emailVerifications.consume(request.getEmailVerificationId(), email, request.getEmailVerificationToken());
        String fullName = request.getFullName().trim().replaceAll("\\s+", " ");
        accounts.createAccount(fullName, email, request.getPassword(), true, null);
    }

    @Transactional
    public boolean verify(EmailVerificationRequest request) {
        User user = userRepository.findByEmailForUpdate(normalize(request.getEmail())).orElse(null);
        if (user == null || Boolean.TRUE.equals(user.getEmailVerified())
                || user.getEmailVerificationCodeHash() == null
                || user.getEmailVerificationCodeExpiry() == null
                || !user.getEmailVerificationCodeExpiry().isAfter(Instant.now())
                || user.getEmailVerificationAttempts() >= MAX_ATTEMPTS) {
            return false;
        }
        user.setEmailVerificationAttempts(user.getEmailVerificationAttempts() + 1);
        String submittedHash = AuthService.hashResetToken(request.getCode());
        if (!java.security.MessageDigest.isEqual(
                submittedHash.getBytes(java.nio.charset.StandardCharsets.US_ASCII),
                user.getEmailVerificationCodeHash().getBytes(java.nio.charset.StandardCharsets.US_ASCII))) {
            userRepository.save(user);
            return false;
        }
        user.setEmailVerified(true);
        user.setEnabled(true);
        clearCode(user);
        userRepository.save(user);
        return true;
    }

    private void clearCode(User user) {
        user.setEmailVerificationCodeHash(null);
        user.setEmailVerificationCodeExpiry(null);
        user.setEmailVerificationSentAt(null);
        user.setEmailVerificationAttempts(0);
    }

    private String normalize(String email) {
        return email.trim().toLowerCase(Locale.ROOT);
    }
}
