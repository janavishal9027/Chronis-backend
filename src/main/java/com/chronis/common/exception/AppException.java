package com.chronis.common.exception;

import lombok.Getter;

public class AppException extends RuntimeException {

    @Getter
    private final String errorCode;

    @Getter
    private final Object[] arguments;

    public AppException(String errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
        this.arguments = new Object[0];
    }

    public AppException(String errorCode, String message, Object... arguments) {
        super(message);
        this.errorCode = errorCode;
        this.arguments = arguments;
    }
}
