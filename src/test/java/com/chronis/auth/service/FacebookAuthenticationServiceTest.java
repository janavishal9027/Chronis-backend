package com.chronis.auth.service;

import com.chronis.auth.domain.User;
import com.chronis.auth.dto.FacebookLoginRequest;
import com.chronis.auth.dto.LoginResponse;
import com.chronis.auth.repository.UserRepository;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.mock.env.MockEnvironment;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestClient;
import org.springframework.web.server.ResponseStatusException;

import static org.hamcrest.Matchers.startsWith;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.*;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

class FacebookAuthenticationServiceTest {
    private static final String VALID_TOKEN_DATA = """
            {"data":{"is_valid":true,"app_id":"facebook-app-test",
            "user_id":"facebook-person","expires_at":4102444800}}
            """;

    private UserRepository users;
    private AccountProvisioningService accounts;
    private AuthService auth;
    private FacebookAuthenticationService service;
    private MockRestServiceServer facebook;

    @BeforeEach
    void setUp() {
        users = mock(UserRepository.class);
        accounts = mock(AccountProvisioningService.class);
        auth = mock(AuthService.class);
        var environment = new MockEnvironment()
                .withProperty("app.security.facebook.app-id", "facebook-app-test")
                .withProperty("app.security.facebook.app-secret", "test-secret")
                .withProperty("app.security.facebook.graph-api-version", "v26.0");
        service = new FacebookAuthenticationService(users, accounts, auth, environment);
        var builder = RestClient.builder();
        facebook = MockRestServiceServer.bindTo(builder).build();
        ReflectionTestUtils.setField(service, "restClient", builder.build());
    }

    @Test
    void invalidFacebookTokenIsUnauthorizedRatherThanAResponseConversionFailure() {
        expectFacebook("debug_token", "{\"data\":{\"is_valid\":false}}");

        var error = assertThrows(ResponseStatusException.class, () -> service.login(request()));

        assertEquals(HttpStatus.UNAUTHORIZED, error.getStatusCode());
        verifyNoInteractions(users, accounts, auth);
        facebook.verify();
    }

    @Test
    void verifiedFacebookProfileCreatesAChronisSession() {
        expectFacebook("debug_token", VALID_TOKEN_DATA);
        expectFacebook("me", """
                {"id":"facebook-person","name":"Test Person","email":"person@example.test"}
                """);
        var user = new User();
        user.setEmail("person@example.test");
        user.setFacebookSubject("facebook-person");
        when(users.findByFacebookSubject("facebook-person")).thenReturn(Optional.of(user));
        var session = new LoginResponse();
        when(auth.createSession(user)).thenReturn(session);

        assertSame(session, service.login(request()));

        verify(auth).createSession(user);
        verifyNoInteractions(accounts);
        facebook.verify();
    }

    @Test
    void facebookProfileWithoutEmailCannotCreateAnAccountOrSession() {
        expectFacebook("debug_token", VALID_TOKEN_DATA);
        expectFacebook("me", "{\"id\":\"facebook-person\",\"name\":\"Test Person\"}");

        var error = assertThrows(ResponseStatusException.class, () -> service.login(request()));

        assertEquals(HttpStatus.BAD_REQUEST, error.getStatusCode());
        assertTrue(error.getReason().contains("email address"));
        verifyNoInteractions(users, accounts, auth);
        facebook.verify();
    }

    @Test
    void tokenIssuedToAnotherMetaAppCannotCreateASession() {
        expectFacebook("debug_token", VALID_TOKEN_DATA.replace("facebook-app-test", "another-app"));

        var error = assertThrows(ResponseStatusException.class, () -> service.login(request()));

        assertEquals(HttpStatus.UNAUTHORIZED, error.getStatusCode());
        verifyNoInteractions(users, accounts, auth);
        facebook.verify();
    }

    private void expectFacebook(String resource, String json) {
        facebook.expect(requestTo(startsWith("https://graph.facebook.com/v26.0/" + resource + "?")))
                .andExpect(method(HttpMethod.GET))
                .andRespond(request -> {
                    // Facebook labels its JSON as JavaScript unless JSON is explicitly requested.
                    var contentType = request.getHeaders().getAccept().contains(MediaType.APPLICATION_JSON)
                            ? MediaType.APPLICATION_JSON : MediaType.parseMediaType("text/javascript");
                    return withSuccess(json, contentType).createResponse(request);
                });
    }

    private FacebookLoginRequest request() {
        var request = new FacebookLoginRequest();
        request.setAccessToken("test-provider-access-token");
        return request;
    }
}
