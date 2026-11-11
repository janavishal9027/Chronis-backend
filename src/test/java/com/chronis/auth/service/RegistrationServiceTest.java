package com.chronis.auth.service;

import com.chronis.auth.domain.User;
import com.chronis.auth.dto.EmailVerificationRequest;
import com.chronis.auth.dto.SignupRequest;
import com.chronis.auth.repository.UserRepository;
import java.time.Instant;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class RegistrationServiceTest {
    private UserRepository users;
    private AccountProvisioningService accounts;
    private SignupEmailVerificationService emails;
    private RegistrationService service;

    @BeforeEach
    void setUp() {
        users = mock(UserRepository.class);
        accounts = mock(AccountProvisioningService.class);
        emails = mock(SignupEmailVerificationService.class);
        service = new RegistrationService(users, accounts, emails);
    }

    @Test
    void invalidEmailProofDoesNotCreateAccount() {
        doThrow(new ResponseStatusException(HttpStatus.BAD_REQUEST, "Verify email"))
                .when(emails).consume(any(), anyString(), anyString());
        assertThrows(ResponseStatusException.class, () -> service.signup(request()));
        verifyNoInteractions(accounts);
    }

    @Test
    void existingEmailCannotConsumeProofOrCreateAnotherAccount() {
        when(users.existsByEmail("person@example.test")).thenReturn(true);
        assertThrows(ResponseStatusException.class, () -> service.signup(request()));
        verifyNoInteractions(accounts, emails);
    }

    @Test
    void verifiedEmailSignupCreatesAnEnabledAccountWithoutPhoneOrAnotherOtp() {
        User user = new User();
        user.setEmail("person@example.test");
        user.setEmailVerified(false);
        user.setEnabled(false);
        when(accounts.createAccount(anyString(), eq(user.getEmail()), anyString(), eq(true), isNull()))
                .thenReturn(user);
        SignupRequest request = request();
        service.signup(request);
        verify(emails).consume(request.getEmailVerificationId(), user.getEmail(), request.getEmailVerificationToken());
        verify(accounts).createAccount("Test Person", user.getEmail(), "test-password-long", true, null);
    }

    @Test
    void invalidEmailOtpCountsAttemptsWithoutEnablingAccount() {
        User user = new User();
        user.setEmailVerified(false);
        user.setEnabled(false);
        user.setEmailVerificationCodeHash(AuthService.hashResetToken("123456"));
        user.setEmailVerificationCodeExpiry(Instant.now().plusSeconds(600));
        when(users.findByEmailForUpdate("person@example.test")).thenReturn(Optional.of(user));
        var request = new EmailVerificationRequest();
        request.setEmail("person@example.test");
        request.setCode("000000");
        for (int attempt = 0; attempt < 6; attempt++) assertFalse(service.verify(request));
        assertEquals(5, user.getEmailVerificationAttempts());
        assertFalse(user.isEnabled());
    }

    private SignupRequest request() {
        var request = new SignupRequest();
        request.setFullName("Test Person");
        request.setEmail("Person@example.test");
        request.setPassword("test-password-long");
        request.setEmailVerificationId(UUID.randomUUID());
        request.setEmailVerificationToken("test-proof");
        return request;
    }
}
