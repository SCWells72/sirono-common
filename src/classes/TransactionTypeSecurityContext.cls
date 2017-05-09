/**
 * This class is use for Security Context of Transaction_Type__c object
 **/

public with sharing class TransactionTypeSecurityContext extends SecurityContext {

    // Below field(s) are use for Select/Read permission.
    private static final String CODE = 'Code__c';
    private static final String ID = 'Id';

    // The fields for selecting a Transaction_Type__c in PaymentAdjustmentJSONParsing
    private static final Set<String> SELECT_FIELDS = new Set<String>{
        ID, CODE
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private TransactionTypeSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }

    /**
     * The select context for Transaction_Type__c in PaymentAdjustmentJSONParsing
     **/
    public static final TransactionTypeSecurityContext SELECT_CONTEXT = new TransactionTypeSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Transaction_Type__c.class;
    }
}