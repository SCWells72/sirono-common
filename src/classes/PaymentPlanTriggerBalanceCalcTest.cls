/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 09-01-2016
 */

@isTest
public class PaymentPlanTriggerBalanceCalcTest {

    private static Contact g;
    private static Charge_Group__c cg1;
    private static Charge_Group__c cg2;
    private static Transaction__c txn;

    static void init() {

        g = TestUtility.GenerateGuarantorContact();
        insert g;
        System.debug('G id: ' + g.Id);

        cg1 = TestUtility.generateChargeGroup(g.Id, null, 1214);
        insert cg1;

        txn = TestUtility.generateTransaction(cg1, 2300, 'Service');
        insert txn;
    }

    @isTest
    static void testCreatePlan() {

        init();

        System.debug('G id: ' + g.Id);
        //Create a payment plan
        Payment_Plan__c pp = TestUtility.generatePaymentPlan(g);
        insert pp;

        Test.startTest();
        //with one chargegroup
        cg1.Payment_Plan__c = pp.Id;
        update cg1;
        Test.stopTest();

        pp = [SELECT Id, Remaining_Balance__c FROM Payment_Plan__c WHERE Id = :pp.Id];
        System.debug('pp.Payable_Amount__c: ' + pp.Payable_Amount__c);
        System.debug('txnAmount: ' + txn.Amount__c);
        //confirm the payable amount is what we expect
        System.assert(pp.Remaining_Balance__c == txn.Amount__c, 'PaymentPlan value is incorrect');
    }

    @isTest
    static void testAddPayment() {
        init();

        //Create a payment plan
        Payment_Plan__c pp = TestUtility.generatePaymentPlan(g);
        insert pp;

        cg1.Payment_Plan__c = pp.Id;
        update cg1;

        //Start Test Context, to reset all Governor limits
        Test.startTest();
        //Add a $50 credit to the cg
        Transaction__c txn2 = TestUtility.generateTransaction(cg1, -50, 'Credit');
        insert txn2;
        //Finish Test
        Test.stopTest();

        //Get the db values to compare
        Transaction__c[] txns = new Transaction__c[]{
                txn, txn2
        };
        AggregateResult[] sums = [SELECT SUM(Amount__c)tot FROM Transaction__c WHERE Id IN :txns];
        pp = [SELECT Id, Remaining_Balance__c FROM Payment_Plan__c WHERE Id = :pp.Id];
        Decimal txnTotal = (Decimal) sums[0].get('tot');

        System.assert(pp.Remaining_Balance__c == txnTotal, 'PaymentPlan value is incorrect');
    }
}