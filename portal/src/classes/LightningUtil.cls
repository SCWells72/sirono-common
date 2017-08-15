/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Common utility functions for Lightning Apex controllers.
 */
public with sharing class LightningUtil {

    private LightningUtil() {
        // Utility class
    }

    /**
     * Creates and returns an AuraHandledException with the specified message.
     *
     * @param message the exception message
     * @return the exception object with the message properly populated
     */
    public static AuraHandledException newAuraHandledException(String message) {
        AuraHandledException ex = new AuraHandledException(message);
        ex.setMessage(message);
        return ex;
    }
}