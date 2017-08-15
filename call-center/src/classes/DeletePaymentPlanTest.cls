/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Unit tests for DeletePaymentPlan.
 */
@IsTest
private class DeletePaymentPlanTest {
    @TestSetup
    public static void setupData() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 23232323;
        insert guarantorContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Active__c = true;
        paymentPlan.Plan_Type__c = Constants.AUTOMATIC;
        paymentPlan.Sirono_Id__c = 2876;
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1321212);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        insert chargeGroup;
    }

    static testMethod void testSubmit() {
        Contact guarantorContact = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];
        Payment_Plan__c paymentPlan = [
                SELECT Active__c,
                        Id,
                        Sirono_Id__c
                FROM Payment_Plan__c
                WHERE Guarantor__c = :guarantorContact.Id];

        System.debug('guarantorId: '+guarantorContact.Id);
        System.debug('paymentPlanId: '+paymentPlan.Id);
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        ApexPages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);

        DeletePaymentPlan objDeletePaymentPlan = new DeletePaymentPlan();
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objDeletePaymentPlan.doSubmit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(1, msgList.size());

        System.assertEquals('Payment plan was successfully cancelled.', msgList[0].getDetail());
        Test.stopTest();
    }

    static testMethod void testInvalidSubmit() {
        Contact guarantorContact = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];
        Payment_Plan__c paymentPlan = [
                SELECT Active__c,
                        Id,
                        Sirono_Id__c
                FROM Payment_Plan__c
                WHERE Guarantor__c = :guarantorContact.Id];

        System.debug('guarantorId: '+guarantorContact.Id);
        System.debug('paymentPlanId: '+paymentPlan.Id);
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);

        DeletePaymentPlan objDeletePaymentPlan = new DeletePaymentPlan();
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objDeletePaymentPlan.doSubmit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(1, msgList.size());

        System.assertEquals('Payment Plan Id is missing.', msgList[0].getDetail());
        Test.stopTest();
    }

    //Coverage for the cancel Method
    static testMethod void testCancelReturnToGT() {
        ApexPages.currentPage().getParameters().put('guarantorId', '123');
        DeletePaymentPlan objDeletePaymentPlan = new DeletePaymentPlan();
        PageReference pr = objDeletePaymentPlan.cancel();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        for (ApexPages.Message msg : msgList) {
            System.debug('msg cancel: '+msg);
        }
        System.assertEquals(0, msgList.size());
        System.assert(pr.getUrl().endsWith('123'));
    }

    //Coverage for the cancel Method
    static testMethod void testCancelReturnToPlan() {
        Payment_Plan__c paymentPlan = [
                SELECT Active__c,
                        Id,
                        Guarantor__r.Profile_Pointer_Id__c,
                        Sirono_Id__c
                FROM Payment_Plan__c];
        ApexPages.currentPage().getParameters().put('guarantorId', paymentPlan.Guarantor__r.Profile_Pointer_Id__c.toPlainString());
        ApexPages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Sirono_Id__c.toPlainString());
        DeletePaymentPlan objDeletePaymentPlan = new DeletePaymentPlan();
        PageReference pr = objDeletePaymentPlan.cancel();

        System.assertEquals(0, ApexPages.getMessages().size(), 'Expected no message on cancel');
        System.assert(pr.getUrl().endsWith(paymentPlan.Sirono_Id__c.toPlainString()));
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