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
    private static final String LAST_4 = 'Last_4__c';
    private static final String METHOD = 'Method__c';
    private static final String NAME = 'Name';
    private static final String POSTED_AMOUNT = 'Posted_Amount__c';
    private static final String PROCESSOR_TRANSACTION_ID = 'Processor_Transaction_ID__c';
    private static final String SIRONO_ID = 'Sirono_ID__c';

    // The fields for inserting a Payment in PayEstimate
    private static final Set<String> CREATE_FIELDS = new Set<String>{
    	AMOUNT, DEPOSIT_DATE, ENCOUNTER, GUARANTOR, NAME
    };
    
    // The fields for inserting a Payment in PayStaffWSUtill
    private static final Set<String> PSWU_CREATE_FIELDS = new Set<String>{
    	GUARANTOR, CHARGE_DATE, METHOD, LAST_4, PROCESSOR_TRANSACTION_ID, AMOUNT, SIRONO_ID, NAME
    };

    // The fields for updating a Payment__c in TxnAggregationUtils
    private static final Set<String> UPDATE_FIELDS = new Set<String>{
    	AMOUNT, POSTED_AMOUNT
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
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Payment__c.class;
    }
}