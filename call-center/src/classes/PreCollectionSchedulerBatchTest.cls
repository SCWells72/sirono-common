/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Tests for PreCollectionSchedulerBatch.
*/
@IsTest
private class PreCollectionSchedulerBatchTest {

    @IsTest
    static void main() {
        Contact con = TestUtility.generateGuarantorContact();
        insert con;

        Contact con1 = TestUtility.generateGuarantorContact();
        con1.LastName = 'Test';
        con1.Profile_Pointer_Id__c = 123;
        insert con1;

        Contact con2 = TestUtility.generatePatientContact();
        con2.LastName = 'Test';
        con2.Profile_Pointer_Id__c = 123456;
        con2.Guarantor__c = con1.Id;
        insert con2;

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

        Campaign c = TestUtility.generateCampaign(Constants.CAMPAIGN_NAME_PRECOLLECTIONS);
        c.IsActive = true;
        insert c;

        CampaignMember cmm = new CampaignMember(
            CampaignId = c.Id,
            ContactId = con.Id,
            Status = Constants.SENT
        );
        insert cmm;

        cmm = new CampaignMember(CampaignId = c.Id, ContactId = con2.Id, Status = Constants.SENT);
        insert cmm;

        Charge_Group__c cg = TestUtility.generateChargeGroup(con1.Id, con2.Id, 1212343);
        cg.Account_Status__c = Constants.ACCT_STATUS_BILLED;
        cg.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        cg.Pre_Collection_Sent__c = System.today();
        insert cg;

        Test.startTest();
        PreCollectionSchedulerBatch dpp = new PreCollectionSchedulerBatch();
        System.schedule('schJob', '0 11 22 * 9 ?', dpp);
        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(0, msgList.size());
    }

    @IsTest
    static void main1() {
        Contact con = TestUtility.generateGuarantorContact();
        insert con;

        Contact con1 = TestUtility.generateGuarantorContact();
        con1.LastName = 'Test';
        con1.Profile_Pointer_Id__c = 123;
        insert con1;

        Contact con2 = TestUtility.generatePatientContact();
        con2.LastName = 'Test';
        con2.Profile_Pointer_Id__c = 123456;
        con2.Guarantor__c = con1.Id;
        insert con2;

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

        Campaign c = TestUtility.generateCampaign(Constants.CAMPAIGN_NAME_PRECOLLECTIONS);
        c.IsActive = true;
        insert c;

        CampaignMember cmm = new CampaignMember(CampaignId = c.Id, ContactId = con.Id, Status = Constants.SENT);
        insert cmm;

        cmm = new CampaignMember(CampaignId = c.Id, ContactId = con2.Id, Status = Constants.SENT);
        insert cmm;

        Charge_Group__c cg = TestUtility.generateChargeGroup(con1.Id, con2.Id, 12122343);
        cg.Account_Status__c = Constants.ACCT_STATUS_BILLED;
        cg.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        cg.Pre_Collection_Sent__c = System.today();
        insert cg;

        Transaction__c transactionObj = TestUtility.generateTransaction(cg, -110, Constants.AUTOMATIC);
        insert transactionObj ;

        cg = TestUtility.generateChargeGroup(con.Id, con2.Id, 1212343);
        cg.Account_Status__c = Constants.ACCT_STATUS_BILLED;
        cg.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        cg.Pre_Collection_Sent__c = System.today();
        insert cg;

        transactionObj = TestUtility.generateTransaction(cg, -110, Constants.AUTOMATIC);
        insert transactionObj ;

        Test.startTest();
        PreCollectionSchedulerBatch dpp = new PreCollectionSchedulerBatch();
        delete [SELECT Id FROM CampaignMember];
        System.schedule('schJob', '0 11 22 * 9 ?', dpp);
        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(0, msgList.size());
    }

    @IsTest
    static void executBatch() {
        Test.startTest();
        PreCollectionSchedulerBatch dppc = new PreCollectionSchedulerBatch();
        Database.executeBatch(dppc);
        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(0, msgList.size());
    }
    
    /**
     * Check all access rights for a read only User using runAs.
     **/
    @IsTest
    static void checkAccessRights() {
        List<CmpnMemberSecurityContext> allContexts = new List<CmpnMemberSecurityContext> {
            CmpnMemberSecurityContext.CREATE_CONTEXT,
            CmpnMemberSecurityContext.UPDATE_CONTEXT
        };

        System.runAs(TestUtility.generateReadOnlyUser()) {
            for (CmpnMemberSecurityContext context : allContexts) {
                try {
                    context.actionAllowed();
                    System.assert(false, 'Expected permission to be denied for ' + context);
                } catch (SecurityUtils.SecurityException ex) {
                    System.debug('SecurityException : ' + ex);
                } catch (Exception e) {
                    System.assert(false, 'Expected SecurityUtils.SecurityException to be thrown, but got ' + e);
                }
            }
        }
    }
}