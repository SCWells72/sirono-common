/**
 * Created by mmartin on 2/23/17.
 */

public with sharing class PaymentMethodSecurityContext extends SecurityContext {

    /*// Field constants for Payment_Method__c object.
    private static final String GUARANTOR = 'Guarantor__c';
    private static final String RECORDTYPEID = 'RecordTypeID';

    // The fields for inserting a Payment Method in PaymentArrangement
    private static final Set<String> CREATE_FIELDS = new Set<String>{
    	GUARANTOR, RECORDTYPEID
    };*/

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    /*private PaymentMethodSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }*/

    /**
     * The create context for Payment_Method__c
     **/
    //public static final PaymentMethodSecurityContext CREATE_CONTEXT = new PaymentMethodSecurityContext(CREATE_FIELDS, ACTION.OBJ_CREATE);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        //return Payment_Method__c.class;
        return null;
    }
    
    /**
     * Override deleteActionAllowed method of SecurityContext class
     **/
    public override Boolean deleteActionAllowed() { 	
        //return Payment_Method__c.sObjectType.getDescribe().isDeletable();
        return false;
    }
}