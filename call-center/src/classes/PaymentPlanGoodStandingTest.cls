/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Test class for PaymentPlanGoodStanding.
 */
@IsTest
public class PaymentPlanGoodStandingTest {

    static testMethod void myUnitTest1() {
        PaymentPlanGoodStanding con = new PaymentPlanGoodStanding();
        PageReference pageRef = con.cancel();
        System.assertEquals(VisualforceControllerUtil.HOME_PAGE_URL, pageRef.getUrl());

        ApexPages.currentPage().getParameters().put('guarantorId', '1212');
        PaymentPlanGoodStanding con1 = new PaymentPlanGoodStanding();
        PageReference pageRef1 = con1.cancel();
        System.assertEquals('/' + 1212, pageRef1.getUrl());

    }

    static testMethod void myUnitTest2() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Active__c = true;
        paymentPlan.Sirono_Id__c = 12345;
        insert paymentPlan;

        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        ApexPages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);

        PaymentPlanGoodStanding con = new PaymentPlanGoodStanding();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();

        con.doSubmit();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains('Payment Plan Id is missing.')) {
                isError = true;
            }
        }
        System.assertEquals(isError, true);

        Test.stopTest();
        con.cancel();
    }

    public static testMethod void testSuccess() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Sirono_Id__c = 12345;
        insert paymentPlan;

        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        ApexPages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        ApexPages.currentPage().getParameters().put('paymentPlanExtId', '12345');

        PaymentPlanGoodStanding con = new PaymentPlanGoodStanding();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();

        con.doSubmit();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains('successfully completed')) {
                isError = true;
            }
        }
        System.assertEquals(isError, true);

        Test.stopTest();
        con.cancel();

        PageReference pageRef = con.cancel();
        System.assertEquals('/' + paymentPlan.Id, pageRef.getUrl());
        con.doTesting();
    }

    static testMethod void myUnitTest4() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Sirono_Id__c = 12345;
        insert paymentPlan;

        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        ApexPages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        ApexPages.currentPage().getParameters().put('paymentPlanExtId', '12345');

        PaymentPlanGoodStanding con = new PaymentPlanGoodStanding();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        TestUtility.responsebody = '2323232';

        con.doSubmit();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains('successfully completed')) {
                isError = false;
            }
        }
        System.assertEquals(isError, false);

        Test.stopTest();
        con.cancel();

        PageReference pageRef = con.cancel();
        System.assertEquals('/' + paymentPlan.Id, pageRef.getUrl());

        con.doTesting();
    }
    
    /**
     * Check all access rights for a read only User using runAs.
     **/
    @IsTest
    static void checkAccessRights() {
        List<PaymentPlanSecurityContext> allContexts = new List<PaymentPlanSecurityContext> {
            PaymentPlanSecurityContext.UPSERT_CONTEXT,
            PaymentPlanSecurityContext.UPDATE_CONTEXT,
            PaymentPlanSecurityContext.DP_UPDATE_CONTEXT,
            PaymentPlanSecurityContext.PPU_UPDATE_CONTEXT
        };

        System.runAs(TestUtility.generateReadOnlyUser()) {
            for (PaymentPlanSecurityContext context : allContexts) {
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