/**
 * This class is use for Security Context of RecordType object
 **/

public with sharing class RecordTypeSecurityContext extends SecurityContext {

    // Below field(s) are use for Select/Read permission.
    private static final String DEVELOPERNAME = 'DeveloperName;';
    private static final String ID = 'Id';
    private static final String NAME = 'Name';
    private static final String SOBJECTTYPE = 'sObjectType';

    // The fields for selecting a RecordType in CampaignMemberTriggerHandler, RecordTypeUtil
    private static final Set<String> SELECT_FIELDS = new Set<String>{
        ID, NAME, SOBJECTTYPE
    };

    // The fields for selecting a RecordType in CaseUtil
    private static final Set<String> CU_SELECT_FIELDS = new Set<String>{
        ID, SOBJECTTYPE
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private RecordTypeSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }

    /**
     * The select context for RecordType in CampaignMemberTriggerHandler, RecordTypeUtil
     **/
    public static final RecordTypeSecurityContext SELECT_CONTEXT = new RecordTypeSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * The select context for RecordType in CaseUtil
     **/
    public static final RecordTypeSecurityContext CU_SELECT_CONTEXT = new RecordTypeSecurityContext(CU_SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return RecordType.class;
    }
}