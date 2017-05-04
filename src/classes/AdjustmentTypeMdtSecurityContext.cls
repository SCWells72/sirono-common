/**
 * This class is use for Security Context of Adjustment Type Metadata object
 **/

public with sharing class AdjustmentTypeMdtSecurityContext extends SecurityContext {

    // Below field(s) are use for Select/Read permission.
    private static final String CODE = 'Code__c';
    private static final String DESCRIPTION = 'Description__c';
    private static final String ENABLED = 'Enabled__c';
    private static final String ID = 'Id';

    // The fields for selecting a Adjustment_Type__mdt in CreateAdjustment
    private static final Set<String> SELECT_FIELDS = new Set<String>{
        CODE, DESCRIPTION, ENABLED, ID
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private AdjustmentTypeMdtSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }

    /**
     * The select context for Adjustment_Type__mdt in CreateAdjustment
     **/
    public static final AdjustmentTypeMdtSecurityContext SELECT_CONTEXT = new AdjustmentTypeMdtSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Adjustment_Type__mdt.class;
    }
}