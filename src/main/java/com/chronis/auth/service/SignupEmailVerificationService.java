package com.chronis.auth.service;

import com.chronis.auth.domain.SignupEmailVerification;
import com.chronis.auth.dto.*;
import com.chronis.auth.repository.*;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.Instant;
import java.util.*;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class SignupEmailVerificationService {
    private final SignupEmailVerificationRepository verifications;
    private final UserRepository users;
    private final EmailVerificationMailService mail;
    private final PasswordEncoder passwords;
    private final SecureRandom random = new SecureRandom();
    private final Map<String, SendWindow> ipWindows = new HashMap<>();
    private record SendWindow(Instant start, int count) {}

    public SignupEmailVerificationService(SignupEmailVerificationRepository verifications, UserRepository users,
            EmailVerificationMailService mail, PasswordEncoder passwords) {
        this.verifications = verifications;
        this.users = users;
        this.mail = mail;
        this.passwords = passwords;
    }

    @Transactional(noRollbackFor = ResponseStatusException.class)
    public SignupEmailChallengeResponse send(String email, String remoteAddress) {
        mail.requireAvailable();
        email = normalize(email);
        if (users.existsByEmail(email)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "An account with this email already exists. Sign in or request a new verification code.");
        }
        Instant now = Instant.now();
        limitIp(remoteAddress, now);
        verifications.createIfMissing(UUID.randomUUID(), email, now);
        SignupEmailVerification record = verifications.findByEmail(email).orElseThrow();
        if (record.getSentAt() != null && record.getSentAt().plusSeconds(60).isAfter(now)) {
            throw limited("Wait 60 seconds before requesting another email code.");
        }
        if (record.getWindowStartedAt().plusSeconds(3600).isBefore(now)) {
            record.setWindowStartedAt(now);
            record.setSendCount(0);
        }
        if (record.getSendCount() >= 5) throw limited("Too many email requests. Please try again in an hour.");
        String code = String.format(Locale.ROOT, "%06d", random.nextInt(1_000_000));
        record.setSendCount(record.getSendCount() + 1);
        record.setSentAt(now);
        verifications.saveAndFlush(record);
        mail.sendCode(email, code);
        record.setCodeHash(passwords.encode(code));
        record.setCodeExpiresAt(now.plusSeconds(600));
        record.setConsumed(false);
        record.setAttempts(0);
        record.setVerifiedAt(null);
        record.setTokenHash(null);
        record.setProofExpiresAt(null);
        verifications.save(record);
        return new SignupEmailChallengeResponse(record.getId(), 60, 600);
    }

    @Transactional(noRollbackFor = ResponseStatusException.class)
    public SignupEmailProofResponse verify(SignupEmailCodeRequest request) {
        SignupEmailVerification record = verifications.findForUpdate(request.challengeId()).orElse(null);
        if (record == null || !record.getEmail().equals(normalize(request.email())) || record.isConsumed()
                || record.getCodeHash() == null || record.getCodeExpiresAt() == null
                || !record.getCodeExpiresAt().isAfter(Instant.now()) || record.getAttempts() >= 5) throw invalidCode();
        record.setAttempts(record.getAttempts() + 1);
        verifications.save(record);
        if (!passwords.matches(request.code(), record.getCodeHash())) throw invalidCode();
        byte[] bytes = new byte[32];
        random.nextBytes(bytes);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        record.setVerifiedAt(Instant.now());
        record.setTokenHash(AuthService.hashResetToken(token));
        record.setProofExpiresAt(Instant.now().plusSeconds(600));
        record.setCodeHash(null);
        verifications.save(record);
        return new SignupEmailProofResponse(record.getId(), token, 600);
    }

    @Transactional
    public void consume(UUID id, String email, String token) {
        SignupEmailVerification record = id == null ? null : verifications.findForUpdate(id).orElse(null);
        if (record == null || record.isConsumed() || record.getVerifiedAt() == null
                || !record.getEmail().equals(normalize(email)) || record.getProofExpiresAt() == null
                || !record.getProofExpiresAt().isAfter(Instant.now()) || record.getTokenHash() == null || token == null
                || !MessageDigest.isEqual(record.getTokenHash().getBytes(StandardCharsets.US_ASCII),
                        AuthService.hashResetToken(token).getBytes(StandardCharsets.US_ASCII))) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Verify your email address before creating an account.");
        }
        record.setConsumed(true);
        record.setTokenHash(null);
        verifications.save(record);
    }

    private synchronized void limitIp(String ip, Instant now) {
        ipWindows.entrySet().removeIf(e -> e.getValue().start().plusSeconds(3600).isBefore(now));
        SendWindow window = ipWindows.get(ip);
        if ((ipWindows.size() >= 10000 && window == null) || (window != null && window.count() >= 20)) {
            throw limited("Too many email requests. Please try again later.");
        }
        ipWindows.put(ip, new SendWindow(window == null ? now : window.start(), window == null ? 1 : window.count() + 1));
    }

    private String normalize(String email) { return email.trim().toLowerCase(Locale.ROOT); }
    private ResponseStatusException limited(String message) {
        return new ResponseStatusException(HttpStatus.TOO_MANY_REQUESTS, message);
    }
    private ResponseStatusException invalidCode() {
        return new ResponseStatusException(HttpStatus.BAD_REQUEST,
                "The email code is incorrect or expired. Check the code or request a new one.");
    }
}
