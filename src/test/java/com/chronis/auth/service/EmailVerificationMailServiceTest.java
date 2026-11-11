package com.chronis.auth.service;

import org.junit.jupiter.api.Test;
import org.springframework.mail.MailSendException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.web.server.ResponseStatusException;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class EmailVerificationMailServiceTest {
    @Test
    void verificationCannotBeBypassedWhenEmailDeliveryIsDisabled() {
        var sender = mock(JavaMailSender.class);
        var service = new EmailVerificationMailService(sender, false, "sender@example.test");
        assertThrows(ResponseStatusException.class, () -> service.sendCode("person@example.test", "123456"));
        verifyNoInteractions(sender);
    }

    @Test
    void failedSmtpDeliveryDoesNotClaimSuccessOrExposeConnectionDetails() {
        var sender = mock(JavaMailSender.class);
        doThrow(new MailSendException("private SMTP credentials")).when(sender).send(any(SimpleMailMessage.class));
        var service = new EmailVerificationMailService(sender, true, "sender@example.test");
        var error = assertThrows(ResponseStatusException.class,
                () -> service.sendCode("person@example.test", "123456"));
        assertFalse(error.getReason().contains("credentials"));
    }
}
