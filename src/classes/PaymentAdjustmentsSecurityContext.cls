/**
 * This class is use for Security Context of Payment Adjustments object
 **/
 
public with sharing class PaymentAdjustmentsSecurityContext extends SecurityContext {

    // Field constants for Payment_Adjustments__c objects.
    private static final String AMOUNT = 'Amount__c';
    private static final String CHARGE_GROUP = 'Charge_Group__c';
    private static final String DESCRIPTION = 'Description__c';
    private static final String NAME = 'Name';
    private static final String POST_DATE = 'Post_Date__c';
    private static final String SIRONO_ID = 'Sirono_ID__c';
    private static final String TRANSACTION_TYPE = 'Transaction_Type__c';
	
    // The fields for inserting a Payment_Adjustments__c in PayStaffWSUtill
    private static final Set<String> CREATE_FIELDS = new Set<String>{
    	AMOUNT, CHARGE_GROUP, DESCRIPTION, NAME, POST_DATE, SIRONO_ID, TRANSACTION_TYPE
    };
    
    // The fields for updating a Payment_Adjustments__c in TxnAggregationUtils
    private static final Set<String> UPDATE_FIELDS = new Set<String>{
    	AMOUNT
    };
    
    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private PaymentAdjustmentsSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }
    
    /**
     * The context used to create a Payment_Adjustments__c in the PayStaffWSUtill
     **/
    public static final PaymentAdjustmentsSecurityContext CREATE_CONTEXT = new PaymentAdjustmentsSecurityContext(CREATE_FIELDS, ACTION.OBJ_CREATE);
    
    /**
     * The update context for Payment_Adjustments__c in TxnAggregationUtils
     **/
    public static final PaymentAdjustmentsSecurityContext UPDATE_CONTEXT = new PaymentAdjustmentsSecurityContext(UPDATE_FIELDS, ACTION.OBJ_UPDATE);
    
    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Payment_Adjustments__c.class;
    }
    
    /**
     * Override deleteActionAllowed method of SecurityContext class
     **/
    public override Boolean deleteActionAllowed() { 	
        return Payment_Adjustments__c.sObjectType.getDescribe().isDeletable();
    }
}