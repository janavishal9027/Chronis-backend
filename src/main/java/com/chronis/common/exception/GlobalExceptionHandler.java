package com.chronis.common.exception;

import com.chronis.common.dto.ApiResponse;
import com.chronis.common.dto.ErrorResponse;
import java.util.stream.Collectors;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.authentication.LockedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.server.ResponseStatusException;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(AppException.class)
    public ResponseEntity<ApiResponse<ErrorResponse>> handleAppException(AppException ex) {
        ErrorResponse error = ErrorResponse.builder()
                .errorCode(ex.getErrorCode())
                .message(ex.getMessage())
                .details(null)
                .build();
        HttpStatus status = HttpStatus.BAD_REQUEST;
        if (ex.getErrorCode().equals(ErrorCode.AUTH_ACCESS_DENIED.getCode())) status = HttpStatus.FORBIDDEN;
        else if (ex.getErrorCode().equals(ErrorCode.AUTH_TOKEN_EXPIRED.getCode()) || ex.getErrorCode().equals(ErrorCode.AUTH_TOKEN_INVALID.getCode())
                || ex.getErrorCode().equals(ErrorCode.AUTH_TOKEN_REVOKED.getCode())) status = HttpStatus.UNAUTHORIZED;
        else if (java.util.Set.of("USER_001", "TASK_001", "PROJ_001", "WU_001", "DR_001", "SCH_001", "GEN_001").contains(ex.getErrorCode())) status = HttpStatus.NOT_FOUND;
        else if (java.util.Set.of("ATT_001", "ATT_003", "BRK_001", "DR_002", "GEN_003").contains(ex.getErrorCode())) status = HttpStatus.CONFLICT;
        return ResponseEntity.status(status).body(ApiResponse.<ErrorResponse>builder().success(false)
                .message(error.getMessage()).data(error).timestamp(java.time.Instant.now()).build());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<ErrorResponse>> handleValidation(MethodArgumentNotValidException ex) {
        String details = ex.getBindingResult().getFieldErrors().stream()
                .map(e -> e.getField() + ": " + e.getDefaultMessage())
                .collect(Collectors.joining(", "));
        ErrorResponse error = ErrorResponse.builder()
                .errorCode(ErrorCode.INVALID_INPUT.getCode())
                .message(ErrorCode.INVALID_INPUT.getDefaultMessage())
                .details(details)
                .build();
        return ResponseEntity.badRequest()
                .body(ApiResponse.<ErrorResponse>builder().success(false).message(details).data(error).timestamp(java.time.Instant.now()).build());
    }

    @ExceptionHandler(AuthenticationException.class)
    public ResponseEntity<ApiResponse<ErrorResponse>> handleAuth(AuthenticationException ex) {
        ErrorResponse error = ErrorResponse.builder()
                .errorCode(ErrorCode.AUTH_INVALID_CREDENTIALS.getCode())
                .message(ex.getMessage())
                .build();
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error(error.getMessage()));
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ApiResponse<ErrorResponse>> handleAccessDenied(AccessDeniedException ex) {
        ErrorResponse error = ErrorResponse.builder()
                .errorCode(ErrorCode.AUTH_ACCESS_DENIED.getCode())
                .message("Access denied")
                .build();
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error(error.getMessage()));
    }

    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<ApiResponse<ErrorResponse>> handleResponseStatus(ResponseStatusException ex) {
        ErrorResponse error = ErrorResponse.builder()
                .errorCode(ErrorCode.RESOURCE_NOT_FOUND.getCode())
                .message(ex.getReason() != null ? ex.getReason() : ex.getMessage())
                .build();
        return ResponseEntity.status(ex.getStatusCode())
                .body(ApiResponse.error(error.getMessage()));
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ApiResponse<ErrorResponse>> handleIllegalArgument(IllegalArgumentException ex) {
        ErrorResponse error = ErrorResponse.builder()
                .errorCode(ErrorCode.INVALID_INPUT.getCode())
                .message(ex.getMessage())
                .build();
        return ResponseEntity.badRequest()
                .body(ApiResponse.error(error.getMessage()));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<ErrorResponse>> handleGeneric(Exception ex) {
        log.error("Unexpected error", ex);
        ErrorResponse error = ErrorResponse.builder()
                .errorCode(ErrorCode.INTERNAL_ERROR.getCode())
                .message("An unexpected error occurred")
                .build();
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error(error.getMessage()));
    }

    @ExceptionHandler(org.springframework.web.HttpMediaTypeNotSupportedException.class)
    public ResponseEntity<ApiResponse<Void>> handleUnsupportedMediaType(
            org.springframework.web.HttpMediaTypeNotSupportedException ex) {
        return ResponseEntity.status(HttpStatus.UNSUPPORTED_MEDIA_TYPE)
                .body(ApiResponse.error("Unsupported content type for this request"));
    }

    @ExceptionHandler({org.springframework.http.converter.HttpMessageNotReadableException.class,
            org.springframework.web.method.annotation.MethodArgumentTypeMismatchException.class,
            org.springframework.web.bind.MissingServletRequestParameterException.class})
    public ResponseEntity<ApiResponse<Void>> handleMalformedRequest(Exception ex) {
        return ResponseEntity.badRequest().body(ApiResponse.error("Invalid request values"));
    }

    @ExceptionHandler({org.springframework.dao.DataIntegrityViolationException.class,
            org.springframework.dao.OptimisticLockingFailureException.class})
    public ResponseEntity<ApiResponse<Void>> handleConflict(Exception ex) {
        return ResponseEntity.status(HttpStatus.CONFLICT).body(ApiResponse.error("The record conflicts with current data; refresh and try again"));
    }
}
