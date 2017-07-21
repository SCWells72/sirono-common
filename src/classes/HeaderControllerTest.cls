/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Header Controller Tests.
 */
@isTest
public with sharing class HeaderControllerTest {

    @isTest
    public static void getUserInfoTest() {
        User usr = TestUtility.getGuarantorCommunityUser();

        System.runAs(usr) {
            Test.startTest();
            UserWrapper userWrapper = HeaderController.getUserInfo();
            Test.stopTest();

            System.debug(userWrapper);
            System.assert(userWrapper != null, 'Should have a UserWrapper.');
            System.assertEquals(usr.Id, userWrapper.id, 'Should find id.');
            // TODO: figure this out
//            System.assert(userWrapper.firstName != null, 'Should find firstName.');
            System.assertEquals(usr.ContactId, userWrapper.contactId, 'Should find contactId.');
            //TODO: figure out why this is null.
//          System.assert(userWrapper.profilePointerId != null, 'Should find profile pointer id.');
        }
    }

    @isTest
    public static void getHeaderInfoTest() {
        Contact guarantorContact;
        Contact patientContact;
        Invoice__c invoice1;
        User portalUser = TestUtility.getGuarantorCommunityUser();
        User adminUser = TestUtility.getPortalAdminUser();

        System.runAs(adminUser) {
            Account testAcc = TestUtility.getPortalAccount();
            guarantorContact = TestUtility.getPortalGuarantor();

            patientContact = TestUtility.generatePatientContact();
            patientContact.AccountId = testAcc.Id;
            patientContact.Medical_Record_Number__c = '1234512345';
            INSERT patientContact;

            Payment_Plan__c pPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
            INSERT pPlan;

            List<Invoice__c> lstInvoice = new List<Invoice__c>();
            invoice1 = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
            lstInvoice.add(invoice1);

            Invoice__c invoice2 = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
            lstInvoice.add(invoice2);

            Invoice__c invoice3 = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
            invoice3.Invoice_Status_Index__c = 2;
            lstInvoice.add(invoice3);

            INSERT lstInvoice;

            List<Charge_Group__c> lstChrgGroup = new List<Charge_Group__c>();
            Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 1234, pPlan.Id);
            chargeGroup1.Invoice__c = invoice1.Id;
            lstChrgGroup.add(chargeGroup1);

            Charge_Group__c chargeGroup2 = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 1234, pPlan.Id);
            chargeGroup2.Invoice__c = invoice2.Id;
            lstChrgGroup.add(chargeGroup2);

            INSERT lstChrgGroup;

            Payor__c payorTest = new Payor__c(
                Name = 'payorTest'
            );
            INSERT payorTest;

            Coverage__c objcoverage = new Coverage__c(
                Name = 'Test',
                Payor__c = payorTest.Id
            );
            INSERT objcoverage;

            Charge_Group_Coverage_Junction__c objCGCoverage = new Charge_Group_Coverage_Junction__c();
            objCGCoverage.Name = 'Test';
            objCGCoverage.Charge_Group__c = chargeGroup1.Id;
            objCGCoverage.Coverage__c = objcoverage.Id;
            INSERT objCGCoverage;

            Payment__c payment1 = TestUtility.generateSironoPayment(guarantorContact.Id, 1234, 12);
            Payment__c payment2 = TestUtility.generateSironoPayment(guarantorContact.Id, 1235, 25);
            List<Payment__c> lstPayment = new List<Payment__c>{
                payment1, payment2
            };
            INSERT lstPayment;

            List<Transaction__c> lstTransaction = new List<Transaction__c>();
            Transaction__c transaction1 = TestUtility.generatePaymentTxn(chargeGroup1, 20, payment1);
            lstTransaction.add(transaction1);

            Transaction__c transaction2 = TestUtility.generatePaymentTxn(chargeGroup1, 200, payment2);
            lstTransaction.add(transaction2);

            INSERT lstTransaction;


            invoice1.Invoice_Status_Index__c = 9;
            invoice2.Invoice_Status_Index__c = 4;
            List<Invoice__c> lstInvoiceUpdate = new List<Invoice__c>{
                invoice1, invoice2
            };
            UPDATE lstInvoiceUpdate;

            List<WorkWithInvoicesController.PatientWrapper> patientList = WorkWithInvoicesController.getPatientList();
            System.assertEquals(0, patientList.size());
        }

        System.runAs(portalUser) {
            Test.startTest();
            HeaderWrapper wrapper = HeaderController.getAllHeaderInfo();
            Test.stopTest();

            System.assertEquals(guarantorContact.Id, wrapper.contact.Id, 'Should have found info for Guarantor.');
            System.assertEquals(Constants.DELIQUENT, wrapper.contact.Guarantor_Status__c, 'Should be deliquent.');
            System.assertEquals(null, wrapper.pastDueMessage, 'Should not have a past due message.');
            System.assertEquals(null, wrapper.paymentPlan, 'Should not have a paymentPlan.');
            System.assertEquals(0, wrapper.newEstimatesCount, 'Should not have new estimates.');
        }
    }

    @isTest
    public static void getMessageInfo_GTStatus() {
        HeaderWrapperMock hwm = new HeaderWrapperMock();
        hwm.paymentPlanExists = false;
        hwm.paymentPlanStanding = Constants.PLANTYPE_GOOD_STANDING;
        hwm.planType = Constants.AUTOMATIC;
        hwm.paymentPlanActive = true;


        Test.startTest();
        hwm.guarantorStatus = Constants.GUARANTOR_STATUS_OVERDUE;
        String hasStatusError = HeaderController.getMessageInfo(hwm);
        hwm.guarantorStatus = Constants.GUARANTOR_STATUS_DELINQUENT;
        String delqError = HeaderController.getMessageInfo(hwm);

        Test.stopTest();

        System.assert(hasStatusError.indexOf(HeaderController.WARNING_MESSAGE) != -1, 'Should have the warning');
        System.assert(delqError.indexOf(HeaderController.WARNING_MESSAGE) == -1, 'Should not have the warning');
        System.assert(hasStatusError.indexOf(HeaderController.DELINQUENT_MESSAGE) == -1, 'Should not have the deliquent message');
        System.assert(delqError.indexOf(HeaderController.DELINQUENT_MESSAGE) != -1, 'Should have the deliquent message');
    }

    @isTest
    public static void getMessageInfo_pastDue() {
        HeaderWrapperMock hwm = new HeaderWrapperMock();
        hwm.guarantorStatus = Constants.GUARANTOR_STATUS_ON_PAYMENT_PLAN;
        hwm.paymentPlanStanding = Constants.PLANTYPE_GOOD_STANDING;
        hwm.paymentPlanActive = true;

        Test.startTest();
        hwm.paymentPlanExists = true;
        hwm.paymentPlanStanding = Constants.PAST_DUE;

        hwm.planType = Constants.AUTOMATIC;
        String automaticMessage = HeaderController.getMessageInfo(hwm);
        hwm.planType = Constants.MANUAL;
        String manualMessage = HeaderController.getMessageInfo(hwm);

        Test.stopTest();

        System.assert(automaticMessage.indexOf(HeaderController.PASTDUE_MESSAGE) != -1, 'Should have the past due message.');
        System.assert(manualMessage.indexOf(HeaderController.PASTDUE_MESSAGE) != -1, 'Should have the past due message.');
        System.assert(automaticMessage.indexOf(HeaderController.PASTDUE_MANUAL_MESSAGE) == -1, 'Should not have the past due manual message.');
        System.assert(manualMessage.indexOf(HeaderController.PASTDUE_MANUAL_MESSAGE) != -1, 'Should have the past due manual message.');
    }

    @isTest
    public static void getMessageInfo_inError() {
        HeaderWrapperMock hwm = new HeaderWrapperMock();
        hwm.guarantorStatus = Constants.GUARANTOR_STATUS_ON_PAYMENT_PLAN;
        hwm.paymentPlanExists = false;
        hwm.paymentPlanActive = true;

        Test.startTest();
        // Error message condition
        hwm.planType = Constants.AUTOMATIC;
        hwm.paymentPlanStanding = Constants.IN_ERROR;
        String hasError = HeaderController.getMessageInfo(hwm);
        hwm.paymentPlanStanding = Constants.DUE;
        String noError = HeaderController.getMessageInfo(hwm);

        Test.stopTest();

        System.assert(hasError.indexOf(HeaderController.ERROR_MESSAGE) != -1, 'Should have the error message.');
        System.assert(noError.indexOf(HeaderController.ERROR_MESSAGE) == -1, 'Should not have the error message.');
    }

    @isTest
    public static void hasBalanceAndNotAddPaymentPlan_AddToPaymentPlan() {
        HeaderWrapperMock hwm = new HeaderWrapperMock();
        hwm.addPaymentPlan = true;
        hwm.guarantorStatus = Constants.GUARANTOR_STATUS_DUE;

        Test.startTest();
        Boolean onPlanCheck = HeaderController.hasBalanceAndNotAddPaymentPlan(hwm);
        Test.stopTest();

        System.assertEquals(false, onPlanCheck, 'Should be false if ADD_TO_PAYMENT_PLAN is true.');
    }

    @isTest
    public static void hasBalanceAndNotAddPaymentPlan_NoAddToPaymentPlan() {
        HeaderWrapperMock hwm = new HeaderWrapperMock();
        hwm.addPaymentPlan = false;

        Test.startTest();
        hwm.guarantorStatus = Constants.GUARANTOR_STATUS_DUE;
        Boolean dueCheck = HeaderController.hasBalanceAndNotAddPaymentPlan(hwm);
        hwm.guarantorStatus = Constants.GUARANTOR_STATUS_OVERDUE;
        Boolean overdueCheck = HeaderController.hasBalanceAndNotAddPaymentPlan(hwm);
        hwm.guarantorStatus = Constants.GUARANTOR_STATUS_DELINQUENT;
        Boolean deliquentCheck = HeaderController.hasBalanceAndNotAddPaymentPlan(hwm);
        hwm.guarantorStatus = Constants.GUARANTOR_STATUS_ON_PAYMENT_PLAN;
        Boolean onPlanCheck = HeaderController.hasBalanceAndNotAddPaymentPlan(hwm);
        Test.stopTest();

        System.assertEquals(true, dueCheck, 'Should be true for DUE and no payment plan.');
        System.assertEquals(true, overdueCheck, 'Should be true for Overdue and no payment plan.');
        System.assertEquals(true, deliquentCheck, 'Should be true for Deliquent and no payment plan.');
        System.assertEquals(false, onPlanCheck, 'Should be false for on plan and no add payment plan.');
    }

    @isTest
    public static void hasBalanceAndAddPaymentPlan_VerifyPlan() {
        HeaderWrapperMock hwm = new HeaderWrapperMock();
        hwm.guarantorStatus = Constants.GUARANTOR_STATUS_OVERDUE;

        Test.startTest();
        hwm.addPaymentPlan = true;
        Boolean hasPlanCheck = HeaderController.hasBalanceAndAddPaymentPlan(hwm);
        hwm.addPaymentPlan = false;
        Boolean noPlanCheck = HeaderController.hasBalanceAndAddPaymentPlan(hwm);
        Test.stopTest();

        System.assertEquals(true, hasPlanCheck, 'Should be true with Add to Payment Plan.');
        System.assertEquals(false, noPlanCheck, 'Should be true with no Add to Payment Plan.');
    }

    @isTest
    public static void hasPaymentPlanInGoodStanding_noPPlan() {
        HeaderWrapperMock hwm = new HeaderWrapperMock();
        hwm.guarantorStatus = Constants.GUARANTOR_STATUS_DUE;
        hwm.addPaymentPlan = true;

        hwm.paymentPlanExists = false;

        Test.startTest();
        Boolean noPPlanCheck = HeaderController.hasPaymentPlanInGoodStanding(hwm);
        Test.stopTest();

        System.assertEquals(false, noPPlanCheck, 'Should be false with no payment plan.');
    }

    @isTest
    public static void hasPaymentPlanInGoodStanding_notGoodStanding() {
        HeaderWrapperMock hwm = new HeaderWrapperMock();
        hwm.guarantorStatus = Constants.GUARANTOR_STATUS_DUE;
        hwm.addPaymentPlan = true;

        hwm.paymentPlanExists = true;
        hwm.paymentPlanStanding = Constants.PLANTYPE_PROMISE;

        Test.startTest();
        Boolean notGoodStandingCheck = HeaderController.hasPaymentPlanInGoodStanding(hwm);
        Test.stopTest();

        System.assertEquals(false, notGoodStandingCheck, 'Should be false when payment plan status is not Good Standing.');
    }


    @isTest
    public static void hasPaymentPlanInGoodStanding_GoodStanding() {
        HeaderWrapperMock hwm = new HeaderWrapperMock();
        hwm.guarantorStatus = Constants.GUARANTOR_STATUS_DUE;
        hwm.addPaymentPlan = true;

        hwm.paymentPlanExists = true;
        hwm.paymentPlanStanding = Constants.PLANTYPE_GOOD_STANDING;

        Test.startTest();
        Boolean goodStandingCheck = HeaderController.hasPaymentPlanInGoodStanding(hwm);
        Test.stopTest();

        System.assertEquals(true, goodStandingCheck, 'Should be true when payment plan status is Good Standing.');
    }

    @isTest
    public static void balanceDueOrError_notGoodStanding() {
        HeaderWrapperMock hwm = new HeaderWrapperMock();
        hwm.paymentPlanExists = true;
        hwm.paymentPlanStanding = Constants.PLANTYPE_AUTO;

        Test.startTest();
        Boolean notGoodStandingCheck = HeaderController.balanceDueOrError(hwm);
        Test.stopTest();

        System.assertEquals(true, notGoodStandingCheck, 'Should true when there is a plan no in good standing.');
    }

    @isTest
    public static void balanceDueOrError_hasBalAndPPlan() {
        HeaderWrapperMock hwm = new HeaderWrapperMock();
        hwm.paymentPlanExists = true;
        hwm.paymentPlanStanding = Constants.PLANTYPE_GOOD_STANDING;
        hwm.guarantorStatus = Constants.GUARANTOR_STATUS_DELINQUENT;

        Test.startTest();
        hwm.addPaymentPlan = true;
        Boolean balAndPPlan = HeaderController.balanceDueOrError(hwm);
        hwm.addPaymentPlan = false;
        Boolean balAndNoPPlan = HeaderController.balanceDueOrError(hwm);
        Test.stopTest();

        System.assertEquals(true, balAndPPlan, 'Should be true if Add To PPlan is true.');
        System.assertEquals(false, balAndNoPPlan, 'Should be false if Add To PPlan is false.');
    }

    @isTest
    public static void balanceDueOrError_statusCheck() {
        HeaderWrapperMock hwm = new HeaderWrapperMock();
        hwm.paymentPlanExists = true;
        hwm.paymentPlanStanding = Constants.PLANTYPE_GOOD_STANDING;
        // HasBalanceAndPaymentPlan will return false
        hwm.addPaymentPlan = false;

        Test.startTest();
        hwm.guarantorStatus = Constants.GUARANTOR_STATUS_ON_PAYMENT_PLAN;
        Boolean onPaymentPlanCheck = HeaderController.balanceDueOrError(hwm);
        hwm.guarantorStatus = Constants.GUARANTOR_STATUS_DELINQUENT;
        Boolean notOnPaymentPlanCheck = HeaderController.balanceDueOrError(hwm);
        Test.stopTest();

        System.assertEquals(true, onPaymentPlanCheck, 'Should be true if status is gt status is on payment plan.');
        System.assertEquals(false, notOnPaymentPlanCheck, 'Should be true if status is gt status is not payment plan.');
    }

    @isTest
    public static void onPaymentPlan_verifyGTStatus() {
        HeaderWrapperMock hwm = new HeaderWrapperMock();
        // Already verifyed hasBalanceAndAddPaymentPlan so just make it return false
        hwm.addPaymentPlan = false;

        Test.startTest();
        hwm.guarantorStatus = Constants.GUARANTOR_STATUS_ON_PAYMENT_PLAN;
        Boolean checkOnPPlan = HeaderController.onPaymentPlan(hwm);
        hwm.guarantorStatus = Constants.DUE;
        Boolean checkOther = HeaderController.onPaymentPlan(hwm);
        Test.stopTest();

        System.assertEquals(true, checkOnPPlan, 'Should be false if GTStatus is not on pplan.');
        System.assertEquals(false, checkOther, 'Should be false if GTStatus is not on pplan.');
    }
}