package com.chronis.auth.service;

import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.mail.MailSendException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.web.server.ResponseStatusException;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class PasswordResetMailServiceTest {
    @Test
    void unconfiguredDeliveryFailsExplicitlyWithoutAttemptingMail() {
        JavaMailSender sender = mock(JavaMailSender.class);
        PasswordResetMailService service = new PasswordResetMailService(sender, false, "sender@example.test");
        ResponseStatusException failure = assertThrows(ResponseStatusException.class, service::requireAvailable);
        assertEquals(HttpStatus.SERVICE_UNAVAILABLE, failure.getStatusCode());
        verifyNoInteractions(sender);
    }

    @Test
    void mailFailureDoesNotReportAResetEmailWasSent() {
        JavaMailSender sender = mock(JavaMailSender.class);
        doThrow(new MailSendException("internal SMTP connection details"))
                .when(sender).send(any(SimpleMailMessage.class));
        PasswordResetMailService service = new PasswordResetMailService(sender, true, "sender@example.test");
        ResponseStatusException failure = assertThrows(ResponseStatusException.class,
                () -> service.send("employee@example.test", "reset-token"));
        assertEquals(HttpStatus.SERVICE_UNAVAILABLE, failure.getStatusCode());
        assertFalse(failure.getReason().contains("SMTP"));
    }
}
