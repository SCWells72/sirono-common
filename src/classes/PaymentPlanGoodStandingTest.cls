/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 05-23-2016
 * @PaymentPlanGoodStandingTest Test Class for the Code Covrege of PaymentPlanGoodStanding Class.
 */

@isTest
private class PaymentPlanGoodStandingTest {

    static testMethod void myUnitTest1() {
        PaymentPlanGoodStanding con = new PaymentPlanGoodStanding();
        PageReference pageRef = con.cancel();
        System.assertEquals('/home/home.jsp', pageRef.getUrl());

        Apexpages.currentPage().getParameters().put('guarantorId', '1212');
        PaymentPlanGoodStanding con1 = new PaymentPlanGoodStanding();
        PageReference pageRef1 = con1.cancel();
        System.assertEquals('/' + 1212, pageRef1.getUrl());

    }

    static testMethod void myUnitTest2() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Active__C = true;
        paymentPlan.Sirono_ID__c = 12345;
        insert paymentPlan;

        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);

        PaymentPlanGoodStanding con = new PaymentPlanGoodStanding();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();

        con.doSubmit();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Payment Plan Id is missing.')) isError = true;
        }
        System.assertEquals(isError, true);

        Test.stopTest();
        con.cancel();
    }

    static testMethod void myUnitTest3() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Sirono_ID__c = 12345;
        insert paymentPlan;

        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId', '12345');

        PaymentPlanGoodStanding con = new PaymentPlanGoodStanding();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();

        con.doSubmit();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('successfully completed')) isError = true;
        }
        System.assertEquals(isError, true);

        Test.stopTest();
        con.cancel();

        PageReference pageRef = con.cancel();
        System.assertEquals('/' + paymentPlan.Id, pageRef.getUrl());
        con.doTesting();
    }

    static testMethod void myUnitTest4() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Sirono_ID__c = 12345;
        insert paymentPlan;

        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId', '12345');

        PaymentPlanGoodStanding con = new PaymentPlanGoodStanding();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        TestUtility.responsebody = '2323232';

        con.doSubmit();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('successfully completed')) isError = false;
        }
        System.assertEquals(isError, false);

        Test.stopTest();
        con.cancel();

        PageReference pageRef = con.cancel();
        System.assertEquals('/' + paymentPlan.Id, pageRef.getUrl());

        con.doTesting();

    }
}