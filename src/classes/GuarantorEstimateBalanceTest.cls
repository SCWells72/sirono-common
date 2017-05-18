/**
 * Test the calculation of the Estimate_Balance on the guarantor. It is the sum of all of the Encounters the
 * Guarantor is associated with.
 **/

@isTest
public with sharing class GuarantorEstimateBalanceTest {

    /**
     * This method is used to setup preliminary data to let's all testmethods to execute as expected.
     **/
    @testSetup
    public static void setupData() {
        Test.startTest();
        Encounter__c encounter = new Encounter__c();
        encounter.Patient_Portion__c = 3000.00;
        encounter.Department__c = 'Test Dept';
        encounter.Status__c = 'Ready';
        INSERT encounter;

        Contact gt1 = TestUtility.generateGuarantorContact();
        gt1.LastName = 'GT1';

        Contact gt2 = TestUtility.generateGuarantorContact();
        gt2.LastName = 'GT2';
        INSERT new Contact[]{gt1, gt2};
        Test.stopTest();

        // Check system assert, Encounter record should must be created/exist.
        System.assertNotEquals(encounter.Id, null, 'Encounter record does not exists/created.');
    }

    /**
     * This method tests the logic for estimate balance of Guarantor contact.
     **/
    @isTest
    public static void testGTEstimateBalance() {
        Encounter__c encounter = [SELECT Id, Patient_Portion__c FROM Encounter__c WHERE Department__c = 'Test Dept'];
        Contact gt = [SELECT Id, Estimate_Balance__c FROM Contact WHERE LastName = 'GT1'];

        encounter.Guarantor__c = gt.Id;
        UPDATE encounter;

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
	gt = [SELECT Id, Estimate_Balance__c FROM Contact WHERE Id = :gt.Id];
        System.assert(gt.Estimate_Balance__c == 2000.00,
                'Expected Estimate_Balance__c to be 2000.00, but was: '+gt.Estimate_Balance__c);
    }

    /**
     * This method tests the logic for estimate balance of Guarantor contact negative.
     * Set Encounter status equals to "In Process" so Encounter Substatus set with "Unavailable" and Guarantor's estimate balance becomes 0.
     **/
    @isTest
    public static void testGTEstimateBalanceNegative() {
        Encounter__c encounter = [SELECT Id, Patient_Portion__c FROM Encounter__c WHERE Department__c = 'Test Dept'];
        Contact gt = [SELECT Id, Estimate_Balance__c FROM Contact WHERE LastName = 'GT1'];

        encounter.Guarantor__c = gt.Id;
        UPDATE encounter;

        // Check system assert.
        gt = [SELECT Id, Estimate_Balance__c FROM Contact WHERE Id = :gt.Id];
        System.assert(gt.Estimate_Balance__c == 3000.00,
                'Expected Estimate_Balance__c to be 3000.00, but was: '+gt.Estimate_Balance__c);

        Test.startTest();

        // Update Encounter with "In Process" Status.
        encounter = [SELECT Id, Patient_Portion__c, Status__c FROM Encounter__c WHERE Department__c = 'Test Dept'];
        encounter.Status__c = 'In Process';
        UPDATE encounter;

        Test.stopTest();

        // Check system assert.
        gt = [SELECT Id, Estimate_Balance__c FROM Contact WHERE Id = :gt.Id];
        System.assert(gt.Estimate_Balance__c == 0,
                'Expected Estimate_Balance__c to be 0, but was: '+gt.Estimate_Balance__c);
    }

    /**
     * This method checks contact's Estimate Balance after update encounter's guarantor with another contact.
     **/
    @isTest
    public static void testGTEstimateBalanceChangeEncounterGuarantor() {
        Encounter__c encounter = [SELECT Id, Patient_Portion__c FROM Encounter__c WHERE Department__c = 'Test Dept'];
        Contact gt1 = [SELECT Id, Estimate_Balance__c FROM Contact WHERE LastName = 'GT1'];
        Contact gt2 = [SELECT Id, Estimate_Balance__c FROM Contact WHERE LastName = 'GT2'];

        encounter.Guarantor__c = gt1.Id;
        UPDATE encounter;

         // Check system assert.
	gt1 = [SELECT Id, Estimate_Balance__c FROM Contact WHERE Id = :gt1.Id];
        System.assert(gt1.Estimate_Balance__c == 3000.00,
                'Expected Estimate_Balance__c to be 3000, but was: '+gt1.Estimate_Balance__c);

        Test.startTest();

        encounter = [SELECT Id FROM Encounter__c WHERE Department__c = 'Test Dept'];
        encounter.Guarantor__c = gt2.Id;
        UPDATE encounter;

        Test.stopTest();

	// Check system assert.
        gt1 = [SELECT Id, Estimate_Balance__c FROM Contact WHERE Id = :gt1.Id];
        gt2 = [SELECT Id, Estimate_Balance__c FROM Contact WHERE Id = :gt2.Id];

        System.assert(gt1.Estimate_Balance__c == 0,
                'Expected Estimate_Balance__c to be 0, but was: '+gt1.Estimate_Balance__c);

        System.assert(gt2.Estimate_Balance__c == 3000.00,
                'Expected Estimate_Balance__c to be 3000, but was: '+gt2.Estimate_Balance__c);
    }

    /**
     * This method validates guarantor's Estimate Balance for zero amount.
     **/
    @isTest
    public static void testGTEstimateZeroBalance() {
        Encounter__c encounter = [SELECT Id FROM Encounter__c WHERE Department__c = 'Test Dept'];
        Contact gt = [SELECT Id, Estimate_Balance__c FROM Contact WHERE LastName = 'GT1'];
        encounter.Guarantor__c = gt.Id;
        UPDATE encounter;

        // Check system assert.
	gt = [SELECT Id, Estimate_Balance__c FROM Contact WHERE Id = :gt.Id];
        System.assert(gt.Estimate_Balance__c == 3000.00,
                'Expected Estimate_Balance__c to be 3000, but was: '+gt.Estimate_Balance__c);

        Test.startTest();

        Contact pt = TestUtility.generatePatientContact();
        INSERT pt;

        Charge_Group__c cg = TestUtility.generateChargeGroupWithExternalId(gt.Id, pt.Id, 12345);
        cg.Encounter__c = encounter.Id;
        INSERT cg;

        Test.stopTest();

	// Check system assert.
        encounter = [SELECT Id, Has_Chargegroup__c FROM Encounter__c WHERE Department__c = 'Test Dept'];
        System.assert(encounter.Has_Chargegroup__c, 'Expected Encounter Has_Chargegroup__c to be true');

        gt = [SELECT Id, Estimate_Balance__c FROM Contact WHERE Id = :gt.Id];
        System.assert(gt.Estimate_Balance__c == 0,
                'Expected Estimate_Balance__c to be 0 for gt: '+gt.Id+', but was: '+gt.Estimate_Balance__c);
    }

    /**
     * This method checks validates Estimate Balance after Encounter record gets deleted.
     **/
    @isTest
    public static void testGTEstimateBalanceAfterEncounterDeleted() {
        Encounter__c encounter = [SELECT Id, Patient_Portion__c FROM Encounter__c WHERE Department__c = 'Test Dept'];
        Contact gt = [SELECT Id, Estimate_Balance__c FROM Contact WHERE LastName = 'GT1'];

        encounter.Guarantor__c = gt.Id;
        UPDATE encounter;
        
	// Check system assert.
	gt = [SELECT Id, Estimate_Balance__c FROM Contact WHERE Id = :gt.Id];
        System.assert(gt.Estimate_Balance__c == 3000.00,
                'Expected Estimate_Balance__c to be 3000.00, but was: '+gt.Estimate_Balance__c);

        Test.startTest();

        DELETE encounter;

        Test.stopTest();

	// Check system assert.
        gt = [SELECT Id, Estimate_Balance__c FROM Contact WHERE Id = :gt.Id];
        System.assert(gt.Estimate_Balance__c == 0.00,
                'Expected Estimate_Balance__c to be 0.00, but was: '+gt.Estimate_Balance__c);
    }
}