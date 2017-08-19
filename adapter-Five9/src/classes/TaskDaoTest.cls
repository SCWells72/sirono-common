/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Created by mmartin on 8/18/17.
 */
@IsTest
public with sharing class TaskDaoTest {

    @IsTest
    public static void getGuarantorsWithTaskTest() {
        Contact gt = Five9AdapterTestUtility.generateGuarantorContact();
        insert gt;

        List<Contact> contacts = TaskDao.getGuarantorsWithTask(new Set<Id> { gt.Id }, null, new Set<String> { 'Pre-collection' }, new Set<String> { 'Final' });
        // Check system assert.
        System.assertEquals(0, contacts[0].Tasks.size(), 'Should have 0 Tasks, but we got ' + contacts[0].Tasks.size());

        Task task = Five9AdapterTestUtility.generateTask(gt.Id);
        insert task;

        Test.startTest();
        contacts = TaskDao.getGuarantorsWithTask(new Set<Id> { gt.Id }, null, new Set<String> { 'Pre-collection' }, new Set<String> { 'Final' });
        Test.stopTest();

        // Check system assert.
        System.assertEquals(1, contacts[0].Tasks.size(), 'Expected contact to have 1 Task, but had ' + contacts[0].Tasks.size());
    }
}