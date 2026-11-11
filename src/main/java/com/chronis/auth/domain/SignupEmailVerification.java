package com.chronis.auth.domain;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "signup_email_verifications")
@Getter
@Setter
public class SignupEmailVerification {
    @Id private UUID id;
    @Column(nullable = false, unique = true, length = 200) private String email;
    @Column(length = 60) private String codeHash;
    private Instant codeExpiresAt;
    private Instant verifiedAt;
    @Column(length = 64) private String tokenHash;
    private Instant proofExpiresAt;
    private Instant sentAt;
    @Column(nullable = false) private Instant windowStartedAt;
    @Column(nullable = false) private int sendCount;
    @Column(nullable = false) private int attempts;
    @Column(nullable = false) private boolean consumed;
}
