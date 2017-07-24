/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This class is use for Security Context of Encounter__c object
 **/
public with sharing class EncounterSecurityContext extends SecurityContext {
	
    // Field constants for Encounter__c object
    private static final String BILLED_CHARGE_GROUP_COUNT = 'Billed_Charge_Group_Count__c';
    private static final String TOTAL_PAYMENTS = 'Total_Payments__c';

    // Below field(s) are used for Select/Read permission.
    private static final String BALANCE = 'Balance__c';
    private static final String CANCELLED = 'Cancelled__c';
    private static final String DATE_OF_SERVICE = 'Date_of_Service__c';
    private static final String ESTIMATE_ID = 'Estimate_ID__c';
    private static final String GUARANTOR = 'Guarantor__c';
    private static final String ID = 'Id';
    private static final String INSURANCE_DISCOUNT = 'Insurance_Discount__c';
    private static final String INSURANCE_PORTION = 'Insurance_Portion__c';
    private static final String LIABILITY = 'Liability__c';
    private static final String LOCATION = 'Location__c';
    private static final String NAME = 'Name';
    private static final String ORDERING_PHYSICIAN = 'Ordering_Physician__c';
    private static final String PATIENT = 'Patient__c';
    private static final String PATIENT_PORTION = 'Patient_Portion__c';
    private static final String PROCEDURE = 'Procedure__c';
    private static final String TOTAL_CHARGES = 'Total_Charges__c';
    private static final String TYPE = 'Type__c';

    // The fields for updating a Encounter__c's Total_Payments__c field in EncounterUtil.
    private static final Set<String> UPDATE_FIELDS = new Set<String>{
    	TOTAL_PAYMENTS
    };

    // The fields for updating a Encounter__c's Billed_Charge_Group_Count__c field in EncounterUtil.
    private static final Set<String> UPDATE_BILLED_CG_COUNT_FIELDS = new Set<String>{
        BILLED_CHARGE_GROUP_COUNT
    };

    // The fields for selecting a Encounter__c in EncounterDao
    private static final Set<String> SELECT_FIELDS = new Set<String>{
        ID, NAME, PATIENT, DATE_OF_SERVICE, INSURANCE_DISCOUNT, INSURANCE_PORTION, ORDERING_PHYSICIAN, PROCEDURE,
        LOCATION, PATIENT_PORTION, PROCEDURE, GUARANTOR, BALANCE, TOTAL_PAYMENTS, BALANCE, TYPE
    };

    // The fields for selecting a Encounter__c in CallListUtilities
    private static final Set<String> CLU_SELECT_FIELDS = new Set<String>{
        ID, DATE_OF_SERVICE, LIABILITY, CANCELLED
    };

    // The fields for selecting a Encounter__c in EncounterUtil.
    private static final Set<String> EU_SELECT_FIELDS = new Set<String>{
        ID, GUARANTOR
    };

    // The fields for selecting Encounter__c in EncounterUtil.
    private static final Set<String> EU_SELECT_FIELDS_AGG = new Set<String>{
        GUARANTOR, BALANCE
    };

    // The fields for selecting Encounter__c in PreServiceSchedulerBatch
    private static final Set<String> PSS_SELECT_FIELDS = new Set<String>{
        ID, NAME, GUARANTOR, LIABILITY, DATE_OF_SERVICE, CANCELLED
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
     * The update context for Encounter__c's Billed_Charge_Group_Count__c field in EncounterUtil
     **/
    public static final EncounterSecurityContext UPDATE_BILLED_CG_COUNT_CONTEXT = new EncounterSecurityContext(UPDATE_BILLED_CG_COUNT_FIELDS, ACTION.OBJ_UPDATE);

    /**
     * The select context for Encounter__c in EncounterDao
     **/
    public static final EncounterSecurityContext SELECT_CONTEXT = new EncounterSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * The select context for Encounter__c in CallListUtilities
     **/
    public static final EncounterSecurityContext CLU_SELECT_CONTEXT = new EncounterSecurityContext(CLU_SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * The select context for Encounter__c in EncounterUtil
     **/
    public static final EncounterSecurityContext EU_SELECT_CONTEXT = new EncounterSecurityContext(EU_SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * The select context for Encounter__c in EncounterUtil
     **/
    public static final EncounterSecurityContext EU_SELECT_CONTEXT_AGG = new EncounterSecurityContext(EU_SELECT_FIELDS_AGG, ACTION.OBJ_READ);

    /**
     * The select context for Encounter__c in PreServiceSchedulerBatch
     **/
    public static final EncounterSecurityContext PSS_SELECT_CONTEXT = new EncounterSecurityContext(PSS_SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Encounter__c.class;
    }
}