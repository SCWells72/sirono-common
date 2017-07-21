/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This class is use for Security Context of Exhausted Criteria Metadata object
 **/
public with sharing class ExhaustedCriteriaMdtSecurityContext extends SecurityContext {

    // Below field(s) are use for Select/Read permission.
    private static final String DISPOSITION_TYPE = 'Disposition_Type__c';
    private static final String MASTERLABEL = 'MasterLabel';

    // The fields for selecting a Exhausted_Criteria__mdt in TaskTriggerHandler
    private static final Set<String> SELECT_FIELDS = new Set<String>{
        MASTERLABEL, DISPOSITION_TYPE
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private ExhaustedCriteriaMdtSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }

    /**
     * The select context for Exhausted_Criteria__mdt in TaskTriggerHandler
     **/
    public static final ExhaustedCriteriaMdtSecurityContext SELECT_CONTEXT = new ExhaustedCriteriaMdtSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Exhausted_Criteria__mdt.class;
    }
}