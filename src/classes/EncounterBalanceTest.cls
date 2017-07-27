/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Tests for calculating an Encounter's Balance
 */
@IsTest
public with sharing class EncounterBalanceTest {

    /**
     * This method is used to setup preliminary data to let's all testmethods to execute as expected.
     **/
    @TestSetup
    public static void setupData() {
        Test.startTest();
        Encounter__c encounter = new Encounter__c();
        encounter.Patient_Portion__c = 3000.00;
        encounter.Department__c = 'Test Dept';
        insert encounter;
        Test.stopTest();

        // Check system assert.
        System.assertNotEquals(encounter.Id, null, 'Encounter record does not exists/created.');
    }

    private static Encounter__c getTestEncounter() {
        return [
            SELECT Id, Patient_Portion__c, Balance__c
            FROM Encounter__c
            WHERE Department__c = 'Test Dept'
        ];
    }

    /**
     * This method checks logic for Partial Payment of Encounter's balance.
     **/
    @IsTest
    public static void testEncounterBalancePartialPayment() {
        Encounter__c encounter = getTestEncounter();

        Test.startTest();
        Payment__c pmt1 = new Payment__c();
        pmt1.Amount__c = 600.00;
        pmt1.Encounter__c = encounter.Id;

        Payment__c pmt2 = new Payment__c();
        pmt2.Amount__c = 400.00;
        pmt2.Encounter__c = encounter.Id;

        insert new Payment__c[] { pmt1, pmt2 };
        Test.stopTest();

        // Check system assert.
        encounter = getTestEncounter();
        System.assert(encounter.Balance__c == 2000.00,
            'Expected Balance__c to be 2000.00, but was: ' + encounter.Balance__c);
    }

    /**
     * This method checks logic of Encounter's balance after Payment update.
     **/
    @IsTest
    public static void testEncounterBalanceAfterPaymentChanges() {
        Encounter__c encounter = getTestEncounter();

        Test.startTest();
        // Save a payment associated with the Encounter
        Payment__c pmt1 = new Payment__c();
        pmt1.Amount__c = 600.00;
        pmt1.Encounter__c = encounter.Id;

        insert pmt1;

        // Change the amount of the payment
        pmt1 = [SELECT Id, Amount__c FROM Payment__c WHERE Encounter__c = :encounter.Id];
        pmt1.Amount__c = 800.00;
        update pmt1;

        Test.stopTest();

        // Check system assert.
        encounter = getTestEncounter();
        System.assert(encounter.Balance__c == 2200.00,
            'Expected Balance__c to be 2200.00, but was: ' + encounter.Balance__c);
    }

    /**
     * This method checks logic for Encounter balance.
     **/
    @IsTest
    public static void testEncounterBalance() {
        Encounter__c encounter = getTestEncounter();

        Test.startTest();
        Contact gt = TestUtility.generateGuarantorContact();
        insert gt;

        Contact pt = TestUtility.generatePatientContact();
        insert pt;

        Test.stopTest();

        // Check system assert.
        encounter = getTestEncounter();
        System.assert(encounter.Balance__c == 3000.00, 'Expected Balance__c to be 3000, but was: ' + encounter.Balance__c);
    }

    /**
     * This method checks logic for Encounter's balance after delete Payment.
     **/
    @IsTest
    public static void testEncounterBalanceAfterDeletePayment() {
        Encounter__c encounter = getTestEncounter();

        Test.startTest();
        Payment__c pmt1 = new Payment__c();
        pmt1.Encounter__c = encounter.Id;
        pmt1.Amount__c = 300;
        insert pmt1;

        Payment__c pmt2 = new Payment__c();
        pmt2.Encounter__c = encounter.Id;
        pmt2.Amount__c = 200;
        insert pmt2;

        // Check system assert.
        encounter = getTestEncounter();
        System.assert(encounter.Balance__c == 2500.00,
            'Expected encounter balance of 2500.00, but got ' + encounter.Balance__c);
        delete pmt2;

        Test.stopTest();

        // Check system assert.
        encounter = getTestEncounter();
        System.assert(encounter.Balance__c == 2700.00,
            'Expected encounter balance of 2700.00, but got ' + encounter.Balance__c);
    }

    /**
     * This method checks logic for Encounter's balance after delete last Payment.
     **/
    @IsTest
    public static void testEncounterBalanceAfterDeleteLastPayment() {
        Encounter__c encounter = getTestEncounter();
        Test.startTest();

        Payment__c pmt1 = new Payment__c();
        pmt1.Encounter__c = encounter.Id;
        pmt1.Amount__c = 300;
        insert pmt1;

        // Check system assert.
        encounter = getTestEncounter();
        System.assert(encounter.Balance__c == 2700.00,
            'Expected encounter balance of 2700.00, but got ' + encounter.Balance__c);
        delete pmt1;

        Test.stopTest();

        // Check system assert.
        encounter = getTestEncounter();
        System.assert(encounter.Balance__c == 3000.00,
            'Expected encounter balance of 3000.00, but got ' + encounter.Balance__c);
    }
}