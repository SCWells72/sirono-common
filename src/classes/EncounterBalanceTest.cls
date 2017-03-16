/**
 * Tests for calculating an Encounter's Balance
 */

@isTest
public with sharing class EncounterBalanceTest {

    /**
     * This method is used to setup preliminary data to let's all testmethods to execute as expected.
     **/
    @testSetup
    public static void setupData() {
        Test.startTest();
        Encounter__c encounter = new Encounter__c();
        encounter.Patient_Portion__c = 3000.00;
        encounter.Department__c = 'Test Dept';
        INSERT encounter;
        Test.stopTest();
        
        // Check system assert.
        System.assertNotEquals(encounter.Id, null, 'Encounter record does not exists/created.');
    }

    private static Encounter__c getTestEncounter() {
        return [
                SELECT Id, Patient_Portion__c, Balance__c, Has_Chargegroup__c
                FROM Encounter__c
                WHERE Department__c = 'Test Dept'];
    }
    
    /**
     * This method checks logic for Partial Payment of Encounter's balance.
     **/
    @isTest
    public static void testEncounterBalancePartialPayment() {
        Encounter__c encounter = getTestEncounter();

        Test.startTest();
        Payment__c pmt1 = new Payment__c();
        pmt1.Amount__c = 600.00;
        pmt1.Encounter__c = encounter.Id;

        Payment__c pmt2 = new Payment__c();
        pmt2.Amount__c = 400.00;
        pmt2.Encounter__c = encounter.Id;

        INSERT new Payment__c[]{pmt1, pmt2};
        Test.stopTest();

	// Check system assert.
        encounter = getTestEncounter();
	System.assert(!encounter.Has_Chargegroup__c, 'Expected Has_Chargegroup__c to be false');
        System.assert(encounter.Balance__c == 2000.00,
                'Expected Balance__c to be 2000.00, but was: '+encounter.Balance__c);
    }

    /**
     * This method checks logic of Encounter's balance after Payment update.
     **/
    @isTest
    public static void testEncounterBalanceAfterPaymentChanges() {
        Encounter__c encounter = getTestEncounter();

        Test.startTest();
        // Save a payment associated with the Encounter
        Payment__c pmt1 = new Payment__c();
        pmt1.Amount__c = 600.00;
        pmt1.Encounter__c = encounter.Id;

        INSERT pmt1;

        // Change the amount of the payment
        pmt1 = [SELECT Id, Amount__c FROM Payment__c WHERE Encounter__c = :encounter.Id];
        pmt1.Amount__c = 800.00;
        UPDATE pmt1;

        Test.stopTest();

	// Check system assert.
        encounter = getTestEncounter();
        System.assert(!encounter.Has_Chargegroup__c, 'Expected Has_Chargegroup__c to be false');
        System.assert(encounter.Balance__c == 2200.00,
                'Expected Balance__c to be 2200.00, but was: '+encounter.Balance__c);
    }

    /**
     * This method checks logic for Encounter zero balance with charge group.
     **/
    @isTest
    public static void testEncounterZeroBalanceChargeGroup() {
        Encounter__c encounter = getTestEncounter();

        Test.startTest();
        Contact gt = TestUtility.generateGuarantorContact();
        INSERT gt;

        Contact pt = TestUtility.generatePatientContact();
        INSERT pt;

        Charge_Group__c cg = TestUtility.generateChargeGroupWithExternalId(gt.Id, pt.Id, 12345);
        cg.Encounter__c = encounter.Id;
        INSERT cg;

        Test.stopTest();

	// Check system assert.
        encounter = getTestEncounter();
        System.assert(encounter.Has_Chargegroup__c, 'Expected Has_Chargegroup__c to be true');
        System.assert(encounter.Balance__c == 0.00, 'Expected Balance__c to be 0, but was: '+encounter.Balance__c);
    }

    /**
     * This method checks logic for Encounter's balance after delete charge group.
     **/
    @isTest
    public static void testEncounterBalanceAfterDeleteChargeGroup() {
        Encounter__c encounter = getTestEncounter();

        Test.startTest();
        Contact gt = TestUtility.generateGuarantorContact();
        INSERT gt;

        Contact pt = TestUtility.generatePatientContact();
        INSERT pt;

        Charge_Group__c cg = TestUtility.generateChargeGroupWithExternalId(gt.Id, pt.Id, 12345);
        cg.Encounter__c = encounter.Id;
        INSERT cg;
        List<Charge_Group__c> cgs = [SELECT Id FROM Charge_Group__c WHERE Encounter__c = :encounter.Id];
        DELETE cgs;
        Test.stopTest();

        // Check system assert.
	encounter = [SELECT Id, Balance__c, Has_Chargegroup__c FROM Encounter__c WHERE Department__c = 'Test Dept'];
        System.assert(!encounter.Has_Chargegroup__c, 'Expected Has_Chargegroup__c to be false');
        System.assert(encounter.Balance__c == 3000.00, 'Expected Balance__c to be 3000, but was: '+encounter.Balance__c);
    }

    /**
     * This method checks logic for Encounter's balance after delete Payment.
     **/
    @isTest
    public static void testEncounterBalanceAfterDeletePayment() {
        Encounter__c encounter = getTestEncounter();

        Test.startTest();
        Payment__c pmt1 = new Payment__c();
        pmt1.Encounter__c = encounter.Id;
        pmt1.Amount__c = 300;
        INSERT pmt1;

        Payment__c pmt2 = new Payment__c();
        pmt2.Encounter__c = encounter.Id;
        pmt2.Amount__c = 200;
        INSERT pmt2;

        // Check system assert.
	encounter = getTestEncounter();
        System.assert(encounter.Balance__c == 2500.00,
                'Expected encounter balance of 2500.00, but got ' + encounter.Balance__c);
        Delete pmt2;

        Test.stopTest();
	
        // Check system assert.
	encounter = getTestEncounter();
        System.assert(encounter.Balance__c == 2700.00,
                'Expected encounter balance of 2700.00, but got ' + encounter.Balance__c);
    }

    /**
     * This method checks logic for Encounter's balance after delete last Payment.
     **/
    @isTest
    public static void testEncounterBalanceAfterDeleteLastPayment() {
        Encounter__c encounter = getTestEncounter();
        Test.startTest();

        Payment__c pmt1 = new Payment__c();
        pmt1.Encounter__c = encounter.Id;
        pmt1.Amount__c = 300;
        INSERT pmt1;

        // Check system assert.
	encounter = getTestEncounter();
        System.assert(encounter.Balance__c == 2700.00,
                'Expected encounter balance of 2700.00, but got ' + encounter.Balance__c);
        Delete pmt1;

        Test.stopTest();

	// Check system assert.
        encounter = getTestEncounter();
        System.assert(encounter.Balance__c == 3000.00,
                'Expected encounter balance of 3000.00, but got ' + encounter.Balance__c);
    }
}