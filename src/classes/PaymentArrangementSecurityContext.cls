/**
 * This class is use for Security Context of Payment Arrangement object
 **/

public with sharing class PaymentArrangementSecurityContext extends SecurityContext {

    /*// Field constants for Payment_Arrangement__c object.
    private static final String ENCOUNTER = 'Encounter__c';
    private static final String PAYMENT_METHOD = 'Payment_Method__c';

    // The fields for inserting a Payment Arrangement in PaymentArrangement
    private static final Set<String> CREATE_FIELDS = new Set<String>{
    	ENCOUNTER, PAYMENT_METHOD
    };*/

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    /*private PaymentArrangementSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }*/

    /**
     * The create context for Payment_Arrangement__c
     **/
    //public static final PaymentArrangementSecurityContext CREATE_CONTEXT = new PaymentArrangementSecurityContext(CREATE_FIELDS, ACTION.OBJ_CREATE);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        //return Payment_Arrangement__c.class;
        return null;
    }
    
    /**
     * Override deleteActionAllowed method of SecurityContext class
     **/
    public override Boolean deleteActionAllowed() { 	
        //return Payment_Arrangement__c.sObjectType.getDescribe().isDeletable();
        return false;
    }
}