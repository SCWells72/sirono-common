/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 05-20-2016
 * @DeletePaymentPlanTest Class is Unit test class of DeletePaymentPlan class.
 */

@isTest
private class DeletePaymentPlanTest {

    static testMethod void myUnitTest() {
        Apexpages.currentPage().getParameters().put('guarantorId', '123');
        Apexpages.currentPage().getParameters().put('paymentPlanId', '123');
        Apexpages.currentPage().getParameters().put('paymentPlanExtId', '123');

        DeletePaymentPlan objDeletePaymentPlan = new DeletePaymentPlan();
        objDeletePaymentPlan.doSubmit();
        objDeletePaymentPlan.cancel();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(2, msgList.size());
    }

    static testMethod void submit() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Active__c = true;
        paymentPlan.Plan_Type__c = 'Automatic';
        paymentPlan.Sirono_ID__c = 2876;
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1321212);
        chargeGroup.Account_Sub_Status__c = 'Payment Plan';
        insert chargeGroup;

        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.ID);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId', String.valueof(paymentPlan.Sirono_ID__c));

        DeletePaymentPlan objDeletePaymentPlan = new DeletePaymentPlan();
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objDeletePaymentPlan.doSubmit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(2, msgList.size());
        Test.stopTest();
    }

    static testMethod void submit1() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Active__c = true;
        paymentPlan.Plan_Type__c = 'Automatic';
        paymentPlan.Sirono_ID__c = 2876;
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1321212);
        chargeGroup.Account_Sub_Status__c = 'Payment Plan';
        insert chargeGroup;

        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.ID);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId', String.valueof(paymentPlan.Sirono_ID__c));

        DeletePaymentPlan objDeletePaymentPlan = new DeletePaymentPlan();
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objDeletePaymentPlan.doSubmit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(2, msgList.size());
        Test.stopTest();
    }

    static testMethod void submit2() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Active__c = true;
        paymentPlan.Plan_Type__c = 'Automatic';
        paymentPlan.Sirono_ID__c = 2876;
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1321212);
        chargeGroup.Account_Sub_Status__c = 'Payment Plan';
        insert chargeGroup;

        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.ID);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId', String.valueof(paymentPlan.Sirono_ID__c));

        DeletePaymentPlan objDeletePaymentPlan = new DeletePaymentPlan();
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        TestUtility.statusCode2 = 201;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objDeletePaymentPlan.doSubmit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(1, msgList.size());
        Test.stopTest();
    }

    static testMethod void submit3() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Active__c = true;
        paymentPlan.Plan_Type__c = 'Automatic';
        paymentPlan.Sirono_ID__c = 2876;
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1321212);
        chargeGroup.Account_Sub_Status__c = 'Payment Plan';
        insert chargeGroup;

        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.ID);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId', String.valueof(paymentPlan.Sirono_ID__c));

        DeletePaymentPlan objDeletePaymentPlan = new DeletePaymentPlan();
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        TestUtility.statusCode4 = 204;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objDeletePaymentPlan.doSubmit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(2, msgList.size());
        Test.stopTest();
    }

    static testMethod void submit4() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Active__c = true;
        paymentPlan.Plan_Type__c = 'Automatic';
        paymentPlan.Sirono_ID__c = 2876;
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1321212);
        chargeGroup.Account_Sub_Status__c = 'Payment Plan';
        insert chargeGroup;

        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.ID);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId', String.valueof(paymentPlan.Sirono_ID__c));

        DeletePaymentPlan objDeletePaymentPlan = new DeletePaymentPlan();
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        TestUtility.statusCode3 = 204;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objDeletePaymentPlan.doSubmit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(1, msgList.size());
        Test.stopTest();
    }

    //Coverage for the cancel Method
    static testMethod void cancel() {
        Apexpages.currentPage().getParameters().put('guarantorId', '123');
        DeletePaymentPlan objDeletePaymentPlan = new DeletePaymentPlan();
        objDeletePaymentPlan.cancel();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(0, msgList.size());
    }

    //Coverage for the cancel Method
    static testMethod void cancel1() {
        DeletePaymentPlan objDeletePaymentPlan = new DeletePaymentPlan();
        objDeletePaymentPlan.cancel();
        objDeletePaymentPlan.doSubmit();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(2, msgList.size());
    }
}