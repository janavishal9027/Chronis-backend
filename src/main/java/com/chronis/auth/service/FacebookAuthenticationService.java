package com.chronis.auth.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.chronis.auth.domain.User;
import com.chronis.auth.dto.FacebookLoginRequest;
import com.chronis.auth.dto.LoginResponse;
import com.chronis.auth.repository.UserRepository;
import java.time.Instant;
import java.util.Locale;
import org.springframework.core.env.Environment;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientResponseException;
import org.springframework.web.client.RestClientException;
import org.springframework.web.server.ResponseStatusException;

@Service
@Transactional(readOnly = true)
public class FacebookAuthenticationService {
    private static final String GRAPH_ROOT = "https://graph.facebook.com/";

    private final UserRepository userRepository;
    private final AccountProvisioningService accounts;
    private final AuthService authService;
    private final RestClient restClient = RestClient.create();
    private final String appId;
    private final String appSecret;
    private final String graphApiVersion;

    public FacebookAuthenticationService(UserRepository userRepository,
            AccountProvisioningService accounts, AuthService authService, Environment environment) {
        this.userRepository = userRepository;
        this.accounts = accounts;
        this.authService = authService;
        this.appId = environment.getProperty("app.security.facebook.app-id", "").trim();
        this.appSecret = environment.getProperty("app.security.facebook.app-secret", "").trim();
        this.graphApiVersion = environment.getProperty("app.security.facebook.graph-api-version", "v26.0").trim();
    }

    @Transactional
    public LoginResponse login(FacebookLoginRequest request) {
        if (appId.isEmpty() || appSecret.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE,
                    "Facebook sign-in is not configured. Add the Facebook app credentials to the backend configuration.");
        }

        String accessToken = request.getAccessToken().trim();
        JsonNode tokenData = loadTokenData(accessToken);
        String subject = tokenData.path("user_id").asText("");
        long expiresAt = tokenData.path("expires_at").asLong(0);
        if (!tokenData.path("is_valid").asBoolean()
                || !appId.equals(tokenData.path("app_id").asText())
                || subject.isBlank()
                || (expiresAt > 0 && expiresAt <= Instant.now().getEpochSecond())) {
            throw unauthorized();
        }

        JsonNode profile = loadProfile(accessToken);
        String profileId = profile.path("id").asText("");
        String email = profile.path("email").asText("").trim().toLowerCase(Locale.ROOT);
        String fullName = profile.path("name").asText("").trim();
        if (!subject.equals(profileId) || email.isBlank() || !email.contains("@")) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Facebook did not provide an email address. Use email sign-up or another sign-in option.");
        }
        if (fullName.isBlank()) fullName = email.substring(0, email.indexOf('@'));

        User user = userRepository.findByFacebookSubject(subject).orElse(null);
        if (user == null) {
            user = userRepository.findByEmail(email).orElse(null);
            if (user != null && !Boolean.TRUE.equals(user.getEmailVerified())) {
                throw new ResponseStatusException(HttpStatus.CONFLICT,
                        "Verify this email address before linking it to Facebook.");
            }
            if (user != null && user.getFacebookSubject() != null
                    && !subject.equals(user.getFacebookSubject())) {
                throw new ResponseStatusException(HttpStatus.CONFLICT,
                        "This email is already linked to a different Facebook account.");
            }
            if (user == null) {
                user = accounts.createAccount(fullName, email, accounts.randomPassword(), true, null);
                user.setFacebookSubject(subject);
            } else {
                user.setFacebookSubject(subject);
                user.setEmailVerified(true);
                user.setEnabled(true);
            }
            user = userRepository.save(user);
        } else if (!email.equalsIgnoreCase(user.getEmail())) {
            throw unauthorized();
        }

        return authService.createSession(user);
    }

    private JsonNode loadTokenData(String token) {
        String appAccessToken = appId + "|" + appSecret;
        JsonNode response = getGraph(
                GRAPH_ROOT + graphApiVersion
                        + "/debug_token?input_token={inputToken}&access_token={appToken}",
                token, appAccessToken);
        JsonNode data = response.path("data");
        if (data.isMissingNode() || data.isNull()) throw unauthorized();
        return data;
    }

    private JsonNode loadProfile(String token) {
        return getGraph(
                GRAPH_ROOT + graphApiVersion + "/me?fields=id,name,email&access_token={token}", token);
    }

    private JsonNode getGraph(String uri, Object... variables) {
        try {
            JsonNode response = restClient.get().uri(uri, variables)
                    .accept(MediaType.APPLICATION_JSON).retrieve().body(JsonNode.class);
            if (response == null || response.has("error")) throw unauthorized();
            return response;
        } catch (ResponseStatusException ex) {
            throw ex;
        } catch (RestClientResponseException ex) {
            if (ex.getStatusCode().is4xxClientError()) throw unauthorized();
            throw unavailable();
        } catch (RestClientException ex) {
            throw unavailable();
        }
    }

    private ResponseStatusException unauthorized() {
        return new ResponseStatusException(HttpStatus.UNAUTHORIZED,
                "Facebook identity could not be verified.");
    }

    private ResponseStatusException unavailable() {
        return new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE,
                "Facebook sign-in could not be verified right now. Try again later.");
    }
}
