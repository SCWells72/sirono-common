/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Test class for DelinquentPaymentPlansSchedulerBatch.
 */
@IsTest
public class DelinquentPaymentPlansSchedulerBatchTest {
    static testMethod void main() {
        Contact con = TestUtility.generateGuarantorContact();
        insert con;

        Contact con1 = TestUtility.generateGuarantorContact();
        con1.LastName = 'Test';
        con1.Guarantor_Id__c = 123;
        insert con1;

        Date dt = System.today().addDays(-10);

        Payment_Plan__c t = TestUtility.generatePaymentPlan(con.Id);
        t.Remaining_Balance__c = -120;
        t.Active__c = true;
        t.Delinquent_Date__c = dt;
        insert t;

        Payment_Plan__c t1 = TestUtility.generatePaymentPlan(con1.Id);
        t1.Remaining_Balance__c = -120;
        t1.Active__c = true;
        t1.Delinquent_Date__c = dt;
        insert t1;

        Campaign c = TestUtility.generateCampaign(Constants.CAMPAIGN_NAME_PAST_DUE);
        c.IsActive = true;
        insert c;

        CampaignMember cmm = new CampaignMember(CampaignId = c.Id, ContactId = con.Id, Status = Constants.SENT);
        insert cmm;

        Test.startTest();
        DelinquentPaymentPlansSchedulerBatch dpp = new DelinquentPaymentPlansSchedulerBatch();
        System.schedule('schJob', '0 11 22 * 9 ?', dpp);
        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(0, msgList.size());
    }

    static testMethod void pain() {
        Test.startTest();
        DelinquentPaymentPlansSchedulerBatch dppc = new DelinquentPaymentPlansSchedulerBatch();
        Database.executeBatch(dppc);
        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(0, msgList.size());
    }
}