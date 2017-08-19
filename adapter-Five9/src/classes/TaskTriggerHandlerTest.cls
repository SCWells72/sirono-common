/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Test class for TaskTriggerHandler.
 **/
@IsTest
private class TaskTriggerHandlerTest {
    
    /**
     * This test method test the Campagin Member removed or not based on Task record.
     * This method also test Call Hour of Day of the Task. When Task is created/updated at that time based on date it's calculate
     *	Hours.
     **/
    @IsTest
    static void testRemoveCampaignMember() {
        // Create Guarantor Contact Record.
        Contact guarantorContact = Five9AdapterTestUtility.generateGuarantorContact();
        insert guarantorContact;

        // Create Campaign Record.
        Campaign campaign = Five9AdapterTestUtility.generateCampaign('Pre-collection');
        insert campaign;

        // Create Campaign Member Record.
        CampaignMember campaignMember = Five9AdapterTestUtility.generateCampaignMember(campaign.Id, guarantorContact.Id);
        insert campaignMember;

        // Create Tasks Records.
        List<Task> taskListToInsert = new List<Task>();
        Task objTask = Five9AdapterTestUtility.generateTask(guarantorContact.Id);
        objTask.CallDisposition = 'Final';
        taskListToInsert.add(objTask);

        objTask = Five9AdapterTestUtility.generateTask(guarantorContact.Id);
        objTask.CallDisposition = 'Retry';
        taskListToInsert.add(objTask);

        objTask = Five9AdapterTestUtility.generateTask(guarantorContact.Id);
        objTask.CallDisposition = 'Error';
        taskListToInsert.add(objTask);

        Test.startTest();
        // Check system assert.
        List<CampaignMember> lstCampaignMember = [SELECT Id FROM CampaignMember];
        System.assertEquals(1, lstCampaignMember.size());

        insert taskListToInsert;
        // Check system assert.
        lstCampaignMember = [SELECT Id FROM CampaignMember];
        System.assertEquals(0, lstCampaignMember.size());

        update taskListToInsert[0];
        // Check system assert.
        List<Task> lstTask = [SELECT Id, sPRS__Hours_Of_Day__c FROM Task WHERE Id = :taskListToInsert[0].Id];
        System.assertNotEquals(lstTask[0].sPRS__Hours_Of_Day__c, null);
        Test.stopTest();
    }
}