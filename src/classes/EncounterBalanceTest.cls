/**
 * Tests for calculating an Encounter's Balance
 */
@isTest
public with sharing class EncounterBalanceTest {

    @testSetup
    public static void setupData() {
        Encounter__c encounter = new Encounter__c();
        encounter.Patient_Portion__c = 3000.00;
        encounter.Department__c = 'Test Dept';
        INSERT encounter;
    }

    @isTest
    public static void testEncounterBalancePartialPayment() {
        Encounter__c encounter = [SELECT Id, Patient_Portion__c FROM Encounter__c WHERE Department__c = 'Test Dept'];

        Test.startTest();
        Payment__c pmt1 = new Payment__c();
        pmt1.Amount__c = 600.00;
        pmt1.Encounter__c = encounter.Id;

        Payment__c pmt2 = new Payment__c();
        pmt2.Amount__c = 400.00;
        pmt2.Encounter__c = encounter.Id;

        INSERT new Payment__c[]{pmt1, pmt2};
        Test.stopTest();

        encounter = [SELECT Id, Balance__c, Has_Chargegroup__c FROM Encounter__c WHERE Department__c = 'Test Dept'];
        System.assert(!encounter.Has_Chargegroup__c, 'Expected Has_Chargegroup__c to be false');
        System.assert(encounter.Balance__c == 2000.00, 'Expected Balance__c to be 2000.00, but was: '+encounter.Balance__c);
    }

    @isTest
    public static void testEncounterZeroBalanceChargeGroup() {
        Encounter__c encounter = [SELECT Id, Patient_Portion__c FROM Encounter__c WHERE Department__c = 'Test Dept'];

        Test.startTest();
        Contact gt = TestUtility.generateGuarantorContact();
        INSERT gt;

        Contact pt = TestUtility.generatePatientContact();
        INSERT pt;

        Charge_Group__c cg = TestUtility.generateChargeGroupWithExternalId(gt.Id, pt.Id, 12345);
        cg.Encounter__c = encounter.Id;
        INSERT cg;

        Test.stopTest();

        encounter = [SELECT Id, Balance__c, Has_Chargegroup__c FROM Encounter__c WHERE Department__c = 'Test Dept'];
        System.assert(encounter.Has_Chargegroup__c, 'Expected Has_Chargegroup__c to be true');
        System.assert(encounter.Balance__c == 0.00, 'Expected Balance__c to be 0, but was: '+encounter.Balance__c);
    }


    @isTest
    public static void testEncounterBalanceAfterDeleteChargeGroup() {
        Encounter__c encounter = [SELECT Id, Patient_Portion__c FROM Encounter__c WHERE Department__c = 'Test Dept'];

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

        encounter = [SELECT Id, Balance__c, Has_Chargegroup__c FROM Encounter__c WHERE Department__c = 'Test Dept'];
        System.assert(!encounter.Has_Chargegroup__c, 'Expected Has_Chargegroup__c to be false');
        System.assert(encounter.Balance__c == 3000.00, 'Expected Balance__c to be 2000, but was: '+encounter.Balance__c);
    }
}