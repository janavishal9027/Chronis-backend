package com.chronis.auth.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.chronis.auth.domain.User;
import com.chronis.auth.dto.GoogleLoginRequest;
import com.chronis.auth.dto.LoginResponse;
import com.chronis.auth.repository.UserRepository;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import java.math.BigInteger;
import java.security.KeyFactory;
import java.security.interfaces.RSAPublicKey;
import java.security.spec.RSAPublicKeySpec;
import java.time.Instant;
import java.util.Base64;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.env.Environment;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestClient;
import org.springframework.web.server.ResponseStatusException;

@Service
@Transactional(readOnly = true)
public class GoogleAuthenticationService {
    private static final String GOOGLE_KEYS_URL = "https://www.googleapis.com/oauth2/v3/certs";
    private static final Logger log = LoggerFactory.getLogger(GoogleAuthenticationService.class);
    private final UserRepository userRepository;
    private final AccountProvisioningService accounts;
    private final AuthService authService;
    private final ObjectMapper objectMapper;
    private final RestClient restClient = RestClient.create();
    private final Set<String> clientIds;
    private volatile Map<String, RSAPublicKey> publicKeys = Map.of();
    private volatile Instant keysExpireAt = Instant.EPOCH;

    public GoogleAuthenticationService(UserRepository userRepository, AccountProvisioningService accounts,
            AuthService authService, ObjectMapper objectMapper, Environment environment) {
        this.userRepository = userRepository;
        this.accounts = accounts;
        this.authService = authService;
        this.objectMapper = objectMapper;
        Set<String> allowedClientIds = new HashSet<>();
        addClientIds(allowedClientIds, environment.getProperty("app.security.google.client-id", ""));
        addClientIds(allowedClientIds, environment.getProperty("app.security.google.client-ids", ""));
        this.clientIds = Set.copyOf(allowedClientIds);
    }

    @Transactional
    public LoginResponse login(GoogleLoginRequest request) {
        if (clientIds.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE,
                    "Google sign-in is not configured. Add the Google web client ID to the backend configuration.");
        }
        Claims claims = validateToken(request.getIdToken());
        String subject = claims.getSubject();
        String email = claims.get("email", String.class);
        String fullName = claims.get("name", String.class);
        if (subject == null || subject.isBlank() || email == null || email.isBlank()
                || !Boolean.TRUE.equals(claims.get("email_verified", Boolean.class))) {
            log.warn("Google sign-in rejected: required identity claims are missing or email is unverified "
                    + "(subjectPresent={}, emailPresent={}, emailVerified={}).",
                    subject != null && !subject.isBlank(), email != null && !email.isBlank(),
                    Boolean.TRUE.equals(claims.get("email_verified", Boolean.class)));
            throw unauthorized();
        }

