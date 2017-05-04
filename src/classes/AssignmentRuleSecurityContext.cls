/**
 * This class is use for Security Context of AssignmentRule object
 **/

public with sharing class AssignmentRuleSecurityContext extends SecurityContext {

    // Below field(s) are use for Select/Read permission.
    private static final String ACTIVE = 'Active';
    private static final String ID = 'Id';
    private static final String SOBJECTTYPE = 'SobjectType';

    // The fields for selecting a AssignmentRule in CreateCaseManual
    private static final Set<String> SELECT_FIELDS = new Set<String>{
        ACTIVE, ID, SOBJECTTYPE
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private AssignmentRuleSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }

    /**
     * The select context for AssignmentRule in CreateCaseManual
     **/
    public static final AssignmentRuleSecurityContext SELECT_CONTEXT = new AssignmentRuleSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return AssignmentRule.class;
    }
}