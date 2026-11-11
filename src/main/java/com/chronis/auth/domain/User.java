package com.chronis.auth.domain;

import com.chronis.common.audit.BaseEntity;
import java.util.HashSet;
import java.util.Set;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.Getter;
import lombok.Setter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

@Entity
@Table(name = "users",
       uniqueConstraints = {
           @UniqueConstraint(columnNames = "username"),
           @UniqueConstraint(columnNames = "email")
       })
@Getter
@Setter
public class User extends BaseEntity implements UserDetails {

    @Column(name = "username", nullable = false, unique = true, length = 100)
    private String username;

    @Column(name = "email", nullable = false, unique = true, length = 200)
    private String email;

    @Column(name = "password", nullable = false, length = 255)
    private String password;

    @Column(name = "enabled", nullable = false)
    private Boolean enabled = true;

    @Column(name = "account_non_expired", nullable = false)
    private Boolean accountNonExpired = true;

    @Column(name = "account_non_locked", nullable = false)
    private Boolean accountNonLocked = true;

    @Column(name = "credentials_non_expired", nullable = false)
    private Boolean credentialsNonExpired = true;

    @Column(name = "password_changed_at")
    private java.time.Instant passwordChangedAt;

    @Column(name = "password_reset_token", length = 512)
    private String passwordResetToken;

    @Column(name = "password_reset_token_expiry")
    private java.time.Instant passwordResetTokenExpiry;

    @Column(name = "email_verified", nullable = false)
    private Boolean emailVerified = true;

    @Column(name = "email_verification_code_hash", length = 64)
    private String emailVerificationCodeHash;

    @Column(name = "email_verification_code_expiry")
    private java.time.Instant emailVerificationCodeExpiry;

    @Column(name = "email_verification_sent_at")
    private java.time.Instant emailVerificationSentAt;

    @Column(name = "email_verification_attempts", nullable = false)
    private Integer emailVerificationAttempts = 0;

    @Column(name = "google_subject", length = 255, unique = true)
    private String googleSubject;

    @Column(name = "facebook_subject", length = 255, unique = true)
    private String facebookSubject;

    @Column(name = "first_name", length = 100)
    private String firstName;

    @Column(name = "last_name", length = 100)
    private String lastName;

    @Column(name = "timezone", nullable = false, length = 50)
    private String timezone = "Asia/Kolkata";

    @Column(name = "profile_picture_url", length = 500)
    private String profilePictureUrl;

    @Column(name = "employee_id", length = 50)
    private String employeeId;

    @Override
    public java.util.Collection<? extends GrantedAuthority> getAuthorities() {
        return java.util.List.of();
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public String getUsername() {
        return username;
    }

    @Override
    public boolean isAccountNonExpired() {
        return accountNonExpired;
    }

    @Override
    public boolean isAccountNonLocked() {
        return accountNonLocked;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return credentialsNonExpired;
    }

    @Override
    public boolean isEnabled() {
        return enabled;
    }
}
