/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This class is use for Security Context of Task object
 **/
public with sharing class TaskSecurityContext extends SecurityContext {

    // Field constants for Task object.
    private static final String ACTIVITYDATE = 'ActivityDate';
    private static final String CALLDISPOSITION = 'CallDisposition';
    private static final String FIVE9_FIVE9AGENTNAME = 'Five9__Five9AgentName__c';
    private static final String FIVE9_FIVE9ANI = 'Five9__Five9ANI__c';
    private static final String FIVE9_FIVE9CALLTYPE = 'Five9__Five9CallType__c';
    private static final String FIVE9_FIVE9CAMPAIGN = 'Five9__Five9Campaign__c';
    private static final String FIVE9_FIVE9DNIS = 'Five9__Five9DNIS__c';
    private static final String FIVE9_FIVE9SESSIONID = 'Five9__Five9SessionId__c';
    private static final String HOURS_OF_DAY = 'Hours_Of_Day__c';
    private static final String STATUS = 'Status';
    private static final String WHOID = 'WhoId';

    // Below field(s) are use for Select/Read permission.
    private static final String ID = 'Id';
    private static final String WHATID = 'WhatId';

    // The fields for updating a Task in TaskTriggerHandler
    private static final Set<String> UPDATE_FIELDS = new Set<String> {
        HOURS_OF_DAY
    };

    // The fields for selecting a Task in TaskTriggerHandler
    private static final Set<String> SELECT_FIELDS = new Set<String> {
        CALLDISPOSITION, WHOID, FIVE9_FIVE9CAMPAIGN, WHATID, ID, FIVE9_FIVE9SESSIONID
    };

    // The fields for inserting a Task in MissedCallReportProcessor
    private static final Set<String> INSERT_FIELDS = new Set<String> {
        WHOID, FIVE9_FIVE9ANI, FIVE9_FIVE9DNIS, CALLDISPOSITION, FIVE9_FIVE9SESSIONID, FIVE9_FIVE9CALLTYPE,
        FIVE9_FIVE9CAMPAIGN, FIVE9_FIVE9AGENTNAME, ACTIVITYDATE, STATUS
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
     * The update context for Task in TaskTriggerHandler
     **/
    public static final TaskSecurityContext UPDATE_CONTEXT = new TaskSecurityContext(UPDATE_FIELDS, ACTION.OBJ_UPDATE);

    /**
     * The select context for Task in TaskTriggerHandler
     **/
    public static final TaskSecurityContext SELECT_CONTEXT = new TaskSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * The upsert context for Task in MissedCallReportHandler
     **/
    public static final TaskSecurityContext INSERT_CONTEXT = new TaskSecurityContext(INSERT_FIELDS, ACTION.OBJ_UPSERT);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Task.class;
    }
}