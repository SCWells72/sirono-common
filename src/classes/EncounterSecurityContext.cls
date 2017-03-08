/**
 * This class is use for Security Context of Encounter__c object
 **/

public with sharing class EncounterSecurityContext extends SecurityContext {
	
    // Field constants for Encounter__c object
    private static final String HAS_CHARGEGROUP = 'Has_Chargegroup__c';
    private static final String TOTAL_PAYMENTS = 'Total_Payments__c';
    
    // The fields for updating a Encounter__c's Total_Payments__c field in EncounterUtil.
    private static final Set<String> UPDATE_FIELDS = new Set<String>{
    	TOTAL_PAYMENTS
    };
    
    // The fields for updating a Encounter__c's Has_Chargegroup__c field in EncounterUtil.
    private static final Set<String> UPDATE_HAS_CHARGEGROUP_FIELDS = new Set<String>{
    	HAS_CHARGEGROUP
    };
    
    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private EncounterSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }
    
    /**
     * The update context for Encounter__c's Total_Payments__c field in EncounterUtil
     **/
    public static final EncounterSecurityContext UPDATE_CONTEXT = new EncounterSecurityContext(UPDATE_FIELDS, ACTION.OBJ_UPDATE);
    
    /**
     * The update context for Encounter__c's Has_Chargegroup__c field in EncounterUtil
     **/
    public static final EncounterSecurityContext UPDATE_HAS_CHARGEGROUP_CONTEXT = new EncounterSecurityContext(UPDATE_HAS_CHARGEGROUP_FIELDS, ACTION.OBJ_UPDATE);
    
    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Encounter__c.class;
    }
    
    /**
     * Override deleteActionAllowed method of SecurityContext class
     **/
    public override Boolean deleteActionAllowed() { 	
        return Encounter__c.sObjectType.getDescribe().isDeletable();
    }
}