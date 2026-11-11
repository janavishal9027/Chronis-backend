package com.chronis.notification.repository;

import com.chronis.notification.domain.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long>,
        JpaSpecificationExecutor<Notification> {

    List<Notification> findByRecipientIdOrderByCreatedAtDesc(Long recipientId);

    List<Notification> findByRecipientIdAndReadStatus(Long recipientId, com.chronis.notification.domain.Notification.ReadStatus readStatus);

    long countByRecipientIdAndReadStatus(Long recipientId, com.chronis.notification.domain.Notification.ReadStatus readStatus);
}
