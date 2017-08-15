/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Test TxnAggregationUtils for PAS Payment transactions
 *
 * A PAS payment comes from the Hospital & will have the pmt_key set, but no guarantor. The Amount and Posted_Amount
 * on it equal the sum of its transactions.
 */
@IsTest
public with sharing class TxnPASPmtAggregationTest {

    private static String CG_EXT_ID = '456';
    private static String PAS_KEY = 'someConcatenatedStringOfValues';

    @TestSetup
    public static void setupData() {
        Contact gt = TestUtility.generateGuarantorContact();
        Contact pt = TestUtility.generatePatientContact();

        insert new Contact[] { gt, pt };

        gt = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];
        pt = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.patientRt];

        Charge_Group__c cg = TestUtility.generateChargeGroupWithExternalId(gt.Id, pt.Id, Decimal.valueOf(CG_EXT_ID));
        insert cg;

        Payment__c payment = TestUtility.generatePASPayment(PAS_KEY);
        insert payment;

        // Check system asserts.
        System.assertEquals(CG_EXT_ID, cg.External_Id__c, 'Expected CG External_Id__c is ' + CG_EXT_ID + ' but got ' + cg.External_Id__c);
        System.assertEquals(PAS_KEY, payment.ID__c, 'Expected ' + PAS_KEY + ' but got ' + payment.ID__c);
    }

    /*
     *  When a PAS payment's transactions are saved, the payment's amount and posted_amount should be the absolute value
     *  of the sum of all the transactions' amounts
     */
    @IsTest
    public static void testPASPaymentAmountAggregation() {
        Payment__c payment = [SELECT Id FROM Payment__c WHERE ID__c = :PAS_KEY];
        Charge_Group__c cg = [SELECT Id FROM Charge_Group__c];

        Test.startTest();

        Transaction__c txn = TestUtility.generatePaymentTxn(cg, -100.00, payment);
        insert txn;

        Test.stopTest();

        payment = [SELECT Id, Amount__c, Posted_Amount__c FROM Payment__c WHERE Id = :payment.Id];

        System.assert(payment.Amount__c == 100.00, 'Expected payment amount to be 100.00, but was: ' + payment.Amount__c);
        System.assert(payment.Posted_Amount__c == 100.00,
            'Expected posted amount to be 100.00, but was: ' + payment.Posted_Amount__c);
    }

    /*
     * When a PAS payment's transactions are all deleted, the payment's amount and posted_amount should be 0
     */
    @IsTest
    public static void testPASPaymentTxnDeleted() {
        Payment__c payment = [SELECT Id FROM Payment__c WHERE ID__c = :PAS_KEY];
        Charge_Group__c cg = [SELECT Id FROM Charge_Group__c];

        Test.startTest();

        Transaction__c txn = TestUtility.generatePaymentTxn(cg, -100.00, payment);
        insert txn;

        payment = [SELECT Id, Amount__c, Posted_Amount__c FROM Payment__c];
        System.assert(payment.Amount__c == 100.00, 'Expected payment amount to be 100.00, but was: ' + payment.Amount__c);
        System.assert(payment.Posted_Amount__c == 100.00,
            'Expected Posted_Amount__c to be 100.00, but was: ' + payment.Posted_Amount__c);

        txn = [SELECT Id FROM Transaction__c];
        delete txn;

        Test.stopTest();

        payment = [SELECT Id, Amount__c, Posted_Amount__c FROM Payment__c WHERE Id = :payment.Id];

        System.assert(payment.Amount__c == 0.00, 'Expected payment amount to be 0.00, but was: ' + payment.Amount__c);
        System.assert(payment.Posted_Amount__c == 0.00,
            'Expected payment Posted_Amount__c to be 0.00, but was: ' + payment.Posted_Amount__c);
    }
}