/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
public with sharing class TxnAdjustmentAggregationTest {

    private static Decimal CG_EXT_ID = 456;

    @TestSetup
    public static void setupData() {
        Contact gt = TestUtility.generateGuarantorContact();
        Contact pt = TestUtility.generatePatientContact();

        insert new Contact[] { gt, pt };

        Charge_Group__c cg = TestUtility.generateChargeGroup(gt.Id, pt.Id, CG_EXT_ID);
        insert  cg;

    }

    /*
     *  When a sirono payment's transactions are saved, the payment's posted_amount should be the absolute value
     *  of the sum of all the transactions' amounts. The Payment amount shouldn't change
     */
    @IsTest
    public static void testAdjustmentAmountAggregation() {
        Contact gt = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];
        Charge_Group__c cg = [SELECT Id FROM Charge_Group__c];

        Adjustment__c adj = TestUtility.generateAdjustment(gt.Id, 'Some:Fake:Key', null);
        insert adj;

        Test.startTest();

        Transaction__c[] txns = new List<Transaction__c>();
        txns.add(TestUtility.generateAdjTxn(cg, 300.00, adj));
        txns.add(TestUtility.generateAdjTxn(cg, 150.00, adj));
        txns.add(TestUtility.generateAdjTxn(cg, 50.00, adj));

        insert txns;

        Test.stopTest();

        adj = [SELECT Id, Amount__c FROM Adjustment__c];

        System.assertEquals(-500.00 , adj.Amount__c, 'Expected adjustment amount to be -500.00, but was: ' + adj.Amount__c);
    }

    @IsTest
    public static void testAdjustmentTxnUpdated() {
        Contact gt = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];
        Charge_Group__c cg = [SELECT Id FROM Charge_Group__c];

        Adjustment__c adj = TestUtility.generateAdjustment(gt.Id, 'Some:Fake:Key', null);
        insert adj;

        Transaction__c[] txns = new List<Transaction__c>();
        txns.add(TestUtility.generateAdjTxn(cg, 300.00, adj));
        txns.add(TestUtility.generateAdjTxn(cg, 150.00, adj));
        txns.add(TestUtility.generateAdjTxn(cg, 50.00, adj));

        insert txns;

        Test.startTest();
        adj = [SELECT Id, Amount__c FROM Adjustment__c];

        System.assertEquals(-500.00 , adj.Amount__c, 'Expected adjustment amount to be -500.00, but was: ' + adj.Amount__c);

        for (Transaction__c txn : txns) {
            txn.Amount__c = txn.Amount__c - 20.00;
        }

        update txns;

        Test.stopTest();

        adj = [SELECT Id, Amount__c FROM Adjustment__c];

        System.assertEquals(-440.00 , adj.Amount__c, 'Expected adjustment amount to be -440.00, but was: ' + adj.Amount__c);
    }

    @IsTest
    public static void testAdjustmentTxnDeleted() {
        Contact gt = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];
        Charge_Group__c cg = [SELECT Id FROM Charge_Group__c];

        Adjustment__c adj = TestUtility.generateAdjustment(gt.Id, 'Some:Fake:Key', null);
        insert adj;

        Transaction__c[] txns = new List<Transaction__c>();
        txns.add(TestUtility.generateAdjTxn(cg, 300.00, adj));
        txns.add(TestUtility.generateAdjTxn(cg, 150.00, adj));
        txns.add(TestUtility.generateAdjTxn(cg, 50.00, adj));

        insert txns;

        Test.startTest();
        adj = [SELECT Id, Amount__c FROM Adjustment__c];

        System.assertEquals(-500.00 , adj.Amount__c, 'Expected adjustment amount to be -500.00, but was: ' + adj.Amount__c);

        DELETE txns[2];

        Test.stopTest();

        adj = [SELECT Id, Amount__c FROM Adjustment__c];

        System.assertEquals(-450.00 , adj.Amount__c, 'Expected adjustment amount to be -450.00, but was: ' + adj.Amount__c);
    }

    @IsTest
    public static void testAdjustmentTxnAdded() {
        Contact gt = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];
        Charge_Group__c cg = [SELECT Id FROM Charge_Group__c];

        Adjustment__c adj = TestUtility.generateAdjustment(gt.Id, 'Some:Fake:Key', null);
        insert adj;

        Transaction__c[] txns = new List<Transaction__c>();
        txns.add(TestUtility.generateAdjTxn(cg, 300.00, adj));
        txns.add(TestUtility.generateAdjTxn(cg, 150.00, adj));

        insert txns;

        Test.startTest();
        adj = [SELECT Id, Amount__c FROM Adjustment__c];
        System.assertEquals(-450.00 , adj.Amount__c, 'Expected adjustment amount to be -450.00, but was: ' + adj.Amount__c);

        Transaction__c newTxn = TestUtility.generateAdjTxn(cg, 50.00, adj);
        insert newTxn;
        Test.stopTest();

        adj = [SELECT Id, Amount__c FROM Adjustment__c];

        System.assertEquals(-500.00 , adj.Amount__c, 'Expected adjustment amount to be -500.00, but was: ' + adj.Amount__c);
    }

    @IsTest
    public static void testAdjustmentTxnDeleteAll() {
        Contact gt = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];
        Charge_Group__c cg = [SELECT Id FROM Charge_Group__c];

        Adjustment__c adj = TestUtility.generateAdjustment(gt.Id, 'Some:Fake:Key', null);
        insert adj;

        Transaction__c[] txns = new List<Transaction__c>();
        txns.add(TestUtility.generateAdjTxn(cg, 300.00, adj));
        txns.add(TestUtility.generateAdjTxn(cg, 150.00, adj));
        txns.add(TestUtility.generateAdjTxn(cg, 50.00, adj));
        insert txns;

        Test.startTest();
        adj = [SELECT Id, Amount__c FROM Adjustment__c];
        System.assertEquals(-500.00 , adj.Amount__c, 'Expected adjustment amount to be -500.00, but was: ' + adj.Amount__c);

        delete txns;
        Test.stopTest();

        adj = [SELECT Id, Amount__c FROM Adjustment__c];

        System.assertEquals(0 , adj.Amount__c, 'Expected adjustment amount to be 0.00, but was: ' + adj.Amount__c);
    }
}