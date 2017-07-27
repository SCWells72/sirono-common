/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This class is use for Security Context of Case Charge Group Junction object
 **/
public with sharing class CaseCGJunctionSecurityContext extends SecurityContext {

    // Field constants for Case_Charge_Group_Junction__c object.
    private static final String CASE_OBJ = 'Case__c';
    private static final String CHARGE_GROUP = 'Charge_Group__c';

    // The fields for inserting CaseCGJunction in CaseUtil
    private static final Set<String> CREATE_FIELDS = new Set<String> {
        CASE_OBJ, CHARGE_GROUP
    };

    // The fields for selecting a CaseCGJunction in CaseCommentTriggerHandler
    private static final Set<String> SELECT_FIELDS = new Set<String> {
        CHARGE_GROUP, CASE_OBJ
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private CaseCGJunctionSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }

    /**
     * The create context for Case_Charge_Group_Junction__c in CaseUtil
     **/
    public static final CaseCGJunctionSecurityContext CREATE_CONTEXT = new CaseCGJunctionSecurityContext(CREATE_FIELDS, ACTION.OBJ_CREATE);

    /**
     * The delete context for Case_Charge_Group_Junction__c in CampaignMemberTriggerHandler
     **/
    public static final CaseCGJunctionSecurityContext DELETE_CONTEXT = new CaseCGJunctionSecurityContext(null, ACTION.OBJ_DELETE);

    /**
     * The select context for CaseCGJunction in CaseCommentTriggerHandler
     **/
    public static final CaseCGJunctionSecurityContext SELECT_CONTEXT = new CaseCGJunctionSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Case_Charge_Group_Junction__c.class;
    }
}