/**
 * This class is use for Security Context of Charge Group object
 **/

public with sharing class ChargeGroupSecurityContext extends SecurityContext {

    // Field constants for Charge_Group__c object
    private static final String ACCOUNT_STATUS = 'Account_Status__c';
    private static final String ACCOUNT_SUB_STATUS = 'Account_Sub_Status__c';    
    private static final String PAYMENT_PLAN = 'Payment_Plan__c';

    // The fields for updating a Charge Group in AddToPaymentPlan & AddCreditCard.
    private static final Set<String> UPDATE_FIELDS = new Set<String>{
    	ACCOUNT_SUB_STATUS, PAYMENT_PLAN
    };
    
    // The fields for updating a Charge Group in PayStaffWSUtill & DeletePaymentPlan.
    private static final Set<String> UPDATE_WITH_STATUS_FIELDS = new Set<String>{
    	ACCOUNT_STATUS, ACCOUNT_SUB_STATUS, PAYMENT_PLAN
    };
	
    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private ChargeGroupSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }

    /**
     * The update context for Charge Group in AddToPaymentPlan & AddCreditCard.
     **/
    public static final ChargeGroupSecurityContext UPDATE_CONTEXT = new ChargeGroupSecurityContext(UPDATE_FIELDS, ACTION.OBJ_UPDATE);
    
    /**
     * The update with CG status context for Charge Group in PayStaffWSUtill & DeletePaymentPlan.
     **/
    public static final ChargeGroupSecurityContext UPDATE_WITH_STATUS_CONTEXT = new ChargeGroupSecurityContext(UPDATE_WITH_STATUS_FIELDS, ACTION.OBJ_UPDATE);

    /**
     * Override getObjectType method of SecurityContext class.
     **/
    public override System.Type getObjectType() {
        return Charge_Group__c.class;
    }
    
    /**
     * Override deleteActionAllowed method of SecurityContext class
     **/
    public override Boolean deleteActionAllowed() { 	
        return Charge_Group__c.sObjectType.getDescribe().isDeletable();
    }
}