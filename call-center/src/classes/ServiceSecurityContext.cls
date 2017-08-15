/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This class is use for Security Context of Service2__c object
 **/
public with sharing class ServiceSecurityContext extends SecurityContext {

    // Field constants for Service2__c object
    private static final String AMOUNT = 'Amount__c';

    // The fields for updating a Service2__c in TxnAggregationUtils
    private static final Set<String> UPDATE_FIELDS = new Set<String> {
        AMOUNT
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private ServiceSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }

    /**
     * The update context for Service2__c in TxnAggregationUtils
     **/
    public static final ServiceSecurityContext UPDATE_CONTEXT = new ServiceSecurityContext(UPDATE_FIELDS, ACTION.OBJ_UPDATE);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Service2__c.class;
    }
}