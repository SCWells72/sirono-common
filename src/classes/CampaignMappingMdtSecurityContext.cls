/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This class is use for Security Context of Campaign Mapping Metadata object
 **/
public with sharing class CampaignMappingMdtSecurityContext extends SecurityContext {

    // Below field(s) are use for Select/Read permission.
    private static final String MASTERLABEL = 'MasterLabel';
    private static final String SALESFORCE_CAMPAIGN_NAME = 'Salesforce_Campaign_Name__c';

    // The fields for selecting a Campaign_Mapping__mdt in TaskTriggerHandler, CaseUtil
    private static final Set<String> SELECT_FIELDS = new Set<String> {
        MASTERLABEL, SALESFORCE_CAMPAIGN_NAME
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private CampaignMappingMdtSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }

    /**
     * The select context for Campaign_Mapping__mdt in TaskTriggerHandler, CaseUtil
     **/
    public static final CampaignMappingMdtSecurityContext SELECT_CONTEXT = new CampaignMappingMdtSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Campaign_Mapping__mdt.class;
    }
}