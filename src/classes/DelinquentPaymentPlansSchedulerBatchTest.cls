/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 09-02-2016
 * @DelinquentPaymentPlansSchedulerBatchTest Test Class for the Code Covrege of DelinquentPaymentPlansSchedulerBatch Class.
 */

@isTest
public class DelinquentPaymentPlansSchedulerBatchTest {
    static testMethod void main() {
        Contact con1 = new Contact();
        con1.LastName = 'Test';        
        insert con1;
    
        Test.startTest();
        DelinquentPaymentPlansSchedulerBatch dpp = new DelinquentPaymentPlansSchedulerBatch();
        system.schedule('schJob','0 11 22 * 9 ?',dpp);
        Test.stopTest();
        
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(0 ,msgList.size()); 
		
        /*contact con = TestUtility.generateGuarantorContact();
        insert con;

        contact con1 = TestUtility.generateGuarantorContact();
        con1.LastName = 'Test';
        con1.Profile_Pointer_Id__c = 123;
        insert con1;

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

        Campaign c = TestUtility.generateCampaign('Delinquent');
        c.isActive = true;
        insert c;

        CampaignMember cmm = new CampaignMember(CampaignId = c.Id, ContactId = con.Id, Status = 'Sent');
        insert cmm;

        Test.startTest();
        DelinquentPaymentPlansSchedulerBatch dpp = new DelinquentPaymentPlansSchedulerBatch();
        system.schedule('schJob', '0 11 22 * 9 ?', dpp);
        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(0, msgList.size());*/
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