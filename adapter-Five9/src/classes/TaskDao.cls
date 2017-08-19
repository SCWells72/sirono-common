/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * DB functionality for Task DML operations.
 */
public with sharing class TaskDao {

    private static void assertAccessible(SObjectType type) {
        if (!type.getDescribe().isAccessible()) {
            throw new System.SecurityException('User does not have read access for '+type.getDescribe().name);
        }
    }

    private static void assertUpdateable(SObjectType type) {
        if (!type.getDescribe().isUpdateable()) {
            throw new System.SecurityException('User does not have update permissions for '+type.getDescribe().name);
        }
    }

    private static void assertDeletable(SObjectType type) {
        if (!type.getDescribe().isDeletable()) {
            throw new System.SecurityException('User does not have delete permissions for '+type.getDescribe().name);
        }
    }

    private static void assertCreatable(SObjectType type) {
        if (!type.getDescribe().isCreateable()) {
            throw new System.SecurityException('User does not have create permissions for '+type.getDescribe().name);
        }
    }

    /**
     * @description Take a list of tasks and if allowed upsert those tasks.
     *
     * @param List<Task> - tasks that are to be upserted.
     **/
    public static void upsertTasks(List<Task> tasks) {
        assertCreatable(Task.SObjectType);
        assertUpdateable(Task.SObjectType);

        try {
            upsert tasks;
        } catch (DmlException de) {
            System.debug('The upsert operation failed with message: ' + de.getMessage());
            throw de;
        }
    }

    /**
     * @description Method that queries for and returns existing Salesforce Ids.
     *
     * @param whoIds Contact Id to be verified.
     **/
    public static Map<Id, Contact> getValidWhoIds(Set<Id> whoIds) {
        assertAccessible(Contact.SObjectType);
        Map<Id, Contact> contactMap = new Map<Id, Contact>([
            SELECT Id
            FROM Contact
            WHERE Id IN :whoIds
        ]);

        return contactMap;
    }

    /**
     * @description Method that queries for and returns existing Tasks that have a given Five9 session Id.
     *
     * @param five9SessionIds Five9 supplied session Ids
     **/
    public static Map<String, Task> getTasksBySessionId(Set<String> five9SessionIds) {
        assertAccessible(Task.SObjectType);
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

    /**
     * Get Contacts with Task based on contactIds, caseIds, five9Campaigns and callDispositions
     *
     * @param Set<Id> contactIds - A set of Contact Ids.
     * @param Set<Id> caseIds - A set of Case Ids.
     * @param Set<String> five9Campaigns - That contains five9Campaign names.
     * @param Set<String> callDispositions - That contains call disposition values.
     * @returns List<Contact> - The requested Contacts with Task that meet the criteria.
     **/
    public static List<Contact> getGuarantorsWithTask(Set<Id> contactIds, Set<Id> caseIds, Set<String> five9Campaigns, Set<String> callDispositions) {
        assertAccessible(Contact.SObjectType);
        assertAccessible(Task.SObjectType);

        String queryString = 'SELECT Id, FirstName, LastName, ';
        queryString += '( ';
        queryString += 'SELECT Id, CallDisposition, Five9__Five9Campaign__c, WhatId ';
        queryString += 'FROM Tasks ';
        queryString += (caseIds != null) ? 'WHERE WhatId IN :caseIds AND CallDisposition != null AND WhoId != null ' : 'WHERE CallDisposition IN :callDispositions ';
        queryString += 'AND Five9__Five9Campaign__c IN :five9Campaigns';
        queryString += ') ';
        queryString += 'FROM Contact ';
        queryString += 'WHERE Id IN :contactIds';

        return Database.query(queryString);
    }
}