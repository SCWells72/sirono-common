/**
 * This class is use for Security Context of User Timezone Setting Metadata object
 **/

public with sharing class UserTimezoneMdtSecurityContext extends SecurityContext {

    // Below field(s) are use for Select/Read permission.
    private static final String DEVELOPERNAME = 'DeveloperName';
    private static final String ID = 'Id';
    private static final String TIMEZONE_NAME = 'Timezone_Name__c';

    // The fields for selecting a User_Timezone_Setting__mdt in TaskTriggerHandler
    private static final Set<String> SELECT_FIELDS = new Set<String>{
        ID, TIMEZONE_NAME, DEVELOPERNAME
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private UserTimezoneMdtSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }

    /**
     * The select context for User_Timezone_Setting__mdt in TaskTriggerHandler
     **/
    public static final UserTimezoneMdtSecurityContext SELECT_CONTEXT = new UserTimezoneMdtSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return User_Timezone_Setting__mdt.class;
    }
}