package com.chronis.auth.security;

import com.chronis.auth.domain.RefreshToken;
import com.chronis.auth.domain.User;
import com.chronis.auth.repository.RefreshTokenRepository;
import java.time.Instant;
import java.util.Optional;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.security.core.context.SecurityContextHolder;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class JwtAuthenticationFilterTest {
    private static final String SECRET = "test-only-secret-with-at-least-32-characters";
    private JwtService jwt;
    private JwtAuthenticationFilter filter;
    private CustomUserDetailsService users;
    private RefreshTokenRepository sessions;
    private User user;
    private RefreshToken session;

    @BeforeEach
    void setUp() {
        jwt = new JwtService(SECRET, 60_000, 300_000);
        users = mock(CustomUserDetailsService.class);
        sessions = mock(RefreshTokenRepository.class);
        filter = new JwtAuthenticationFilter(jwt, users, sessions);
        user = new User();
        user.setId(1L);
        user.setUsername("employee");
        user.setEmail("employee@example.test");
        session = new RefreshToken();
        session.setId(7L);
        session.setUserId(user.getId());
        session.setExpiryDate(Instant.now().plusSeconds(300));
        when(users.loadUserEntity("employee")).thenReturn(user);
        when(sessions.findById(7L)).thenReturn(Optional.of(session));
    }

    @AfterEach
    void clearSecurityContext() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void authenticatesAccessTokenForActiveSession() throws Exception {
        runFilter(jwt.generateAccessToken(user, 7L));
        assertSame(user, SecurityContextHolder.getContext().getAuthentication().getPrincipal());
    }

    @Test
    void rejectsRefreshTokenAsBearerCredential() throws Exception {
        runFilter(jwt.generateRefreshToken(user));
        assertNull(SecurityContextHolder.getContext().getAuthentication());
        verify(sessions, never()).findById(anyLong());
    }

    @Test
    void logoutRevocationImmediatelyInvalidatesExistingAccessToken() throws Exception {
        String token = jwt.generateAccessToken(user, 7L);
        session.setRevoked(true);
        runFilter(token);
        assertNull(SecurityContextHolder.getContext().getAuthentication());
    }

    @Test
    void disabledUserCannotUseAnOtherwiseValidToken() throws Exception {
        String token = jwt.generateAccessToken(user, 7L);
        user.setEnabled(false);
        runFilter(token);
        assertNull(SecurityContextHolder.getContext().getAuthentication());
    }

    @Test
    void sessionCannotAuthenticateADifferentUser() throws Exception {
        session.setUserId(2L);
        runFilter(jwt.generateAccessToken(user, 7L));
        assertNull(SecurityContextHolder.getContext().getAuthentication());
    }

    @Test
    void malformedTokenDoesNotThrowOrAuthenticate() throws Exception {
        runFilter("not-a-jwt");
        assertNull(SecurityContextHolder.getContext().getAuthentication());
    }

    @Test
    void expiredTokenDoesNotThrowOrAuthenticate() throws Exception {
        JwtService expired = new JwtService(SECRET, -60_000, 300_000);
        runFilter(expired.generateAccessToken(user, 7L));
        assertNull(SecurityContextHolder.getContext().getAuthentication());
    }

    @Test
    void tokenRotationProducesDistinctRefreshTokens() {
        assertNotEquals(jwt.generateRefreshToken(user), jwt.generateRefreshToken(user));
    }

    private void runFilter(String token) throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/v1/employees/me");
        request.addHeader("Authorization", "Bearer " + token);
        boolean[] called = {false};
        filter.doFilter(request, new MockHttpServletResponse(), (req, res) -> called[0] = true);
        assertTrue(called[0], "Invalid tokens must continue to the security entry point");
    }
}
