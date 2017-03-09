/**
 * This class is use for Security Context of Contact object
 **/

public with sharing class ContactSecurityContext extends SecurityContext {

    // Field constants for Contact object
    private static final String ESTIMATE_BALANCE = 'Estimate_Balance__c';
    private static final String RECORDTYPEID = 'RecordTypeId';

    // The fields for updating a Contact in EncounterUtil
    private static final Set<String> UPDATE_FIELDS = new Set<String>{
    	ESTIMATE_BALANCE, RECORDTYPEID
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private ContactSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }
    
    /**
     * The update context for Contact in EncounterUtil
     **/
    public static final ContactSecurityContext UPDATE_CONTEXT = new ContactSecurityContext(UPDATE_FIELDS, ACTION.OBJ_UPDATE);
    
    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Contact.class;
    }
    
    /**
     * Override deleteActionAllowed method of SecurityContext class
     **/
    public override Boolean deleteActionAllowed() { 	
        return Contact.sObjectType.getDescribe().isDeletable();
    }
}