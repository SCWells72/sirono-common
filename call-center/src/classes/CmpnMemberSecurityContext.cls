/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This class is use for Security Context of Campaign Member object
 **/
public with sharing class CmpnMemberSecurityContext extends SecurityContext {

    // Field constants for CampaignMember object.
    private static final String CAMPAIGNID = 'CampaignId';
    private static final String CASE_ID = 'Case_Id__c';
    private static final String CONTACTID = 'ContactId';
    private static final String STATUS = 'Status';

    // Below field(s) are use for Select/Read permission.
    private static final String ID = 'Id';

    // The fields for inserting CampaignMember in CaseUtil
    private static final Set<String> CREATE_FIELDS = new Set<String> {
        CAMPAIGNID, CASE_ID, CONTACTID
    };

    // The fields for inserting CampaignMember in EarlyOutSchedulerBatch
    private static final Set<String> SB_CREATE_FIELDS = new Set<String> {
        CAMPAIGNID, STATUS, CONTACTID
    };

    // The fields for updating CampaignMember in CaseUtil
    private static final Set<String> UPDATE_FIELDS = new Set<String> {
        CASE_ID
    };

    // The fields for selecting a Campaign Member in CallListUtilities, PreServiceSchedulerBatch, PreCollectionSchedulerBatch, CaseUtil, TaskTriggerHandler
    private static final Set<String> SELECT_FIELDS = new Set<String> {
        ID, CONTACTID, CAMPAIGNID
    };

    // The fields for selecting a Campaign Member in CaseUtil
    private static final Set<String> CU_SELECT_FIELDS = new Set<String> {
        ID, CONTACTID
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

    public CmpnMemberSecurityContext() {
    }

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
     * The select context for Campaign Member in CallListUtilities, PreServiceSchedulerBatch, PreCollectionSchedulerBatch, CaseUtil, TaskTriggerHandler
     **/
    public static final CmpnMemberSecurityContext SELECT_CONTEXT = new CmpnMemberSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * The select context for Campaign Member in CaseUtil
     **/
    public static final CmpnMemberSecurityContext CU_SELECT_CONTEXT = new CmpnMemberSecurityContext(CU_SELECT_FIELDS, ACTION.OBJ_READ);

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
        return CampaignMember.SObjectType.getDescribe().isDeletable();
    }
}