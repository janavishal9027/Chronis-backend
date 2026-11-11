package com.chronis.notification.dto;

import com.chronis.notification.domain.Notification;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationDTO {
    private Long id;
    private Long recipientId;
    private String title;
    private String body;
    private Notification.Type type;
    private Notification.ReadStatus readStatus;
    private Instant createdAt;
}
