/**
 * This class is use for Security Context of Campaign Member object
 **/

public with sharing class CmpnMemberSecurityContext extends SecurityContext {

    // Field constants for CampaignMember object.
    private static final String CAMPAIGNID = 'CampaignId';
    private static final String CASE_ID = 'Case_ID__c';
    private static final String CONTACTID = 'ContactId';
    private static final String STATUS = 'Status';

    // The fields for inserting CampaignMember in CaseUtil
    private static final Set<String> CREATE_FIELDS = new Set<String>{
    	CAMPAIGNID, CASE_ID, CONTACTID
    };
    
    // The fields for inserting CampaignMember in EarlyOutSchedulerBatch
    private static final Set<String> SB_CREATE_FIELDS = new Set<String>{
    	CAMPAIGNID, STATUS, CONTACTID
    };
    
    // The fields for updating CampaignMember in CaseUtil
    private static final Set<String> UPDATE_FIELDS = new Set<String>{
    	CASE_ID
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private CmpnMemberSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }
    
    public CmpnMemberSecurityContext() {}

    /**
     * The create context for CampaignMember in CampaignMemberTriggerHandler & CaseUtil
     **/
    public static final CmpnMemberSecurityContext CREATE_CONTEXT = new CmpnMemberSecurityContext(CREATE_FIELDS, ACTION.OBJ_CREATE);
    
    /**
     * The create context for CampaignMember in EarlyOutSchedulerBatch
     **/
    public static final CmpnMemberSecurityContext SB_CREATE_CONTEXT = new CmpnMemberSecurityContext(SB_CREATE_FIELDS, ACTION.OBJ_CREATE);

    /**
     * The update context for CampaignMember in CampaignMemberTriggerHandler & CaseUtil
     **/
    public static final CmpnMemberSecurityContext UPDATE_CONTEXT = new CmpnMemberSecurityContext(UPDATE_FIELDS, ACTION.OBJ_UPDATE);

    /**
     * The delete context for CampaignMember in CampaignMemberTriggerHandler, TaskTriggerHandler & CaseTriggerHandler
     **/
    public static final CmpnMemberSecurityContext DELETE_CONTEXT = new CmpnMemberSecurityContext(null, ACTION.OBJ_DELETE);
    
    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return CampaignMember.class;
    }
    
    /**
     * Override deleteActionAllowed method of SecurityContext class
     **/
    public override Boolean deleteActionAllowed() { 	
        return CampaignMember.sObjectType.getDescribe().isDeletable();
    }
}