        String normalizedEmail = email.trim().toLowerCase(Locale.ROOT);
        User user = userRepository.findByGoogleSubject(subject).orElse(null);
        if (user == null) {
            user = userRepository.findByEmail(normalizedEmail).orElse(null);
            if (user != null && !Boolean.TRUE.equals(user.getEmailVerified())) {
                throw new ResponseStatusException(HttpStatus.CONFLICT,
                        "Verify this email address before linking it to Google.");
            }
            if (user != null && user.getGoogleSubject() != null
                    && !subject.equals(user.getGoogleSubject())) {
                throw new ResponseStatusException(HttpStatus.CONFLICT,
                        "This email is already linked to a different Google account.");
            }
            if (user == null) {
                user = accounts.createAccount(fullName, normalizedEmail,
                        accounts.randomPassword(), true, subject);
            } else {
                user.setGoogleSubject(subject);
                user.setEmailVerified(true);
                user.setEnabled(true);
                user = userRepository.save(user);
            }
        } else if (!normalizedEmail.equalsIgnoreCase(user.getEmail())) {
            throw unauthorized();
        }
        return authService.createSession(user);
    }

    private Claims validateToken(String token) {
        if (token == null || token.isBlank()) {
            return reject("identity token is empty");
        }

        String[] segments = token.split("\\.");
        if (segments.length != 3) {
            return reject("identity token has an invalid JWT structure");
        }

        try {
            JsonNode header = objectMapper.readTree(Base64.getUrlDecoder().decode(segments[0]));
            if (!"RS256".equals(header.path("alg").asText())) {
                return reject("identity token uses an unsupported signing algorithm");
            }
            String keyId = header.path("kid").asText();
            if (keyId.isBlank()) {
                return reject("identity token is missing its signing key ID");
            }

            RSAPublicKey key;
            try {
                key = keyFor(keyId);
            } catch (Exception ex) {
                log.warn("Google sign-in rejected: Google signing key could not be loaded ({}).",
                        ex.getClass().getSimpleName());
                throw unauthorized();
            }

            Claims claims = Jwts.parser().verifyWith(key).build()
                    .parseSignedClaims(token).getPayload();
            String issuer = claims.getIssuer();
            if (!("https://accounts.google.com".equals(issuer) || "accounts.google.com".equals(issuer))) {
                return reject("identity token issuer is not Google");
            }
            Set<String> audiences = claims.getAudience();
            if (audiences == null || audiences.stream().noneMatch(clientIds::contains)) {
                log.warn("Google sign-in rejected: audience mismatch (received {}, expected one of {}).",
                        audiences, clientIds);
                throw unauthorized();
            }
            return claims;
        } catch (Exception ex) {
            if (ex instanceof ExpiredJwtException expired) {
                java.util.Date expiration = expired.getClaims().getExpiration();
                log.warn("Google sign-in rejected: ID token expired (expiresAt={}, serverTime={}).",
                        expiration == null ? "missing" : expiration.toInstant(), Instant.now());
            } else if (!(ex instanceof ResponseStatusException)) {
                log.warn("Google sign-in rejected: JWT signature or claims validation failed ({}).",
                        ex.getClass().getSimpleName());
            }
            throw unauthorized();
        }
    }

    private static void addClientIds(Set<String> clientIds, String configuredClientIds) {
        if (configuredClientIds == null || configuredClientIds.isBlank()) return;
        for (String clientId : configuredClientIds.split(",")) {
            String trimmedClientId = clientId.trim();
            if (!trimmedClientId.isEmpty()) clientIds.add(trimmedClientId);
        }
    }

    private Claims reject(String reason) {
        log.warn("Google sign-in rejected: {}.", reason);
        throw unauthorized();
    }

    private RSAPublicKey keyFor(String keyId) throws Exception {
        Map<String, RSAPublicKey> current = publicKeys;
        if (!Instant.now().isBefore(keysExpireAt) || !current.containsKey(keyId)) {
            synchronized (this) {
                current = publicKeys;
                if (!Instant.now().isBefore(keysExpireAt) || !current.containsKey(keyId)) {
                    refreshKeys();
                    current = publicKeys;
                }
            }
        }
        RSAPublicKey key = current.get(keyId);
        if (key == null) throw unauthorized();
        return key;
    }

    private void refreshKeys() throws Exception {
        JsonNode document = restClient.get().uri(GOOGLE_KEYS_URL).retrieve().body(JsonNode.class);
        if (document == null || !document.path("keys").isArray()) throw unauthorized();
        Map<String, RSAPublicKey> keys = new HashMap<>();
        for (JsonNode item : document.path("keys")) {
            if (!"RSA".equals(item.path("kty").asText())
                    || !"RS256".equals(item.path("alg").asText())) continue;
            String kid = item.path("kid").asText();
            byte[] modulus = Base64.getUrlDecoder().decode(item.path("n").asText());
            byte[] exponent = Base64.getUrlDecoder().decode(item.path("e").asText());
            RSAPublicKeySpec spec = new RSAPublicKeySpec(
                    new BigInteger(1, modulus), new BigInteger(1, exponent));
            keys.put(kid, (RSAPublicKey) KeyFactory.getInstance("RSA").generatePublic(spec));
        }
        if (keys.isEmpty()) throw unauthorized();
        publicKeys = Map.copyOf(keys);
        keysExpireAt = Instant.now().plusSeconds(3600);
    }

    private ResponseStatusException unauthorized() {
        return new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Google identity could not be verified.");
    }
}
