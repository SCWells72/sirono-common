/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Exception that occurs when an error is encountered during a Service operation.
 */
global class SironoServiceException extends Exception {

    // A list of errors associated with the exception.
    global List<String> errors { set; get; }

    global SironoServiceException(List<String> errors) {
        this.errors = errors;
    }
}