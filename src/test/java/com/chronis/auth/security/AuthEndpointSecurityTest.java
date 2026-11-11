package com.chronis.auth.security;

import com.chronis.auth.controller.AuthController;
import com.chronis.auth.repository.RefreshTokenRepository;
import com.chronis.auth.repository.UserRepository;
import com.chronis.auth.service.AuthService;
import com.chronis.auth.service.FacebookAuthenticationService;
import com.chronis.auth.service.GoogleAuthenticationService;
import com.chronis.auth.service.RegistrationService;
import com.chronis.auth.service.SignupEmailVerificationService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;

@WebMvcTest(AuthController.class)
@ContextConfiguration(classes = {AuthController.class, SecurityConfig.class, JwtAuthenticationFilter.class})
class AuthEndpointSecurityTest {
    @Autowired private MockMvc mvc;
    @MockBean private AuthService auth;
    @MockBean private RegistrationService registration;
    @MockBean private SignupEmailVerificationService emails;
    @MockBean private GoogleAuthenticationService googleAuthentication;
    @MockBean private FacebookAuthenticationService facebookAuthentication;
    @MockBean private UserRepository users;
    @MockBean private CustomUserDetailsService userDetails;
    @MockBean private JwtService jwt;
    @MockBean private RefreshTokenRepository sessions;

    @Test
    void logoutRequiresAnAuthenticatedSession() throws Exception {
        mvc.perform(post("/api/v1/auth/logout"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("success").value(false));
        verifyNoInteractions(auth);
    }

    @Test
    void passwordChangeRequiresAnAuthenticatedSession() throws Exception {
        mvc.perform(post("/api/v1/auth/change-password")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"currentPassword\":\"old-password\",\"newPassword\":\"new-password\",\"confirmNewPassword\":\"new-password\"}"))
                .andExpect(status().isUnauthorized());
        verifyNoInteractions(auth);
    }

    @Test
    void loginRemainsPublicWithoutCsrfForMobileClient() throws Exception {
        mvc.perform(post("/api/v1/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"username\":\"employee\",\"password\":\"password\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("success").value(true));
    }

    @Test
    void refreshRemainsPublicForExpiredAccessTokens() throws Exception {
        mvc.perform(post("/api/v1/auth/refresh")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"refreshToken\":\"opaque-refresh-token\"}"))
                .andExpect(status().isOk());
    }

    @Test
    void signupEmailCodeCanBeSentWithoutAnExistingLogin() throws Exception {
        mvc.perform(post("/api/v1/auth/signup/email/send-code")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"email\":\"person@example.test\"}"))
                .andExpect(status().isOk());
        verifyNoInteractions(registration);
        verify(emails).send(org.mockito.ArgumentMatchers.eq("person@example.test"), org.mockito.ArgumentMatchers.anyString());
    }

    @Test
    void removedLegacyResendEndpointHasNoMapping() throws Exception {
        mvc.perform(post("/api/v1/auth/resend-verification")
                .with(user("test-account"))
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"email\":\"person@example.test\"}"))
                .andExpect(status().isNotFound());
        verifyNoInteractions(registration, emails);
    }

    @Test
    void removedPhoneConfigurationIsNotPublic() throws Exception {
        mvc.perform(get("/api/v1/auth/phone/configuration"))
                .andExpect(status().isUnauthorized());
        verifyNoInteractions(registration);
    }

    @Test
    void removedPhoneSendEndpointCannotSendSms() throws Exception {
        mvc.perform(post("/api/v1/auth/phone/send-code")
                .contentType(MediaType.APPLICATION_JSON).content("{\"phoneNumber\":\"+919876543210\"}"))
                .andExpect(status().isUnauthorized());
        verifyNoInteractions(emails);
    }

    @Test
    void emailVerificationRequiresChallengeEmailAndSixDigitCode() throws Exception {
        mvc.perform(post("/api/v1/auth/signup/email/verify-code")
                .contentType(MediaType.APPLICATION_JSON).content("{\"code\":\"123456\"}"))
                .andExpect(status().isBadRequest());
        verifyNoInteractions(emails);
    }

    @Test
    void signupCannotOmitEmailVerificationProof() throws Exception {
        mvc.perform(post("/api/v1/auth/signup")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"fullName\":\"Test Person\",\"email\":\"person@example.test\",\"password\":\"valid-password\"}"))
                .andExpect(status().isBadRequest());
        verifyNoInteractions(registration);
    }
}
