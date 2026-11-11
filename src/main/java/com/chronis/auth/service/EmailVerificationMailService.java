package com.chronis.auth.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.mail.MailException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class EmailVerificationMailService {
    private final JavaMailSender mailSender;
    private final boolean enabled;
    private final String from;

    public EmailVerificationMailService(
            JavaMailSender mailSender,
            @Value("${app.security.email-verification.enabled:false}") boolean enabled,
            @Value("${app.security.email-verification.from:no-reply@chronis.local}") String from) {
        this.mailSender = mailSender;
        this.enabled = enabled;
        this.from = from;
    }

    public void requireAvailable() {
        if (!enabled) {
            throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE,
                    "Email verification is not configured. Configure SMTP to create an account.");
        }
    }

    public void sendCode(String email, String code) {
        requireAvailable();
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(from);
        message.setTo(email);
        message.setSubject("Verify your Chronis email");
        message.setText("Your Chronis verification code is " + code
                + ". It expires in 10 minutes. If you did not request this, ignore this email.");
        try {
            mailSender.send(message);
        } catch (MailException ex) {
            throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE,
                    "Email delivery is temporarily unavailable. Try again later.");
        }
    }
}
