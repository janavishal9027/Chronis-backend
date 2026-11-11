package com.chronis.auth.service;

import com.chronis.auth.domain.RefreshToken;
import com.chronis.auth.domain.User;
import com.chronis.auth.dto.ChangePasswordRequest;
import com.chronis.auth.dto.ForgotPasswordRequest;
import com.chronis.auth.dto.LoginRequest;
import com.chronis.auth.dto.RefreshTokenRequest;
import com.chronis.auth.dto.ResetPasswordRequest;
import com.chronis.auth.repository.RefreshTokenRepository;
import com.chronis.auth.repository.UserRepository;
import com.chronis.auth.security.JwtService;
import com.chronis.common.exception.AppException;
import java.time.Instant;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.crypto.password.PasswordEncoder;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class AuthServiceTest {
    private UserRepository users;
    private RefreshTokenRepository sessions;
    private JwtService jwt;
    private PasswordEncoder encoder;
    private PasswordResetMailService mail;
    private AuthenticationManager authenticationManager;
    private AuthService service;
    private User user;

    @BeforeEach
    void setUp() {
        users = mock(UserRepository.class);
        sessions = mock(RefreshTokenRepository.class);
        jwt = mock(JwtService.class);
        encoder = mock(PasswordEncoder.class);
        mail = mock(PasswordResetMailService.class);
        authenticationManager = mock(AuthenticationManager.class);
        service = new AuthService(authenticationManager, users, sessions, jwt,
                encoder, mail);
        user = new User();
        user.setId(1L);
        user.setUsername("employee");
        user.setEmail("employee@example.test");
        user.setPassword("hashed-old-password");
    }

    @Test
    void refreshRejectsRevokedSession() {
        RefreshToken session = activeSession();
        session.setRevoked(true);
        when(sessions.findByToken("refresh")).thenReturn(Optional.of(session));
        assertThrows(BadCredentialsException.class,
                () -> service.refreshToken(new RefreshTokenRequest("refresh")));
        verifyNoInteractions(jwt);
    }

    @Test
    void refreshRejectsDisabledAccount() {
        user.setEnabled(false);
        when(sessions.findByToken("refresh")).thenReturn(Optional.of(activeSession()));
        when(users.findById(1L)).thenReturn(Optional.of(user));
        assertThrows(DisabledException.class,
                () -> service.refreshToken(new RefreshTokenRequest("refresh")));
        verifyNoInteractions(jwt);
    }

    @Test
    void sessionsStillRequireVerifiedEmail() {
        user.setEmailVerified(false);
        assertThrows(DisabledException.class, () -> service.createSession(user));
        verifyNoInteractions(jwt);
    }

    @Test
    void verifiedEmailCanCreateSession() {
        user.setEmailVerified(true);
        when(sessions.save(any(RefreshToken.class))).thenAnswer(invocation -> {
            RefreshToken saved = invocation.getArgument(0);
            saved.setId(7L);
            return saved;
        });
        when(jwt.generateRefreshToken(user)).thenReturn("refresh");
        when(jwt.generateAccessToken(user, 7L)).thenReturn("access");
        var response = service.createSession(user);
        assertEquals("access", response.getAccessToken());
        assertEquals("refresh", response.getRefreshToken());
    }

    @Test
    void verifiedEmailCanRefreshSession() {
        user.setEmailVerified(true);
        when(sessions.findByToken("refresh")).thenReturn(Optional.of(activeSession()));
        when(users.findById(1L)).thenReturn(Optional.of(user));
        when(jwt.generateRefreshToken(user)).thenReturn("next-refresh");
        when(jwt.generateAccessToken(user, 7L)).thenReturn("next-access");
        var response = service.refreshToken(new RefreshTokenRequest("refresh"));
        assertEquals("next-access", response.getAccessToken());
        assertEquals("next-refresh", response.getRefreshToken());
    }

    @Test
    void verifiedEmailCanLogInWithPassword() {
        user.setEmailVerified(true);
        when(users.findByEmail(user.getEmail())).thenReturn(Optional.of(user));
        when(users.findByUsername("employee")).thenReturn(Optional.of(user));
        var authenticated = mock(org.springframework.security.core.Authentication.class);
        when(authenticated.getName()).thenReturn("employee");
        when(authenticationManager.authenticate(any())).thenReturn(authenticated);
        when(sessions.save(any(RefreshToken.class))).thenAnswer(invocation -> {
            RefreshToken saved = invocation.getArgument(0);
            saved.setId(7L);
            return saved;
        });
        when(jwt.generateRefreshToken(user)).thenReturn("refresh");
        when(jwt.generateAccessToken(user, 7L)).thenReturn("access");
        var response = service.login(new LoginRequest(user.getEmail(), "example-password"));
        assertEquals("access", response.getAccessToken());
    }

    @Test
    void unknownResetEmailHasSameSuccessfulOutcomeWithoutSendingMail() {
        when(users.findByEmail("unknown@example.test")).thenReturn(Optional.empty());
        assertDoesNotThrow(() -> service.forgotPassword(new ForgotPasswordRequest("unknown@example.test")));
        verify(mail, never()).send(anyString(), anyString());
    }

    @Test
    void resetStoresOnlyDigestAndDeliversOriginalTokenByEmail() {
        when(users.findByEmail(user.getEmail())).thenReturn(Optional.of(user));
        service.forgotPassword(new ForgotPasswordRequest(user.getEmail()));
        ArgumentCaptor<String> token = ArgumentCaptor.forClass(String.class);
        verify(mail).send(eq(user.getEmail()), token.capture());
        assertNotEquals(token.getValue(), user.getPasswordResetToken());
        assertEquals(AuthService.hashResetToken(token.getValue()), user.getPasswordResetToken());
        assertTrue(user.getPasswordResetTokenExpiry().isAfter(Instant.now()));
    }

    @Test
    void expiredResetCannotChangePassword() {
        when(users.findByPasswordResetToken(AuthService.hashResetToken("code"))).thenReturn(Optional.of(user));
        user.setPasswordResetTokenExpiry(Instant.now().minusSeconds(1));
        assertThrows(AppException.class,
                () -> service.resetPassword(new ResetPasswordRequest("code", "new-password", "new-password")));
        verifyNoInteractions(encoder);
        verify(sessions, never()).revokeAllByUserId(anyLong());
    }

    @Test
    void passwordChangeClearsOutstandingResetAndRevokesAllSessions() {
        when(users.findById(1L)).thenReturn(Optional.of(user));
        when(encoder.matches("old-password", user.getPassword())).thenReturn(true);
        when(encoder.encode("new-password")).thenReturn("hashed-new-password");
        user.setPasswordResetToken("outstanding-token");
        user.setPasswordResetTokenExpiry(Instant.now().plusSeconds(100));
        service.changePassword(1L, new ChangePasswordRequest("old-password", "new-password", "new-password"));
        assertNull(user.getPasswordResetToken());
        assertNull(user.getPasswordResetTokenExpiry());
        assertEquals("hashed-new-password", user.getPassword());
        verify(sessions).revokeAllByUserId(1L);
    }

    private RefreshToken activeSession() {
        RefreshToken token = new RefreshToken();
        token.setId(7L);
        token.setUserId(1L);
        token.setToken("refresh");
        token.setExpiryDate(Instant.now().plusSeconds(300));
        return token;
    }
}
