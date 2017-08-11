/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
public class Five9CreateCallLogRecordTest {

    @IsTest
    static void main() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        ApexPages.currentPage().getParameters().put('Five9_ANI', 'A');
        ApexPages.currentPage().getParameters().put('Five9_DNIS', 'B');
        ApexPages.currentPage().getParameters().put('Salesforce_Id', guarantorContact.Id);
        ApexPages.currentPage().getParameters().put('Call_disposition', 'C');
        ApexPages.currentPage().getParameters().put('session_id', 'D');
        ApexPages.currentPage().getParameters().put('endTimestamp', 'E');
        ApexPages.currentPage().getParameters().put('callTypeName', 'F');
        ApexPages.currentPage().getParameters().put('campaignName', 'G');
        ApexPages.currentPage().getParameters().put('startTimestamp', 'H');
        ApexPages.currentPage().getParameters().put('fullName', 'I');

        Five9CreateCallLogRecord cc = new Five9CreateCallLogRecord();
        cc.doAction();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(0, msgList.size());
    }

    @IsTest
    static void main1() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        ApexPages.currentPage().getParameters().put('Five9_ANI', 'A');
        ApexPages.currentPage().getParameters().put('Five9_DNIS', 'B');
        ApexPages.currentPage().getParameters().put('Salesforce_Id', '');
        ApexPages.currentPage().getParameters().put('Call_disposition', 'C');
        ApexPages.currentPage().getParameters().put('session_id', 'D');
        ApexPages.currentPage().getParameters().put('endTimestamp', 'E');
        ApexPages.currentPage().getParameters().put('callTypeName', 'F');
        ApexPages.currentPage().getParameters().put('campaignName', 'G');
        ApexPages.currentPage().getParameters().put('startTimestamp', 'H');
        ApexPages.currentPage().getParameters().put('fullName', 'I');

        Five9CreateCallLogRecord cc = new Five9CreateCallLogRecord();
        cc.doAction();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(2, msgList.size());
    }
}