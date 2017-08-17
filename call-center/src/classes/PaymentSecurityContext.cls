/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This class is use for Security Context of Payment object
 **/
public with sharing class PaymentSecurityContext extends SecurityContext {

    // Field constants for Payment__c object.
    private static final String AMOUNT = 'Amount__c';
    private static final String CHARGE_DATE = 'Charge_Date__c';
    private static final String DEPOSIT_DATE = 'Deposit_Date__c';
    private static final String ENCOUNTER = 'Encounter__c';
    private static final String GUARANTOR = 'Guarantor__c';
    private static final String ID_C = 'Id__c';
    private static final String LAST_4 = 'Last_4__c';
    private static final String METHOD = 'Method__c';
    private static final String NAME = 'Name';
    private static final String PAYMENT_ID = 'Payment_Id__c';
    private static final String POSTED_AMOUNT = 'Posted_Amount__c';
    private static final String PROCESSOR_TRANSACTION_ID = 'Processor_Transaction_Id__c';
    private static final String SIRONO_ID = 'Sirono_Id__c';

    // Below field(s) are use for Select/Read permission.
    private static final String ID = 'Id';

    // The fields for inserting a Payment in PayEstimate
    private static final Set<String> CREATE_FIELDS = new Set<String> {
        AMOUNT, DEPOSIT_DATE, ENCOUNTER, GUARANTOR
    };

    // The fields for inserting a Payment in PayStaffWSUtill
    private static final Set<String> PSWU_CREATE_FIELDS = new Set<String> {
        GUARANTOR, CHARGE_DATE, METHOD, LAST_4, PROCESSOR_TRANSACTION_ID, AMOUNT, SIRONO_ID, DEPOSIT_DATE
    };

    // The fields for updating a Payment__c in TxnAggregationUtils
    private static final Set<String> UPDATE_FIELDS = new Set<String> {
        AMOUNT, POSTED_AMOUNT
    };

    // The fields for selecting a Payment__c in TxnAggregationUtils
    private static final Set<String> SELECT_FIELDS = new Set<String> {
        ID, SIRONO_ID
    };

    // The fields for selecting a Payment__c in PaymentDao
    private static final Set<String> DAO_SELECT_FIELDS = new Set<String> {
        ID, AMOUNT, DEPOSIT_DATE, ENCOUNTER, GUARANTOR, METHOD, PAYMENT_ID, SIRONO_ID, ID_C
    };


    // The fields for selecting a Payment__c in EncounterUtil
    private static final Set<String> EU_SELECT_FIELDS = new Set<String> {
        ENCOUNTER, AMOUNT
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private PaymentSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }

    /**
     * The create context for Payment__c in PayEstimate
     **/
    public static final PaymentSecurityContext CREATE_CONTEXT = new PaymentSecurityContext(CREATE_FIELDS, ACTION.OBJ_CREATE);
    
    /**
     * The create context for Payment__c in PayStaffWSUtill
     **/
    public static final PaymentSecurityContext PSWU_CREATE_CONTEXT = new PaymentSecurityContext(PSWU_CREATE_FIELDS, ACTION.OBJ_CREATE);
    
    /**
     * The update context for Payment__c in TxnAggregationUtils
     **/
    public static final PaymentSecurityContext UPDATE_CONTEXT = new PaymentSecurityContext(UPDATE_FIELDS, ACTION.OBJ_UPDATE);

    /**
     * The select context for Payment__c in TxnAggregationUtils
     **/
    public static final PaymentSecurityContext SELECT_CONTEXT = new PaymentSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * The select context for Payment__c in EncounterUtil
     **/
    public static final PaymentSecurityContext EU_SELECT_CONTEXT = new PaymentSecurityContext(EU_SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * The select context for Payment__c in PaymentDao
     **/
    public static final PaymentSecurityContext DAO_SELECT_CONTEXT = new PaymentSecurityContext(DAO_SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Payment__c.class;
    }
}