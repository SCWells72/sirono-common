/**
 * Test TxnAggregationUtils for PAS Payment transactions
 *
 * A PAS payment comes from the Hospital & will have the pmt_key set, but no guarantor. The Amount and Posted_Amount
 * on it equal the sum of its transactions.
 */

@isTest
public with sharing class TxnPASPmtAggregationTest {

    private static String CG_EXT_ID = '456';
    private static String PAS_KEY = 'someConcatenatedStringOfValues';

    @testSetup
    public static void setupData() {
        Contact gt = TestUtility.generateGuarantorContact();
        Contact pt = TestUtility.generatePatientContact();

        INSERT new Contact[]{gt, pt};

        gt = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];
        pt = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.patientRt];

        Charge_Group__c cg = TestUtility.generateChargeGroupWithExternalId(gt.Id, pt.Id, Decimal.valueOf(CG_EXT_ID));
        INSERT cg;

        Payment__c payment = TestUtility.generatePASPayment(PAS_KEY);
        INSERT payment;
    }

    /*
     *  When a PAS payment's transactions are saved, the payment's amount and posted_amount should be the absolute value
     *  of the sum of all the transactions' amounts
     */
    @isTest
    public static void testPASPaymentAmountAggregation() {
        Payment__c payment = [SELECT Id FROM Payment__c WHERE ID__c = :PAS_KEY];
        Charge_Group__c cg = [SELECT Id FROM Charge_Group__c];

        Test.startTest();

        Transaction__c txn = TestUtility.generatePaymentTxn(cg, -100.00, payment);
        insert txn;

        Test.stopTest();

        payment = [SELECT Id, Amount__c, Posted_Amount__c FROM Payment__c WHERE Id = :payment.Id];

        System.assert(payment.Amount__c == 100.00, 'Expected payment amount to be 100.00, but was: '+payment.Amount__c);
        System.assert(payment.Posted_Amount__c == 100.00,
                'Expected posted amount to be 100.00, but was: '+payment.Posted_Amount__c);
    }

    /*
     * When a PAS payment's transactions are all deleted, the payment's amount and posted_amount should be 0
     */
    @isTest
    public static void testPASPaymentTxnDeleted() {
        Payment__c payment = [SELECT Id FROM Payment__c WHERE ID__c = :PAS_KEY];
        Charge_Group__c cg = [SELECT Id FROM Charge_Group__c];

        Test.startTest();

        Transaction__c txn = TestUtility.generatePaymentTxn(cg, -100.00, payment);
        insert txn;

        payment = [SELECT Id, Amount__c, Posted_Amount__c  FROM Payment__c];
        System.assert(payment.Amount__c == 100.00, 'Expected payment amount to be 100.00, but was: '+payment.Amount__c);
        System.assert(payment.Posted_Amount__c == 100.00,
                'Expected Posted_Amount__c to be 100.00, but was: '+payment.Posted_Amount__c);

        txn = [SELECT Id FROM Transaction__c];
        DELETE txn;

        Test.stopTest();

        payment = [SELECT Id, Amount__c, Posted_Amount__c FROM Payment__c WHERE Id = :payment.Id];

        System.assert(payment.Amount__c == 0.00, 'Expected payment amount to be 0.00, but was: '+payment.Amount__c);
        System.assert(payment.Posted_Amount__c == 0.00,
                'Expected payment Posted_Amount__c to be 0.00, but was: '+payment.Posted_Amount__c);
    }
}