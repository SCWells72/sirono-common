/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Tests for PreServiceSchedulerBatch.
 */
@IsTest
private class PreServiceSchedulerBatchTest {

    @IsTest
    static void main() {
        Contact con = TestUtility.generateGuarantorContact();
        insert con;

        Contact con1 = TestUtility.generateGuarantorContact();
        con1.LastName = 'Test';
        con1.Guarantor_Id__c = 123;
        insert con1;

        Contact con2 = TestUtility.generatePatientContact();
        con2.LastName = 'Test';
        con2.Guarantor_Id__c = 123456;
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

        Campaign c = TestUtility.generateCampaign(Constants.CAMPAIGN_NAME_PRESERVICE);
        c.IsActive = true;
        insert c;

        CampaignMember cmm = new CampaignMember(
            CampaignId = c.Id,
            ContactId = con.Id,
            Status = Constants.SENT
        );
        insert cmm;

        Encounter__c encounter1 = TestUtility.generateEncounter(con.Id, -10, Date.today());
        encounter1.Patient__c = con2.Id;
        encounter1.Date_Of_Service__c = System.today().addDays(2);
        encounter1.Liability__c = 101;
        encounter1.Cancelled__c = false;
        insert encounter1;

        encounter1 = TestUtility.generateEncounter(con1.Id, -10, Date.today());
        encounter1.Patient__c = con2.Id;
        encounter1.Date_Of_Service__c = System.today().addDays(2);
        encounter1.Liability__c = 101;
        encounter1.Cancelled__c = false;
        insert encounter1;

        Test.startTest();
        System.debug('encounter1' + encounter1);

        PreServiceSchedulerBatch dpp = new PreServiceSchedulerBatch();

        dpp.existingMembers = new Set<Id>();
        System.schedule('schJob', '0 11 22 * 9 ?', dpp);
        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(0, msgList.size());
    }

//Cover Existing map
    @IsTest
    static void main1() {
        Contact con = TestUtility.generateGuarantorContact();
        insert con;

        Contact con1 = TestUtility.generateGuarantorContact();
        con1.LastName = 'Test';
        con1.Guarantor_Id__c = 123;
        insert con1;

        Contact con2 = TestUtility.generatePatientContact();
        con2.LastName = 'Test';
        con2.Guarantor_Id__c = 123456;
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

        Campaign c = TestUtility.generateCampaign(Constants.CAMPAIGN_NAME_PRESERVICE);
        c.IsActive = true;
        insert c;

        CampaignMember cmm = new CampaignMember(CampaignId = c.Id, ContactId = con.Id, Status = Constants.SENT);
        insert cmm;

        Encounter__c encounter1 = TestUtility.generateEncounter(con.Id, -10, Date.today());
        encounter1.Patient__c = con2.Id;
        encounter1.Date_Of_Service__c = System.today().addDays(2);
        encounter1.Liability__c = 101;
        encounter1.Cancelled__c = false;
        insert encounter1;

        encounter1 = TestUtility.generateEncounter(con1.Id, -10, Date.today());
        encounter1.Patient__c = con2.Id;
        encounter1.Date_Of_Service__c = System.today().addDays(2);
        encounter1.Liability__c = 101;
        encounter1.Cancelled__c = false;
        insert encounter1;

        Test.startTest();
        System.debug('encounter1' + encounter1);
//insert cmm;

        PreServiceSchedulerBatch dpp = new PreServiceSchedulerBatch();
        delete [SELECT Id FROM CampaignMember];
        System.debug('12212' + [SELECT Id FROM CampaignMember]);
        dpp.existingMembers = new Set<Id>();
        System.schedule('schJob', '0 11 22 * 9 ?', dpp);
        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(0, msgList.size());
    }

    @IsTest
    static void executBatch() {
        Test.startTest();

        PreServiceSchedulerBatch dppc = new PreServiceSchedulerBatch();
        dppc.existingMembers = new Set<Id>();
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