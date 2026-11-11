package com.chronis.auth.repository;

import com.chronis.auth.domain.SignupEmailVerification;
import jakarta.persistence.LockModeType;
import java.time.Instant;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;

public interface SignupEmailVerificationRepository extends JpaRepository<SignupEmailVerification, UUID> {
    @Modifying
    @Query(value = "INSERT INTO signup_email_verifications (id, email, window_started_at) "
            + "VALUES (:id, :email, :now) ON CONFLICT (email) DO NOTHING", nativeQuery = true)
    void createIfMissing(@Param("id") UUID id, @Param("email") String email, @Param("now") Instant now);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Optional<SignupEmailVerification> findByEmail(String email);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select v from SignupEmailVerification v where v.id = :id")
    Optional<SignupEmailVerification> findForUpdate(@Param("id") UUID id);
}
