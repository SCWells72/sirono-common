/**
 * This class is use for Security Context of Case object
 **/
 
public with sharing class CaseSecurityContext extends SecurityContext {

    // Field constants for Case objects.
    private static final String PATIENT = 'Patient__c';
    private static final String CONTACTID = 'ContactId';
    private static final String ENCOUNTER = 'Encounter__c';
    private static final String ESTIMATE_BALANCE = 'Estimate_Balance__c';
    private static final String GUARANTOR_INFORMATION = 'Guarantor_Information__c';
    private static final String ORIGIN = 'Origin';
    private static final String OWNERID = 'ownerId';
    private static final String REASON = 'Reason';
    private static final String RECORDTYPEID = 'RecordTypeID';
    private static final String STATUS = 'Status';
    private static final String SUBJECT = 'Subject';
    private static final String TYPE = 'Type';

    // Below field(s) are use for Select/Read permission.
    private static final String CHARGE_GROUP_IDS = 'Charge_Group_IDs__c';
    private static final String DESCRIPTION = 'Description';
    private static final String ID = 'Id';
    private static final String ISCLOSED = 'IsClosed';

    // The fields for inserting a Case in Campaign Member Trigger Handler
    private static final Set<String> CMT_CREATE_FIELDS = new Set<String>{
        CONTACTID, ORIGIN, RECORDTYPEID, STATUS, SUBJECT, TYPE
    };
    
    // The fields for inserting Case with Encounter in CaseUtil
    private static final Set<String> CREATE_WITH_ENCOUNTER_FIELDS = new Set<String>{
        CONTACTID, ENCOUNTER, GUARANTOR_INFORMATION, OWNERID, RECORDTYPEID, STATUS, SUBJECT, TYPE
    };
    
    // The fields for inserting Case in CaseUtil
    private static final Set<String> CU_CREATE_FIELDS = new Set<String>{
        CONTACTID, GUARANTOR_INFORMATION, OWNERID, RECORDTYPEID, STATUS, SUBJECT, TYPE
    };
    
    // The fields for updating Case in CaseUtil & TaskTriggerHandler
    private static final Set<String> UPDATE_FIELDS = new Set<String>{
        REASON, STATUS
    };
    
    // The fields for upserting a Case in CreateCaseManual
    private static final Set<String> UPSERT_FIELDS = new Set<String>{
        CONTACTID, GUARANTOR_INFORMATION, PATIENT, REASON, RECORDTYPEID, SUBJECT
    };

    // The fields for selecting a Case in CaseTriggerHandler
    private static final Set<String> SELECT_FIELDS = new Set<String>{
        ID, DESCRIPTION, CHARGE_GROUP_IDS
    };

    // The fields for selecting a Case in CaseUtil, TaskTriggerHandler
    private static final Set<String> CU_SELECT_FIELDS = new Set<String>{
        ID, GUARANTOR_INFORMATION, REASON, ISCLOSED, TYPE, STATUS, ENCOUNTER
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private CaseSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }

    /**
     * The context used to create a Case in the CampaignMemberTriggerHandler
     **/
    public static final CaseSecurityContext CREATE_CONTEXT = new CaseSecurityContext(CMT_CREATE_FIELDS, ACTION.OBJ_CREATE);

    /**
     * The context used to create a Case with a Guarantor in CaseUtil
     **/
    public static final CaseSecurityContext CREATE_WITH_GT_CONTEXT = new CaseSecurityContext(CU_CREATE_FIELDS, ACTION.OBJ_CREATE);

    /**
     * The context used to create a Case with an Encounter in CaseUtil
     **/
    public static final CaseSecurityContext CU_CREATE_WITH_ENCOUNTER_CONTEXT = new CaseSecurityContext(CREATE_WITH_ENCOUNTER_FIELDS, ACTION.OBJ_CREATE);
    
    /**
     * The context used to update a Case in CaseUtil & TaskTriggerHandler
     **/
    public static final CaseSecurityContext UPDATE_CONTEXT = new CaseSecurityContext(UPDATE_FIELDS, ACTION.OBJ_UPDATE);

    /**
     * The context used to upsert a Case in CreateCaseManual
     **/
    public static final CaseSecurityContext UPSERT_CONTEXT = new CaseSecurityContext(UPSERT_FIELDS, ACTION.OBJ_UPSERT);

     /**
     * The delete context for a Case in SecurityUtilsTest.
     **/
    public static final CaseSecurityContext DELETE_CONTEXT = new CaseSecurityContext(null, ACTION.OBJ_DELETE);

    /**
     * The select context for Case in CaseTriggerHandler
     **/
    public static final CaseSecurityContext SELECT_CONTEXT = new CaseSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * The select context for Case in CaseUtil, TaskTriggerHandler
     **/
    public static final CaseSecurityContext CU_SELECT_CONTEXT = new CaseSecurityContext(CU_SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Case.class;
    }
}