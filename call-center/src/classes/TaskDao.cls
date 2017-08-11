/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * DB functionality for Task DML operations.
 */
public with sharing class TaskDao extends AbstractDao {
    /**
     * @description Take a list of tasks and if allowed upsert those tasks.
     *
     * @param List<Task> - tasks that are to be upserted.
     **/
    public static void insertTasks(List<Task> tasks) {
        if (TaskSecurityContext.INSERT_CONTEXT.actionAllowed()) {
            try {
                upsert tasks;
            } catch (DmlException de) {
                System.debug('The upsert operation failed with message: ' + de.getMessage());
                throw de;
            }
        }
    }

    /**
     * @description Method that queries for and returns existing Salesforce Ids.
     *
     * @param whoIds Contact Id to be verified.
     **/
    public static Map<Id, Contact> getValidWhoIds(Set<Id> whoIds) {
        if (ContactSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            Map<Id, Contact> contactMap = new Map<Id, Contact>([
                SELECT Id
                FROM Contact
                WHERE Id IN :whoIds
            ]);

            return contactMap;
        }

        return null;
    }

    /**
     * @description Method that queries for and returns existing Tasks that have a given Five9 session Id.
     *
     * @param five9SessionIds Five9 supplied session Ids
     **/
    public static Map<String, Task> getTasksBySessionId(Set<String> five9SessionIds) {
        if (ContactSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            List<Task> existingFive9Tasks = [
                SELECT Five9__Five9SessionId__c, Id
                FROM Task
                WHERE Five9__Five9SessionId__c IN :five9SessionIds
            ];

            Map<String, Task> taskMap = new Map<String, Task>();
            for (Task task : existingFive9Tasks) {
                taskMap.put(task.Five9__Five9SessionId__c, task);
            }

            return taskMap;
        }

        return null;

    }
}