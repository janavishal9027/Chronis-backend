package com.chronis.notification.service;

import com.chronis.notification.domain.Notification;
import com.chronis.notification.dto.NotificationDTO;
import com.chronis.notification.repository.NotificationRepository;
import com.chronis.common.exception.AppException;
import com.chronis.common.exception.ErrorCode;
import com.chronis.auth.domain.User;
import com.chronis.auth.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;

    public List<NotificationDTO> getMyNotifications() {
        User emp = currentUser();
        return notificationRepository.findByRecipientIdOrderByCreatedAtDesc(emp.getId()).stream()
                .map(this::toDto).collect(Collectors.toList());
    }

    public long getUnreadCount() {
        User emp = currentUser();
        return notificationRepository.countByRecipientIdAndReadStatus(emp.getId(), Notification.ReadStatus.UNREAD);
    }

    @Transactional
    public NotificationDTO markRead(Long id) {
        Notification n = notificationRepository.findById(id)
                .orElseThrow(() -> new AppException(ErrorCode.RESOURCE_NOT_FOUND.getCode(), "Notification not found"));
        if (!n.getRecipient().getId().equals(currentUser().getId()))
            throw new org.springframework.security.access.AccessDeniedException("Notification belongs to another user");
        n.setReadStatus(Notification.ReadStatus.READ);
        n.setReadAt(java.time.Instant.now());
        return toDto(notificationRepository.save(n));
    }

    private User currentUser() {
        com.chronis.auth.domain.User user = (com.chronis.auth.domain.User) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        return userRepository.findById(user.getId())
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_FOUND.getCode(), "User not found"));
    }

    private NotificationDTO toDto(Notification n) {
        return NotificationDTO.builder()
                .id(n.getId()).recipientId(n.getRecipient().getId()).title(n.getTitle()).body(n.getBody())
                .type(n.getType()).readStatus(n.getReadStatus()).createdAt(n.getCreatedAt()).build();
    }
}
