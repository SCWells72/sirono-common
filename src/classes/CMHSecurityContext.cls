/**
 * This class is use for Security Context of Campaign Member History object
 **/

public with sharing class CMHSecurityContext extends SecurityContext {

    // Field constants for Campaign_Member_History__c object
    private static final String CAMPAIGN = 'Campaign__c';
    private static final String CASE_ID = 'Case_ID__c';
    private static final String CONTACT = 'Contact__c';
    private static final String DATE_REMOVED = 'Date_Removed__c';

    // Below field(s) are use for Select/Read permission.
    private static final String CREATEDDATE = 'CreatedDate';
    private static final String ID = 'Id';
    private static final String NAME = 'Name';

    // The fields for inserting a CampaignMemberHistory in Campaign Member Trigger Handler
    private static final Set<String> CREATE_FIELDS = new Set<String>{
    	CAMPAIGN, CASE_ID, CONTACT
    };
    
    // The fields for updating a CampaignMemberHistory in Campaign Member Trigger Handler
    private static final Set<String> UPDATE_FIELDS = new Set<String>{
        DATE_REMOVED
    };

    // The fields for selecting a CampaignMemberHistory in CampaignMemberTriggerHandler
    private static final Set<String> SELECT_FIELDS = new Set<String>{
        CAMPAIGN, CONTACT, CREATEDDATE, DATE_REMOVED, ID, NAME
    };

    // The fields for selecting a CampaignMemberHistory in TaskTriggerHandler
    private static final Set<String> TTH_SELECT_FIELDS = new Set<String>{
        CAMPAIGN, CASE_ID, CONTACT, ID
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private CMHSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }

    /**
     * The create context for CampaignMemberHistory in CampaignMemberTriggerHandler & CaseUtil
     **/
    public static final CMHSecurityContext CREATE_CONTEXT = new CMHSecurityContext(CREATE_FIELDS, ACTION.OBJ_CREATE);

    /**
     * The update context for CampaignMemberHistory in CampaignMemberTriggerHandler
     **/
    public static final CMHSecurityContext UPDATE_CONTEXT = new CMHSecurityContext(UPDATE_FIELDS, ACTION.OBJ_UPDATE);

    /**
     * The delete context for CampaignMemberHistory in CampaignMemberTriggerHandler
     **/
    public static final CMHSecurityContext DELETE_CONTEXT = new CMHSecurityContext(null, ACTION.OBJ_DELETE);

    /**
     * The select context for CampaignMemberHistory in CampaignMemberTriggerHandler
     **/
    public static final CMHSecurityContext SELECT_CONTEXT = new CMHSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * The select context for CampaignMemberHistory in TaskTriggerHandler
     **/
    public static final CMHSecurityContext TTH_SELECT_CONTEXT = new CMHSecurityContext(TTH_SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Campaign_Member_History__c.class;
    }
}