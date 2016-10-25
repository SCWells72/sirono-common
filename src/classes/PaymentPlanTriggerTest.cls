/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 08-02-2016
 * 10-19-2016: Viraj - Tracker # 132105543: Revisit negative balances in cases. Change "Payable_Amount__c = '<= -100' to '>= 100'" in condition.
 */

@isTest
private class PaymentPlanTriggerTest {

    static testMethod void myUnitTest() {
        TestUtility objTestUtil = new TestUtility();
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Guarantor').getRecordTypeId();
        insert guarantorContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;
        paymentPlan.Active__c = true;
        Update paymentPlan;
        paymentPlan.Plan_Type__c = 'Automatic';
        update paymentPlan;

        paymentPlan.Skip_Payment_Until__c = date.newInstance(2016, 1, 5);
        update paymentPlan;

        guarantorContact.Invoice_Offset_Date__c = 30;
        update guarantorContact;
        update paymentPlan;

        paymentPlan.Plan_Type__c = null;
        update paymentPlan;

        paymentPlan.Plan_Type__c = 'Automatic';
        paymentPlan.Execute_on_Day__c = 0;
        update paymentPlan;

        paymentPlan.Execute_on_Day__c = 31;
        update paymentPlan;
    }

    @isTest
    static void myUnitTest1() {

    Contact guarantorContact = TestUtility.generateGuarantorContact();
    guarantorContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Guarantor').getRecordTypeId();
    insert guarantorContact;

    test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
    paymentPlan.active__c = false;
    paymentPlan.Plan_Type__c = 'Automatic';
    //10-19-2016: Viraj - Tracker # 132105543: Revisit negative balances in cases. Change "Payable_Amount__c = '<= -100' to '>= 100'" in condition.
    paymentPlan.Payable_Amount__c = 100;
    paymentPlan.Has_Error__c = false;
    paymentPlan.Delinquent__c = true;
    insert paymentPlan;

    paymentPlan.Active__c = true;
    //10-19-2016: Viraj - Tracker # 132105543-Change "Payable_Amount__c = '<= -100' to '>= 100'" in condition.
    paymentPlan.Payable_Amount__c = 101;
    paymentPlan.Plan_Type__c = 'Manual';
    update paymentPlan;

}

    @isTest 
    static void myUnitTest3() { 
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Guarantor').getRecordTypeId();
        insert guarantorContact;
        
        test__c paymentPlan1 = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan1.active__c = true;
        paymentPlan1.Plan_Type__c = 'Automatic';
        //10-19-2016: Viraj - Tracker # 132105543-Change "Payable_Amount__c = '<= -100' to '>= 100'" in condition.
        paymentPlan1.Payable_Amount__c = 100;
        paymentPlan1.Has_Error__c = false;
        paymentPlan1.Delinquent__c = true;
        insert paymentPlan1;
        
        paymentPlan1.active__c = false; 
        paymentPlan1.Delinquent__c = false;
        update paymentPlan1;
            
   }  
    
    @isTest
    static void myUnitTest2() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Guarantor').getRecordTypeId();
        insert guarantorContact;
        
        test__c paymentPlan1 = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan1.active__c = false;
        paymentPlan1.Plan_Type__c = 'Manual';
        //10-19-2016: Viraj - Tracker # 132105543-Change "Payable_Amount__c = '<= -100' to '>= 100'" in condition.
        paymentPlan1.Payable_Amount__c = 200;
        paymentPlan1.Has_Error__c = false;
        //paymentPlan1.Delinquent__c = true;
        insert paymentPlan1;
        
        paymentPlan1.active__c = true;
        paymentPlan1.Plan_Type__c = 'Automatic';
        //10-19-2016: Viraj - Tracker # 132105543-Change "Payable_Amount__c = '<= -100' to '>= 100'" in condition.
        paymentPlan1.Payable_Amount__c = 501;
        paymentPlan1.Has_Error__c = true;
        update paymentPlan1;
    } 
    
    @isTest
    static void myUnitTest5() {
        
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Guarantor').getRecordTypeId();
        insert guarantorContact;
        
        Date refDt = Date.newInstance(TestUtility.currentYear, TestUtility.currentMonth, TestUtility.currentDay);
        
        test__c paymentPlan1 = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan1.active__c = true;
        paymentPlan1.Plan_Type__c = 'Automatic';
        //10-19-2016: Viraj - Tracker # 132105543-Change "Payable_Amount__c = '<= -100' to '>= 100'" in condition.
        paymentPlan1.Payable_Amount__c = 100;
        paymentPlan1.Has_Error__c = true;
        paymentPlan1.Skip_Payment_Until__c = refDt.adddays(10); 
        insert paymentPlan1;        
    } 
}