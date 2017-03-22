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
    private static final String NOTES = 'Notes__c';
    private static final String PAYMENT = 'Payment__c';
    private static final String POST_DATE = 'Post_Date__c';
    private static final String SIRONO_ID = 'Sirono_ID__c';
	
    // The fields for inserting Transaction in PayStaffWSUtill
    private static final Set<String> CREATE_FIELDS = new Set<String>{
    	SIRONO_ID, NAME, AMOUNT, POST_DATE, FAIL_DATE, EXPORT_DATE, NOTES, CREDIT_BALANCE, CHARGE_GROUP
    };
    
    // The fields for inserting Transaction with Payment in PayStaffWSUtill
    private static final Set<String> CREATE_WITH_PAYMENT_FIELDS = new Set<String>{
    	SIRONO_ID, NAME, AMOUNT, POST_DATE, FAIL_DATE, EXPORT_DATE, NOTES, CREDIT_BALANCE, CHARGE_GROUP, PAYMENT
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
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Transaction__c.class;
    }
}