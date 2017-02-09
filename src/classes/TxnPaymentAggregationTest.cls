/**
 * Test Aggregation of Sirono Payment transactions
 * Sirono Payments are taken by an agent or via the portal. They have a sirono_id (ID__c) and a guarantor. The Amount
 * is set at the time the payment is taken. The Posted_Amount is the sum of all of the payment's transactions
 */
@isTest
public with sharing class TxnPaymentAggregationTest {
    private static String CG_EXT_ID = '456';

    @testSetup
    public static void setupData() {
        Contact gt = TestUtility.generateGuarantorContact();
        Contact pt = TestUtility.generatePatientContact();

        INSERT new Contact[]{gt, pt};

        gt = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];
        pt = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.patientRt];

        Charge_Group__c cg = TestUtility.generateChargeGroupWithExternalId(gt.Id, pt.Id, Decimal.valueOf(CG_EXT_ID));
        INSERT cg;

        Payment__c payment = TestUtility.generateSironoPayment(gt.Id, 9999999999999.00, 300.00);
        payment.Amount__c = 300.00;
        INSERT payment;
    }

    /*
     *  When a sirono payment's transactions are saved, the payment's posted_amount should be the absolute value
     *  of the sum of all the transactions' amounts. The Payment amount shouldn't change
     */
    @isTest
    public static void testPaymentAmountAggregation() {
        Payment__c payment = [SELECT Id FROM Payment__c];
        Charge_Group__c cg = [SELECT Id FROM Charge_Group__c];

        Test.startTest();

        Transaction__c txn = TestUtility.generatePaymentTxn(cg, -100.00, payment);
        insert txn;

        Test.stopTest();

        payment = [SELECT Id, Amount__c, Posted_Amount__c FROM Payment__c WHERE Id = :payment.Id];

        System.assert(payment.Amount__c == 300.00, 'Expected payment amount to be 300.00, but was: '+payment.Amount__c);
        System.assert(payment.Posted_Amount__c == 100.00,
                'Expected posted amount to be 100.00, but was: '+payment.Posted_Amount__c);
    }

    /*
     * When a sirono payment's transactions are all deleted, the payment's posted_amount should be 0. The amount
     * should not change.
     */
    @isTest
    public static void testPaymentTxnDeleted() {
        Payment__c payment = [SELECT Id  FROM Payment__c];
        Charge_Group__c cg = [SELECT Id FROM Charge_Group__c];

        Test.startTest();

        Transaction__c txn = TestUtility.generatePaymentTxn(cg, -100.00, payment);
        insert txn;

        payment = [SELECT Id, Amount__c, Posted_Amount__c  FROM Payment__c];

        System.assert(payment.Amount__c == 300.00, 'Expected payment amount to be 300.00, but was: '+payment.Amount__c);
        System.assert(payment.Posted_Amount__c == 100.00,
                'Expected Posted_Amount__c to be 100.00, but was: '+payment.Posted_Amount__c);

        txn = [SELECT Id FROM Transaction__c];
        DELETE txn;

        Test.stopTest();

        payment = [SELECT Id, Amount__c, Posted_Amount__c FROM Payment__c WHERE Id = :payment.Id];

        System.assert(payment.Amount__c == 300.00, 'Expected payment amount to be 300.00, but was: '+payment.Amount__c);
        System.assert(payment.Posted_Amount__c == 0.00,
                'Expected payment Posted_Amount__c to be 0.00, but was: '+payment.Posted_Amount__c);
    }
}