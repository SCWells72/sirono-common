/*
 * @author Sirono
 * @version 1.0.1
 * @date: 05-23-2016
 * @SkipPaymentPlanTest Test Class for the Code Covrege of SkipPaymentPlan Class.
 */

@isTest
private class SkipPaymentPlanTest {

    static testMethod void myUnitTest() {
        Apexpages.currentPage().getParameters().put('guarantorId', '');
        Apexpages.currentPage().getParameters().put('paymentPlanId', '123');

        SkipPaymentPlan objSkipPaymentPlan = new SkipPaymentPlan();
        objSkipPaymentPlan.doSubmit();


        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Sorry, the Skip Payment Plan is not of type Automatic.')) isError = true;
        }
        System.assertEquals(isError, true);

        PageReference pageRef = objSkipPaymentPlan.cancel();
        System.assertEquals('/123', pageRef.getUrl());
    }

    static testMethod void myUnitTest2() {
        TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Active__c = true;
        paymentPlan.Plan_Type__c = Constants.AUTOMATIC;
        insert paymentPlan;

        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);

        SkipPaymentPlan objSkipPaymentPlan = new SkipPaymentPlan();
        objSkipPaymentPlan.paymentPlanExtId = '123';
        TestUtility.statusCode = 200;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();
        objSkipPaymentPlan.doSubmit();

        boolean isError = false;
        if (objSkipPaymentPlan.messageToShow.contains('Clicking skip payment installment will ')) isError = true;
        System.assertEquals(isError, true);

        objSkipPaymentPlan.doTesting();
        PageReference pageRef = objSkipPaymentPlan.cancel();
        System.assertEquals('/' + paymentPlan.Id, pageRef.getUrl());
    }

    static testMethod void myUnitTest3() {
        Apexpages.currentPage().getParameters().put('guarantorId', '');
        Apexpages.currentPage().getParameters().put('paymentPlanId', '');
        Apexpages.currentPage().getParameters().put('paymentPlanExtId', '123');

        SkipPaymentPlan objSkipPaymentPlan = new SkipPaymentPlan();
        objSkipPaymentPlan.doSubmit();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Sorry, the Skip Payment Plan is not of type Automatic')) isError = true;
        }
        System.assertEquals(isError, true);


        PageReference pageRef = objSkipPaymentPlan.cancel();
        System.assertEquals('/home/home.jsp', pageRef.getUrl());

    }

    static testMethod void myUnitTest4() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Active__c = true;
        paymentPlan.Plan_Type__c = Constants.AUTOMATIC;
        paymentPlan.Sirono_ID__c = 2876;
        insert paymentPlan;

        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.ID);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId', String.valueof(paymentPlan.Sirono_ID__c));

        SkipPaymentPlan objSkipPaymentPlan = new SkipPaymentPlan();
        Test.startTest();
        TestUtility.statusCode = 200;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objSkipPaymentPlan.doSubmit();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Skipped Successfully.')) isError = true;
        }
        System.assertEquals(isError, true);

        Test.stopTest();

        PageReference pageRef = objSkipPaymentPlan.cancel();
        System.assertEquals('/' + paymentPlan.ID, pageRef.getUrl());

    }

    static testMethod void cancel() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);

        SkipPaymentPlan objSkipPaymentPlan = new SkipPaymentPlan();
        PageReference pageRef = objSkipPaymentPlan.cancel();
        System.assertEquals('/' + guarantorContact.Id, pageRef.getUrl());
    }

    static testMethod void cancel1() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Active__c = true;
        paymentPlan.Plan_Type__c = Constants.AUTOMATIC;
        insert paymentPlan;

        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId', paymentPlan.Id);

        SkipPaymentPlan objSkipPaymentPlan = new SkipPaymentPlan();
        PageReference pageRef = objSkipPaymentPlan.cancel();
        System.assertEquals('/' + paymentPlan.Id, pageRef.getUrl());
    }

    static testMethod void myUnitTest5() {
        Apexpages.currentPage().getParameters().put('guarantorId', '');
        Apexpages.currentPage().getParameters().put('paymentPlanId', '');
        Apexpages.currentPage().getParameters().put('paymentPlanExtId', '123');

        SkipPaymentPlan objSkipPaymentPlan = new SkipPaymentPlan();
        Test.startTest();
        TestUtility.statusCode = 201;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());

        objSkipPaymentPlan.doSubmit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(3, msgList.size());
        Test.stopTest();

        PageReference pageRef = objSkipPaymentPlan.cancel();
        System.assertEquals('/home/home.jsp', pageRef.getUrl());

    }

    /**
     * Check all access rights for a read only User using runAs.
     **/
    @isTest
    static void checkAccessRights() {
        List<PaymentPlanSecurityContext> allContexts = new List<PaymentPlanSecurityContext> {
            PaymentPlanSecurityContext.UPSERT_CONTEXT,
            PaymentPlanSecurityContext.UPDATE_CONTEXT,
            PaymentPlanSecurityContext.DP_UPDATE_CONTEXT,
            PaymentPlanSecurityContext.PPU_UPDATE_CONTEXT
        };

        System.runAs(TestUtility.generateReadOnlyUser()) {
            for (PaymentPlanSecurityContext context: allContexts) {
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