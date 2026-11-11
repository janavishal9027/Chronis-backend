package com.chronis.auth.service;

import com.chronis.auth.dto.*;
import com.chronis.auth.repository.UserRepository;
import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicReference;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.*;
import org.springframework.web.server.ResponseStatusException;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/** Runs real schema initialization and transactions in an isolated schema, with mail mocked. */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.MOCK)
@EnabledIfEnvironmentVariable(named = "CHRONIS_AUTH_IT", matches = "true")
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class SignupEmailPostgresIntegrationTest {
    private static final String SCHEMA = "chronis_email_it_" + UUID.randomUUID().toString().replace("-", "");
    @DynamicPropertySource static void config(DynamicPropertyRegistry r) {
        r.add("spring.datasource.url", () -> System.getenv("CHRONIS_TEST_DB_URL"));
        r.add("spring.datasource.username", () -> System.getenv("CHRONIS_TEST_DB_USER"));
        r.add("spring.datasource.password", () -> System.getenv("CHRONIS_TEST_DB_PASSWORD"));
        com.chronis.support.PostgresTestSchema.create(SCHEMA);
        
        r.add("spring.jpa.properties.hibernate.default_schema", () -> SCHEMA);
        r.add("spring.datasource.hikari.connection-init-sql", () -> "SET search_path TO " + SCHEMA);
        r.add("app.bootstrap.password", () -> "");
        r.add("JWT_SECRET", () -> "Integration-Only-Secret-At-Least-32-Bytes");
        r.add("logging.level.org.springframework", () -> "WARN");
        r.add("logging.level.org.hibernate", () -> "WARN");
    }
    @Autowired SignupEmailVerificationService emails;
    @Autowired RegistrationService registration;
    @Autowired UserRepository users;
    @Autowired JdbcTemplate jdbc;
    @MockBean EmailVerificationMailService mail;
    private final AtomicReference<String> sentCode = new AtomicReference<>();
    private String email;
    @BeforeEach void prepare() {
        email = "signup-" + UUID.randomUUID() + "@example.test";
        doAnswer(call -> { sentCode.set(call.getArgument(1)); return null; }).when(mail).sendCode(eq(email), anyString());
    }
    @AfterAll void removeOnlyThisTestSchema() {
        if (!SCHEMA.matches("chronis_email_it_[a-f0-9]{32}")) throw new IllegalStateException("Invalid test schema");
        jdbc.execute("drop schema " + SCHEMA + " cascade");
    }
    private SignupRequest signup(SignupEmailProofResponse proof) {
        var request = new SignupRequest();
        request.setFullName("Email Test");
        request.setEmail(email);
        request.setPassword("Valid-Password-123");
        request.setEmailVerificationId(proof.verificationId());
        request.setEmailVerificationToken(proof.verificationToken());
        return request;
    }
    @Test void verifiedEmailCreatesEnabledAccountWithoutPhoneAndCannotBeReused() {
        var challenge = emails.send(email.toUpperCase(Locale.ROOT), "test-ip");
        assertFalse(users.existsByEmail(email));
        var row = jdbc.queryForMap("select * from signup_email_verifications where id = ?", challenge.challengeId());
        assertNotEquals(sentCode.get(), row.get("code_hash"));
        var proof = emails.verify(new SignupEmailCodeRequest(challenge.challengeId(), email, sentCode.get()));
        registration.signup(signup(proof));
        var user = users.findByEmail(email).orElseThrow();
        assertTrue(user.isEnabled());
        assertTrue(user.getEmailVerified());
        assertEquals(0, jdbc.queryForObject("select count(*) from information_schema.columns where table_schema=current_schema() and table_name='users' and column_name in ('phone_number', 'phone_verified')", Integer.class));
        assertTrue(jdbc.queryForObject("select to_regclass('phone_verifications') is null", Boolean.class));
        assertThrows(ResponseStatusException.class, () -> emails.consume(proof.verificationId(), email, proof.verificationToken()));
        assertThrows(ResponseStatusException.class, () -> emails.verify(new SignupEmailCodeRequest(challenge.challengeId(), email, sentCode.get())));
    }
    @Test void invalidCodeAttemptsPersistAndLockOutAfterFiveFailures() {
        var challenge = emails.send(email, "test-ip");
        String wrong = "000000".equals(sentCode.get()) ? "111111" : "000000";
        for (int i = 0; i < 5; i++) {
            assertThrows(ResponseStatusException.class, () -> emails.verify(new SignupEmailCodeRequest(challenge.challengeId(), email, wrong)));
        }
        assertEquals(5, jdbc.queryForObject("select attempts from signup_email_verifications where id = ?", Integer.class, challenge.challengeId()));
        assertThrows(ResponseStatusException.class, () -> emails.verify(new SignupEmailCodeRequest(challenge.challengeId(), email, sentCode.get())));
        assertFalse(users.existsByEmail(email));
    }
    @Test void forgedMismatchedAndExpiredProofsCannotCreateAnAccount() {
        var challenge = emails.send(email, "test-ip");
        var proof = emails.verify(new SignupEmailCodeRequest(challenge.challengeId(), email, sentCode.get()));
        assertThrows(ResponseStatusException.class, () -> emails.consume(proof.verificationId(), "other@example.test", proof.verificationToken()));
        assertThrows(ResponseStatusException.class, () -> emails.consume(proof.verificationId(), email, "forged-proof"));
        jdbc.update("update signup_email_verifications set proof_expires_at = now() - interval '1 second' where id = ?", proof.verificationId());
        assertThrows(ResponseStatusException.class, () -> registration.signup(signup(proof)));
        assertFalse(users.existsByEmail(email));
    }
    @Test void resendCooldownPreventsDuplicateDeliveryAndNewCodeInvalidatesOldProof() {
        var challenge = emails.send(email, "test-ip");
        var limited = assertThrows(ResponseStatusException.class, () -> emails.send(email, "test-ip"));
        assertEquals(429, limited.getStatusCode().value());
        verify(mail, times(1)).sendCode(eq(email), anyString());
        var proof = emails.verify(new SignupEmailCodeRequest(challenge.challengeId(), email, sentCode.get()));
        jdbc.update("update signup_email_verifications set sent_at = now() - interval '61 seconds' where id = ?", challenge.challengeId());
        emails.send(email, "test-ip");
        assertThrows(ResponseStatusException.class, () -> emails.consume(proof.verificationId(), email, proof.verificationToken()));
    }
    @Test void concurrentVerificationIssuesExactlyOneProof() throws Exception {
        var challenge = emails.send(email, "test-ip");
        String code = sentCode.get();
        try (var executor = Executors.newFixedThreadPool(2)) {
            Callable<Boolean> verify = () -> {
                try { emails.verify(new SignupEmailCodeRequest(challenge.challengeId(), email, code)); return true; }
                catch (ResponseStatusException expected) { return false; }
            };
            var results = executor.invokeAll(List.of(verify, verify));
            assertEquals(1, results.stream().filter(result -> {
                try { return result.get(); } catch (Exception error) { throw new RuntimeException(error); }
            }).count());
        }
    }
}
