/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This class is use for Security Context of Transaction object
 **/
public with sharing class TransactionSecurityContext extends SecurityContext {

    // Field constants for Transaction object.
    private static final String AMOUNT = 'Amount__c';
    private static final String CHARGE_GROUP = 'Charge_Group__c';
    private static final String CREDIT_BALANCE = 'Credit_Balance__c';
    private static final String EXPORT_DATE = 'Export_Date__c';
    private static final String FAIL_DATE = 'Fail_Date__c';
    private static final String NAME = 'Name';
    private static final String PAYMENT = 'Payment__c';
    private static final String POST_DATE = 'Post_Date__c';
    private static final String SIRONO_ID = 'Sirono_ID__c';

    // Below field(s) are use for Select/Read permission.
    private static final String ADJUSTMENT = 'Adjustment2__c';
    private static final String CHARGE_ADDED_SINCE_PLAN_START = 'Charge_added_since_plan_start__c';
    private static final String ID = 'Id';
    private static final String LASTMODIFIEDDATE = 'LastModifiedDate';
    private static final String SERVICE = 'Service2__c';
    private static final String TXN_METHOD = 'Txn_Method__c';

    // The fields for inserting Transaction in PayStaffWSUtill
    private static final Set<String> CREATE_FIELDS = new Set<String> {
        SIRONO_ID, NAME, AMOUNT, POST_DATE, FAIL_DATE, EXPORT_DATE, CREDIT_BALANCE, CHARGE_GROUP
    };

    // The fields for inserting Transaction with Payment in PayStaffWSUtill
    private static final Set<String> CREATE_WITH_PAYMENT_FIELDS = new Set<String> {
        SIRONO_ID, NAME, AMOUNT, POST_DATE, FAIL_DATE, EXPORT_DATE, CREDIT_BALANCE, CHARGE_GROUP, PAYMENT
    };

    // The fields for selecting a Transaction__c in TxnAggregationUtils
    private static final Set<String> SELECT_FIELDS = new Set<String> {
        AMOUNT, ADJUSTMENT
    };

    // The fields for selecting a Transaction__c in TxnAggregationUtils
    private static final Set<String> SELECT_WITH_PAYMENT_FIELDS = new Set<String> {
        AMOUNT, PAYMENT
    };

    // The fields for selecting a Transaction__c in TxnAggregationUtils
    private static final Set<String> SELECT_WITH_SERVICE_FIELDS = new Set<String> {
        AMOUNT, SERVICE
    };

    // The fields for selecting a Transaction__c in PaymentPlanUtil
    private static final Set<String> PPU_SELECT_FIELDS = new Set<String> {
        AMOUNT, CHARGE_ADDED_SINCE_PLAN_START, TXN_METHOD
    };

    // The fields for selecting a Transaction__c in PayStaffWSUtill
    private static final Set<String> PSWSU_SELECT_FIELDS = new Set<String> {
        ID, SIRONO_ID
    };

    // The fields for selecting a Transaction__c in CreateCaseManual
    private static final Set<String> CCM_SELECT_FIELDS = new Set<String> {
        AMOUNT, CHARGE_GROUP, LASTMODIFIEDDATE, SIRONO_ID
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private TransactionSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }
    
    /**
     * The context used to create a Transaction in the PayStaffWSUtill
     **/
    public static final TransactionSecurityContext CREATE_CONTEXT = new TransactionSecurityContext(CREATE_FIELDS, ACTION.OBJ_CREATE);
    
    /**
     * The context used to create a Transaction with Payment in the PayStaffWSUtill
     **/
    public static final TransactionSecurityContext CREATE_WITH_PAYMENT_CONTEXT = new TransactionSecurityContext(CREATE_WITH_PAYMENT_FIELDS, ACTION.OBJ_CREATE);

    /**
     * The select context for Transaction__c in TxnAggregationUtils
     **/
    public static final TransactionSecurityContext SELECT_CONTEXT = new TransactionSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * The select context for Transaction__c in TxnAggregationUtils
     **/
    public static final TransactionSecurityContext SELECT_CONTEXT_WITH_PAYMENT = new TransactionSecurityContext(SELECT_WITH_PAYMENT_FIELDS, ACTION.OBJ_READ);

    /**
     * The select context for Transaction__c in TxnAggregationUtils
     **/
    public static final TransactionSecurityContext SELECT_CONTEXT_WITH_SERVICE = new TransactionSecurityContext(SELECT_WITH_SERVICE_FIELDS, ACTION.OBJ_READ);

    /**
     * The select context for Transaction__c in PaymentPlanUtil
     **/
    public static final TransactionSecurityContext PPU_SELECT_CONTEXT = new TransactionSecurityContext(PPU_SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * The select context for Transaction__c in PayStaffWSUtill
     **/
    public static final TransactionSecurityContext PSWSU_SELECT_CONTEXT = new TransactionSecurityContext(PSWSU_SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * The select context for Transaction__c in CreateCaseManual
     **/
    public static final TransactionSecurityContext CCM_SELECT_CONTEXT = new TransactionSecurityContext(CCM_SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Transaction__c.class;
    }
}