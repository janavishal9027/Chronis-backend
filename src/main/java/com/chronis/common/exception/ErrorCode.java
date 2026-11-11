package com.chronis.common.exception;

public enum ErrorCode {
    // Auth
    AUTH_INVALID_CREDENTIALS("AUTH_001", "Invalid credentials"),
    AUTH_TOKEN_EXPIRED("AUTH_002", "Token expired"),
    AUTH_TOKEN_INVALID("AUTH_003", "Invalid token"),
    AUTH_ACCESS_DENIED("AUTH_004", "Access denied"),
    AUTH_USER_NOT_FOUND("AUTH_005", "User not found"),
    AUTH_EMAIL_EXISTS("AUTH_006", "Email already exists"),
    AUTH_USERNAME_EXISTS("AUTH_007", "Username already exists"),
    AUTH_PASSWORD_MISMATCH("AUTH_008", "Password does not match"),
    AUTH_TOKEN_REVOKED("AUTH_009", "Token revoked"),

    // User
    USER_NOT_FOUND("USER_001", "User not found"),

    // Attendance
    ATT_ALREADY_CHECKED_IN("ATT_001", "Already checked in today"),
    ATT_NOT_CHECKED_IN("ATT_002", "Not checked in today"),
    ATT_ALREADY_CHECKED_OUT("ATT_003", "Already checked out today"),
    ATT_SESSION_NOT_FOUND("ATT_004", "Attendance session not found"),

    // Break
    BREAK_ALREADY_ACTIVE("BRK_001", "A break is already active"),
    BREAK_NOT_ACTIVE("BRK_002", "No active break to end"),
    BREAK_OVERLAP("BRK_003", "Break sessions overlap"),

    // Task
    TASK_NOT_FOUND("TASK_001", "Task not found"),
    TASK_INVALID_STATUS_TRANSITION("TASK_002", "Invalid task status transition"),
    TASK_NOT_ASSIGNED("TASK_003", "Task not assigned to you"),

    // Project
    PROJECT_NOT_FOUND("PROJ_001", "Project not found"),

    // Work Update
    WU_NOT_FOUND("WU_001", "Work update not found"),

    // Daily Report
    DR_NOT_FOUND("DR_001", "Daily report not found"),
    DR_ALREADY_SUBMITTED("DR_002", "Daily report already submitted today"),

    // Schedule
    SCHEDULE_NOT_FOUND("SCH_001", "Schedule not found"),

    // General
    RESOURCE_NOT_FOUND("GEN_001", "Resource not found"),
    INVALID_INPUT("GEN_002", "Invalid input"),
    DUPLICATE_RESOURCE("GEN_003", "Duplicate resource"),
    INTERNAL_ERROR("GEN_999", "Internal server error");

    private final String code;
    private final String defaultMessage;

    ErrorCode(String code, String defaultMessage) {
        this.code = code;
        this.defaultMessage = defaultMessage;
    }

    public String getCode() {
        return code;
    }

    public String getDefaultMessage() {
        return defaultMessage;
    }
}
