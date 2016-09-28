/*
* @author Sirono
* @version 1.0.1
* @Date: 05-02-2016
* @ Unit class  for the AddNote class.     
* Do the code coverage for the AddNote class
*/

@isTest
private class AddNoteTest {
    static testMethod void myUnitTest() {
        Test.startTest();
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.id);
        paymentPlan.active__c = true;
        paymentPlan.Delinquent__c = true;
        insert paymentPlan;


        AddNote conOb = new AddNote(new ApexPages.StandardController(paymentPlan));
        conOb.chargegroupId = 'test';
        conOb.noteText = 'test class';
        conOb.doSubmit();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(2, msgList.size());
        Test.stopTest();
    }

    static testMethod void noParameterTest() {
        Test.startTest();
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.id);
        paymentPlan.active__c = true;
        paymentPlan.Delinquent__c = true;
        insert paymentPlan;


        AddNote conOb = new AddNote(new ApexPages.StandardController(paymentPlan));
        conOb.doSubmit();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(2, msgList.size());
        Test.stopTest();
    }

    static testMethod void submit() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.id);

        AddNote conOb = new AddNote(new ApexPages.StandardController(paymentPlan));
        conOb.chargegroupId = 'test';
        conOb.noteText = 'test class';

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        conOb.doSubmit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(2, msgList.size());
        Test.stopTest();

    }

    static testMethod void submit1() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.id);

        AddNote conOb = new AddNote(new ApexPages.StandardController(paymentPlan));
        conOb.chargegroupId = 'test';
        conOb.noteText = 'test class';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        conOb.doSubmit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(4, msgList.size());
        Test.stopTest();

    }
}