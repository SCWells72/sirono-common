/*
 * @author Sirono 
 * @version 1.0.1
 * @Date: 09-02-2016
 * do the code coverage for the PreServiceSchedulerBatch class.
*/

@isTest
private class PreServiceSchedulerBatchTest {

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
    con2.Guarantor__c =con1.Id;
    insert con2;

    Date dt = System.today().addDays(-10);

    test__c t = TestUtility.generatePaymentPlan(con.Id);
    t.Payable_Amount__c = -120;
    t.Active__c = true;
    t.Delinquent_Date__c = dt;
    insert t;

    test__c t1 = TestUtility.generatePaymentPlan(con1.Id);
    t1.Payable_Amount__c = -120;
    t1.Active__c = true;
    t1.Delinquent_Date__c = dt;
    insert t1;

    Campaign c = TestUtility.generateCampaign('PreService');
    c.isActive = true;
    insert c;

    CampaignMember cmm = new CampaignMember(CampaignId = c.Id, ContactId = con.Id, Status = 'Sent');
    insert cmm;

    Encounter__c encounter1 = TestUtility.generateEncounter(con.Id, -10, Date.today());
    encounter1.Patient__c = con2.Id;
    encounter1.Date_of_Service__c = System.today().addDays(2);
    encounter1.Liability__c = 101;
    encounter1.Cancelled__c = false;
    insert encounter1;

    encounter1 = TestUtility.generateEncounter(con1.Id, -10, Date.today());
    encounter1.Patient__c = con2.Id;
    encounter1.Date_of_Service__c = System.today().addDays(2);
    encounter1.Liability__c = 101;
    encounter1.Cancelled__c = false;
    insert encounter1;

    Test.startTest();
System.debug('encounter1' + encounter1);

PreServiceSchedulerBatch dpp = new PreServiceSchedulerBatch();

dpp.existingMembers = new Set<Id>();
system.schedule('schJob', '0 11 22 * 9 ?', dpp);
Test.stopTest();

List<ApexPages.Message> msgList = ApexPages.getMessages();
System.assertEquals(0, msgList.size());
}

//Cover Existing map
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
con2.Guarantor__c =con1.Id;
insert con2;

Date dt = System.today().addDays(-10);

test__c t = TestUtility.generatePaymentPlan(con.Id);
t.Payable_Amount__c = -120;
t.Active__c = true;
t.Delinquent_Date__c = dt;
insert t;

test__c t1 = TestUtility.generatePaymentPlan(con1.Id);
t1.Payable_Amount__c = -120;
t1.Active__c = true;
t1.Delinquent_Date__c = dt;
insert t1;

Campaign c = TestUtility.generateCampaign('PreService');
c.isActive = true;
insert c;

CampaignMember cmm = new CampaignMember(CampaignId = c.Id, ContactId = con.Id, Status = 'Sent');
insert cmm;

Encounter__c encounter1 = TestUtility.generateEncounter(con.Id, -10, Date.today());
encounter1.Patient__c = con2.Id;
encounter1.Date_of_Service__c = System.today().addDays(2);
encounter1.Liability__c = 101;
encounter1.Cancelled__c = false;
insert encounter1;

encounter1 = TestUtility.generateEncounter(con1.Id, -10, Date.today());
encounter1.Patient__c = con2.Id;
encounter1.Date_of_Service__c = System.today().addDays(2);
encounter1.Liability__c = 101;
encounter1.Cancelled__c = false;
insert encounter1;

Test.startTest();
System.debug('encounter1' + encounter1);
//insert cmm;

PreServiceSchedulerBatch dpp = new PreServiceSchedulerBatch();
Delete [Select id from CampaignMember];
System.debug('12212' + [Select id from CampaignMember]);
dpp.existingMembers = new Set<Id>();
system.schedule('schJob', '0 11 22 * 9 ?', dpp);
Test.stopTest();

List<ApexPages.Message> msgList = ApexPages.getMessages();
System.assertEquals(0, msgList.size());
}

    @isTest
    static void executBatch() {
Test.startTest();

PreServiceSchedulerBatch dppc = new PreServiceSchedulerBatch();
dppc.existingMembers = new Set<Id>();
Database.executeBatch(dppc);
Test.stopTest();

List<ApexPages.Message> msgList = ApexPages.getMessages();
System.assertEquals(0, msgList.size());
}
}