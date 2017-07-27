/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This class is use for Security Context of Invoice__c object.
 **/
public with sharing class InvoiceSecurityContext extends SecurityContext {

    // Field constants for Invoice__c object
    private static final String ALL_SUBSTATUS = 'All_Substatus__c';
    private static final String INVOICE_BALANCE = 'Invoice_Balance__c';
    private static final String INVOICE_STATUS_INDEX = 'Invoice_Status_Index__c';

    // Below field(s) are use for Select/Read permission.
    private static final String DUE_DATE = 'Due_Date__c';
    private static final String GUARANTOR = 'Guarantor__c';
    private static final String ID = 'Id';
    private static final String INVOICE_AGE = 'Invoice_Age__c';
    private static final String INVOICE_DATE = 'Invoice_Date__c';
    private static final String NAME = 'Name';
    private static final String PARTIAL_PAYMENT_PLAN = 'Partial_Payment_Plan__c';
    private static final String SIRONO_ID = 'Sirono_ID__c';
    private static final String STATUS = 'Invoice_Status__c';

    // The fields for updating a Invoice__c's Invoice_Status_Index__c field in InvoiceUtil
    private static final Set<String> UPDATE_FIELDS = new Set<String> {
        INVOICE_STATUS_INDEX
    };

    // The fields for updating a Invoice__c's All_Substatus__c field in InvoiceUtil
    private static final Set<String> UPDATE_ALL_SUBSTATUS_FIELDS = new Set<String> {
        ALL_SUBSTATUS
    };

    // The fields for updating a Invoice__c's Invoice_Balance__c field in InvoiceUtil
    private static final Set<String> UPDATE_BALANCE_FIELDS = new Set<String> {
        INVOICE_BALANCE
    };

    // The fields for selecting a Invoice__c in EarlyOutSchedulerBatch
    private static final Set<String> SELECT_FIELDS = new Set<String> {
        ID, NAME, GUARANTOR, INVOICE_DATE, DUE_DATE, STATUS
    };

    // The fields for selecting the details on Invoices
    private static final Set<String> DETAIL_FIELDS = new Set<String> {
        ID, NAME, INVOICE_BALANCE, SIRONO_ID, INVOICE_DATE, INVOICE_AGE, STATUS, DUE_DATE, PARTIAL_PAYMENT_PLAN
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private InvoiceSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }
    
    /**
     * The update context for Invoice__c's Invoice_Status_Index__c field in InvoiceUtil
     **/
    public static final InvoiceSecurityContext UPDATE_CONTEXT = new InvoiceSecurityContext(UPDATE_FIELDS, ACTION.OBJ_UPDATE);

    public static final InvoiceSecurityContext DETAIL_CONTEXT = new InvoiceSecurityContext(DETAIL_FIELDS, ACTION.OBJ_READ);
    /**
     * The update context for Invoice__c's All_Substatus__c field in InvoiceUtil
     **/
    public static final InvoiceSecurityContext UPDATE_ALL_SUBSTATUS_CONTEXT = new InvoiceSecurityContext(UPDATE_ALL_SUBSTATUS_FIELDS, ACTION.OBJ_UPDATE);

    /**
     * The update context for Invoice__c's Invoice_Balance__c field in InvoiceUtil
     **/
    public static final InvoiceSecurityContext UPDATE_BALANCE_CONTEXT = new InvoiceSecurityContext(UPDATE_BALANCE_FIELDS, ACTION.OBJ_UPDATE);

    /**
     * The select context for Invoice__c in EarlyOutSchedulerBatch
     **/
    public static final InvoiceSecurityContext SELECT_CONTEXT = new InvoiceSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Invoice__c.class;
    }
}