package com.chronis.auth.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.mail.MailException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class PasswordResetMailService {
    private final JavaMailSender mailSender;
    private final boolean enabled;
    private final String from;

    public PasswordResetMailService(JavaMailSender mailSender,
            @Value("${app.security.password-reset.enabled:false}") boolean enabled,
            @Value("${app.security.password-reset.from:no-reply@chronis.local}") String from) {
        this.mailSender = mailSender;
        this.enabled = enabled;
        this.from = from;
    }

    public void requireAvailable() {
        if (!enabled) {
            throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE,
                    "Password recovery is unavailable. Contact your administrator.");
        }
    }

    public void send(String email, String token) {
        requireAvailable();
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(from);
        message.setTo(email);
        message.setSubject("Reset your Chronis password");
        message.setText("Use this code in the Chronis Reset Password screen within 30 minutes:\n\n"
                + token + "\n\nIf you did not request this, ignore this email.");
        try {
            mailSender.send(message);
        } catch (MailException ex) {
            throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE,
                    "Password recovery is temporarily unavailable. Try again later.");
        }
    }
}
