/**
 * This class is use for Security Context of Charge Group Coverage Junction object
 **/

public with sharing class CGCoverageJunctionSecurityContext extends SecurityContext {

    // Below field(s) are use for Select/Read permission.
    private static final String CHARGE_GROUP = 'Charge_Group__c';
    private static final String COVERAGE = 'Coverage__c';
    private static final String LASTMODIFIEDDATE = 'LastModifiedDate';

    // The fields for selecting a Charge Group Coverage Junction in CreateCaseManual
    private static final Set<String> SELECT_FIELDS = new Set<String>{
        CHARGE_GROUP, COVERAGE, LASTMODIFIEDDATE
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private CGCoverageJunctionSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }

    /**
     * The select context for Charge Group Coverage Junction in CreateCaseManual
     **/
    public static final CGCoverageJunctionSecurityContext SELECT_CONTEXT = new CGCoverageJunctionSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Charge_Group_Coverage_Junction__c.class;
    }
}