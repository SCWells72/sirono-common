/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Test the validation logic in PaymentRequest
 */
@IsTest
public with sharing class PaymentRequestTest {

    @TestSetup
    public static void setup() {
        Contact gt = TestUtility.generateGuarantorContact();
        gt.Profile_Pointer_Id__c = Decimal.valueOf(PaymentRestClientMock.GT_SIRONO_ID);
        insert gt;

        Contact pt = TestUtility.generatePatientContact();
        insert pt;

        Charge_Group__c cg = TestUtility.generateChargeGroup(gt.Id, pt.Id, Decimal.valueOf(PaymentRestClientMock.CG_SIRONO_ID));
        cg.Account_Status__c = Constants.ACCT_STATUS_BILLED;
        cg.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DUE_BY;
        insert cg;

        Service2__c svc = TestUtility.generateService(gt, 575.00);
        insert svc;

        Transaction__c txn = TestUtility.generateServiceTxn(cg, 575.00, svc);
        insert txn;
    }

    public static PaymentRequest buildValidRequest() {
        Contact gt = GuarantorDao.getGuarantorBySironoId(PaymentRestClientMock.GT_SIRONO_ID);
        Charge_Group__c[] cgs = [
            SELECT Id, Guarantor__c, Balance__c
            FROM Charge_Group__c
            WHERE Account_Status__c = :Constants.ACCT_STATUS_BILLED
            AND Guarantor__c = :gt.Id
        ];

        PaymentRequest pmtRequest = new PaymentRequest(gt, cgs);
        pmtRequest.chargeInfo.creditCardNumber = '4005519200000004';
        pmtRequest.chargeInfo.cardHolderName = 'Joe Schmoe';
        pmtRequest.chargeInfo.expirationYear = String.valueOf(Date.today().addYears(2).year()).substring(2);
        pmtRequest.chargeInfo.expirationMonth = String.valueOf(Date.today().month());
        pmtRequest.chargeInfo.cvv = '123';
        pmtRequest.chargeInfo.amount = '150.00';
        pmtRequest.chargeInfo.address = '1111 Cedar St';
        pmtRequest.chargeInfo.city = 'Austin';
        pmtRequest.chargeInfo.state = 'TX';
        pmtRequest.chargeInfo.zip = '78704';
        pmtRequest.guarantor = gt;
        pmtRequest.chargeGroups = new List<Charge_Group__c> { cgs[0] };
        pmtRequest.chargeInfo.amount = '500.00';
        return pmtRequest;
    }

    @IsTest
    public static void paymentRequestSuccessfulValidationTest() {
        PaymentRequest pmtRequest = buildValidRequest();
        List<String> errors = pmtRequest.validate();

        System.assert(errors.isEmpty(), 'Unexpected errors thrown: ' + String.join(errors, '\n'));

    }

    @IsTest
    public static void paymentRequestNoGTValidationTest() {
        PaymentRequest pmtRequest = buildValidRequest();
        pmtRequest.guarantor = null;
        List<String> errors = pmtRequest.validate();

        System.assert(errors.size() == 1, 'Unexpected errors thrown: ' + String.join(errors, '\n'));
    }

    @IsTest
    public static void paymentRequestNoCGValidationTest() {
        PaymentRequest pmtRequest = buildValidRequest();
        pmtRequest.chargeGroups = new List<Charge_Group__c>();
        List<String> errors = pmtRequest.validate();

        for (String error : errors) {
            System.assert(error.contains('Zero or credit balance is not payable.') || error.contains('Amount cannot exceed balance.') ||
                error.contains('Charge Group is a required field.'), 'Unexpected error returned: ' + error);
        }
        System.assert(errors.size() == 3, 'Unexpected errors thrown: ' + String.join(errors, '\n'));
    }

    @IsTest
    public static void paymentRequestZeroAmountValidationTest() {
        PaymentRequest pmtRequest = buildValidRequest();
        pmtRequest.chargeInfo.amount = '0';
        List<String> errors = pmtRequest.validate();

        System.assert(errors.size() == 1, 'Unexpected errors thrown: ' + String.join(errors, '\n'));
    }

    @IsTest
    public static void paymentRequestBadExpYearValidationTest() {
        PaymentRequest pmtRequest = buildValidRequest();
        pmtRequest.chargeInfo.expirationYear = String.valueOf(Date.today().addYears(-1).year()).substring(2);
        List<String> errors = pmtRequest.validate();

        System.assert(errors.size() == 1, 'Unexpected errors thrown: ' + String.join(errors, '\n'));
    }

    @IsTest
    public static void paymentRequestBadExpMonthValidationTest() {
        PaymentRequest pmtRequest = buildValidRequest();
        pmtRequest.chargeInfo.expirationYear = String.valueOf(Date.today().year()).substring(2);
        pmtRequest.chargeInfo.expirationMonth = String.valueOf(Date.today().addMonths(-1).month());
        List<String> errors = pmtRequest.validate();

        System.assert(errors.size() == 1, 'Unexpected errors thrown: ' + String.join(errors, '\n'));
    }

    @IsTest
    public static void paymentRequestNoCardNumberValidationTest() {
        PaymentRequest pmtRequest = buildValidRequest();
        pmtRequest.chargeInfo.creditCardNumber = null;
        List<String> errors = pmtRequest.validate();

        System.assert(errors.size() == 1, 'Unexpected errors thrown: ' + String.join(errors, '\n'));
    }

    @IsTest
    public static void paymentRequestNoCardholderValidationTest() {
        PaymentRequest pmtRequest = buildValidRequest();
        pmtRequest.chargeInfo.cardHolderName = null;
        List<String> errors = pmtRequest.validate();

        System.assert(errors.size() == 1, 'Unexpected errors thrown: ' + String.join(errors, '\n'));
    }

    @IsTest
    public static void paymentRequestBadCVVValidationTest() {
        PaymentRequest pmtRequest = buildValidRequest();
        //Too long
        pmtRequest.chargeInfo.cvv = '12345';
        List<String> errors = pmtRequest.validate();

        System.assert(errors.size() == 1, 'Unexpected errors thrown: ' + String.join(errors, '\n'));

        //Too Short
        pmtRequest.chargeInfo.cvv = '12';
        errors = pmtRequest.validate();

        System.assert(errors.size() == 1, 'Unexpected errors thrown: ' + String.join(errors, '\n'));

        //Not there
        pmtRequest.chargeInfo.cvv = null;
        errors = pmtRequest.validate();

        System.assert(errors.size() == 1, 'Unexpected errors thrown: ' + String.join(errors, '\n'));
    }

    @IsTest
    public static void paymentRequestZipValidationTest() {
        PaymentRequest pmtRequest = buildValidRequest();
        //Too long
        pmtRequest.chargeInfo.zip = '123456';
        List<String> errors = pmtRequest.validate();

        System.assert(errors.size() == 1, 'Unexpected errors thrown: ' + String.join(errors, '\n'));

        //Too Short
        pmtRequest.chargeInfo.zip = '12';
        errors = pmtRequest.validate();

        System.assert(errors.size() == 1, 'Unexpected errors thrown: ' + String.join(errors, '\n'));

        //Non-numeric
        pmtRequest.chargeInfo.zip = '123Ah';
        errors = pmtRequest.validate();

        System.assert(errors.size() == 1, 'Unexpected errors thrown: ' + String.join(errors, '\n'));

        //Not there
        pmtRequest.chargeInfo.zip = null;
        errors = pmtRequest.validate();

        System.assert(errors.size() == 1, 'Unexpected errors thrown: ' + String.join(errors, '\n'));
    }
}
