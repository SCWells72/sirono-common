/*
 * @author Sirono 
 * @version 1.0.1
 * @Date: 09-02-2016
 * do the code coverage for the PreCollectionSchedulerBatch class.
*/

@isTest
private class PreCollectionSchedulerBatchTest {

    @isTest
    static void main() {
        contact con = TestUtility.generateGuarantorContact();
        insert con;

        contact con1 = TestUtility.generateGuarantorContact();
        con1.LastName = 'Test';
        con1.Profile_Pointer_Id__c = 123;
        insert con1;

        contact con2 = TestUtility.generatePatientContact();
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

        Campaign c = TestUtility.generateCampaign('PreCollections');
        c.isActive = true;
        insert c;

        CampaignMember cmm = new CampaignMember(CampaignId = c.Id, ContactId = con.Id, Status = 'Sent');
        insert cmm;

        cmm = new CampaignMember(CampaignId = c.Id, ContactId = con2.Id, Status = 'Sent');
        insert cmm;

        Charge_Group__c cg = TestUtility.generateChargeGroup(con1.Id, con2.id, 1212343);
        cg.Account_Status__c = 'Billed';
        cg.Account_Sub_Status__c = 'Delinquent';
        cg.Pre_Collection_Sent__c = System.today();
        insert cg;

        Test.startTest();
        PreCollectionSchedulerBatch dpp = new PreCollectionSchedulerBatch();
        system.schedule('schJob', '0 11 22 * 9 ?', dpp);
        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(0, msgList.size());
    }

    @isTest
    static void main1() {
        contact con = TestUtility.generateGuarantorContact();
        insert con;

        contact con1 = TestUtility.generateGuarantorContact();
        con1.LastName = 'Test';
        con1.Profile_Pointer_Id__c = 123;
        insert con1;

        contact con2 = TestUtility.generatePatientContact();
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

        Campaign c = TestUtility.generateCampaign('PreCollections');
        c.isActive = true;
        insert c;

        CampaignMember cmm = new CampaignMember(CampaignId = c.Id, ContactId = con.Id, Status = 'Sent');
        insert cmm;

        cmm = new CampaignMember(CampaignId = c.Id, ContactId = con2.Id, Status = 'Sent');
        insert cmm;

        Charge_Group__c cg = TestUtility.generateChargeGroup(con1.Id, con2.id, 12122343);
        cg.Account_Status__c = 'Billed';
        cg.Account_Sub_Status__c = 'Delinquent';
        cg.Pre_Collection_Sent__c = System.today();
        insert cg;

        Transaction__c transactionObj = TestUtility.generateTransaction(cg, -110, 'Automatic');
        insert transactionObj ;


        cg = TestUtility.generateChargeGroup(con.Id, con2.id, 1212343);
        cg.Account_Status__c = 'Billed';
        cg.Account_Sub_Status__c = 'Delinquent';
        cg.Pre_Collection_Sent__c = System.today();
        insert cg;

        transactionObj = TestUtility.generateTransaction(cg, -110, 'Automatic');
        insert transactionObj ;

        Test.startTest();
        PreCollectionSchedulerBatch dpp = new PreCollectionSchedulerBatch();
        Delete [Select id from CampaignMember];
        system.schedule('schJob', '0 11 22 * 9 ?', dpp);
        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(0, msgList.size());
    }

    @isTest
    static void executBatch() {
        Test.startTest();
        PreCollectionSchedulerBatch dppc = new PreCollectionSchedulerBatch();
        Database.executeBatch(dppc);
        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(0, msgList.size());
    }
}