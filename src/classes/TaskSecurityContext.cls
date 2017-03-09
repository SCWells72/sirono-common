/**
 * This class is use for Security Context of Task object
 **/

public with sharing class TaskSecurityContext extends SecurityContext {

    // Field constants for Task object.
    private static final String ACTIVITYDATE = 'ActivityDate';
    private static final String CALLDISPOSITION = 'CallDisposition';
    private static final String FIVE9_FIVE9AGENTNAME = 'Five9__Five9ANI__c';
    private static final String FIVE9_FIVE9ANI = 'Five9__Five9AgentName__c';
    private static final String FIVE9_FIVE9CALLTYPE = 'Five9__Five9CallType__c';
    private static final String FIVE9_FIVE9CAMPAIGN = 'Five9__Five9Campaign__c';
    private static final String FIVE9_FIVE9DNIS = 'Five9__Five9DNIS__c';
    private static final String FIVE9_FIVE9SESSIONID = 'Five9__Five9SessionId__c';
    private static final String HOURS_OF_DAY = 'Hours_of_Day__c';
    private static final String STATUS = 'Status';
    private static final String WHOID = 'WhoId';

    // The fields for inserting a Task in Five9CreateCallLogRecord
    private static final Set<String> CREATE_FIELDS = new Set<String>{
    	ACTIVITYDATE, CALLDISPOSITION, FIVE9_FIVE9AGENTNAME, FIVE9_FIVE9ANI,
        FIVE9_FIVE9CALLTYPE, FIVE9_FIVE9CAMPAIGN, FIVE9_FIVE9DNIS, FIVE9_FIVE9SESSIONID, STATUS, WHOID
    };

    // The fields for updating a Task in TaskTriggerHandler
    private static final Set<String> UPDATE_FIELDS = new Set<String>{
    	HOURS_OF_DAY
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private TaskSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }

    /**
     * The context used to create a Task in Five9CreateCallLogRecord
     **/
    public static final TaskSecurityContext CREATE_CONTEXT = new TaskSecurityContext(CREATE_FIELDS, ACTION.OBJ_CREATE);

    /**
     * The update context for Task in TaskTriggerHandler
     **/
    public static final TaskSecurityContext UPDATE_CONTEXT = new TaskSecurityContext(UPDATE_FIELDS, ACTION.OBJ_UPDATE);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Task.class;
    }
    
    /**
     * Override deleteActionAllowed method of SecurityContext class
     **/
    public override Boolean deleteActionAllowed() { 	
        return Task.sObjectType.getDescribe().isDeletable();
    }
}