/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This class is use for Security Context of Campaign object
 **/
public with sharing class CampaignSecurityContext extends SecurityContext {

    // Below field(s) are use for Select/Read permission.
    private static final String ID = 'Id';
    private static final String ISACTIVE = 'isActive';
    private static final String NAME = 'Name';

    // The fields for selecting a Campaign in DelinquentPaymentPlansSchedulerBatch, TaskTriggerHandler,
    // PreServiceSchedulerBatch, PreCollectionSchedulerBatch, CaseUtil
    private static final Set<String> SELECT_FIELDS = new Set<String> {
        ID, NAME, ISACTIVE
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private CampaignSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }

    /**
     * The select context for Campaign in DelinquentPaymentPlansSchedulerBatch, TaskTriggerHandler,
     * PreServiceSchedulerBatch, PreCollectionSchedulerBatch, CaseUtil
     **/
    public static final CampaignSecurityContext SELECT_CONTEXT = new CampaignSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Campaign.class;
    }
}