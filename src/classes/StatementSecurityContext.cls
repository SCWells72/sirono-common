/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This class is use for Security Context of Statement__c object
 **/
public with sharing class StatementSecurityContext extends SecurityContext {

    // Below field(s) are use for Select/Read permission.
    private static final String GUARANTOR = 'Guarantor__c';
    private static final String ID = 'Id';
    private static final String NAME = 'Name';
    private static final String STATEMENT_DATE = 'Statement_Date__c';

    // The fields for selecting a Statement in DelinquentPaymentPlansSchedulerBatch
    private static final Set<String> SELECT_FIELDS = new Set<String>{
        ID, NAME, STATEMENT_DATE
    };

    // The fields for selecting a Statement in CaseUtil
    private static final Set<String> CU_SELECT_FIELDS = new Set<String>{
        ID, GUARANTOR, STATEMENT_DATE
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private StatementSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }

    /**
     * The select context for Statement in DelinquentPaymentPlansSchedulerBatch
     **/
    public static final StatementSecurityContext SELECT_CONTEXT = new StatementSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * The select context for Statement in CaseUtil
     **/
    public static final StatementSecurityContext CU_SELECT_CONTEXT = new StatementSecurityContext(CU_SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Statement__c.class;
    }
}