/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Created by mmartin on 8/18/17.
 */

@IsTest
public with sharing class Five9AdapterTestUtility {


    public static Contact generateGuarantorContact() {
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Contact' AND Name = 'Guarantor'];

        Contact guarantorContact = new Contact(LastName = 'Test Guarantor',
            RecordTypeId = rt.Id,
            sPRS__Guarantor_Id__c = Decimal.valueOf(Math.random()));

        return guarantorContact;
    }

    // return Task record
    public static Task generateTask(Id guarantorContactId) {
        Task objTask = new Task();
        objTask.WhoId = guarantorContactId;
        objTask.Priority = Five9AdapterConstants.TASK_PRIORITY_NORMAL;
        objTask.Status = Five9AdapterConstants.TASK_STATUS_NEW;
        objTask.CallDisposition = 'Final';
        objTask.Five9__Five9Campaign__c = 'Pre-collection';
        return objTask;
    }


    // Return a new campaign record
    public static Campaign generateCampaign(String name) {
        Campaign objCampaign = new Campaign();
        objCampaign.Name = name;
        objCampaign.IsActive = true;
        return objCampaign;
    }

    // return CampaignMember record
    public static CampaignMember generateCampaignMember(Id campaignId, Id guarantorContactId) {
        CampaignMember objcampaignMember = new CampaignMember();
        objcampaignMember.CampaignId = campaignId;
        objcampaignMember.ContactId = guarantorContactId;
        objcampaignMember.Status = 'Sent';
        return objcampaignMember;
    }
}