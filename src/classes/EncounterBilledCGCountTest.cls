/**
 * Tests for calculating an Encounter's Billed Charge Group Count.
 **/

@isTest
public with sharing class EncounterBilledCGCountTest {

    public static final String GUARANTOR_CONTACT = 'guarantorContact';

    /**
     * This method is used to setup preliminary data to let's all testmethods to execute as expected.
     **/
    @testSetup
    public static void setupData() {
        Test.startTest();
        // Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContactByName(GUARANTOR_CONTACT);
        INSERT guarantorContact;

        // Create Encounter record.
        Encounter__c encounter = TestUtility.generateEncounter(guarantorContact.Id, 500, System.today());
        encounter.Department__c = 'Test Dept';
        INSERT encounter;
        Test.stopTest();
        
        // Check system assert.
        System.assertNotEquals(encounter.Id, null, 'Encounter record does not exists/created.');
    }

    private static Encounter__c getTestEncounter() {
        return [
                SELECT Id, Patient_Portion__c, Billed_Charge_Group_Count__c
                FROM Encounter__c
                WHERE Department__c = 'Test Dept'
        ];
    }

    /**
     * This method checks logic for update Billed_Charge_Group_Count__c field when insert CG with Billed status.
     **/
    @isTest
    public static void testEncounterBilledCGCount() {
        Contact guarantorContact = [SELECT Id FROM Contact WHERE Name = :GUARANTOR_CONTACT LIMIT 1];
        Encounter__c encounter = getTestEncounter();

        Test.startTest();
        // Insert CG record.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1214);
        chargeGroup.Encounter__c = encounter.Id;
        INSERT chargeGroup;
        Test.stopTest();

        // Check system assert.
        System.assertEquals(0, encounter.Billed_Charge_Group_Count__c, 'Bill_Charge_Group should have defaulted to 0 but we got ' + encounter.Billed_Charge_Group_Count__c);
        encounter = getTestEncounter();
        System.assertEquals(1, encounter.Billed_Charge_Group_Count__c, 'Expected Billed_Charge_Group_Count__c to be 1 but we got ' + encounter.Billed_Charge_Group_Count__c);
    }

    /**
     * This method checks logic for update Billed_Charge_Group_Count__c field when update CG with Pending status.
     **/
    @isTest
    public static void testEncounterBilledCGCountForUpdate() {
        Contact guarantorContact = [SELECT Id FROM Contact WHERE Name = :GUARANTOR_CONTACT LIMIT 1];
        Encounter__c encounter = getTestEncounter();

        Test.startTest();
        // Insert CG record.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1214);
        chargeGroup.Encounter__c = encounter.Id;
        INSERT chargeGroup;
        Test.stopTest();

        // Check system assert.
        encounter = getTestEncounter();
        System.assertEquals(1, encounter.Billed_Charge_Group_Count__c, 'Expected Billed_Charge_Group_Count__c to be 1 but we got ' + encounter.Billed_Charge_Group_Count__c);

        // Update CG record and set Account_Status__c equals to Pending.
        chargeGroup.Account_Status__c = Constants.ACCT_STATUS_PENDING;
        UPDATE chargeGroup;

        // Check system assert.
        encounter = getTestEncounter();
        System.assertEquals(0, encounter.Billed_Charge_Group_Count__c, 'Bill_Charge_Group should have 0 but we got ' + encounter.Billed_Charge_Group_Count__c);
    }

    /**
     * This method checks logic for update Billed_Charge_Group_Count__c field when delete CG.
     **/
    @isTest
    public static void testEncounterBilledCGCountForDelete() {
        Contact guarantorContact = [SELECT Id FROM Contact WHERE Name = :GUARANTOR_CONTACT LIMIT 1];
        Encounter__c encounter = getTestEncounter();

        Test.startTest();
        // Insert CG record.
        Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1214);
        chargeGroup1.Encounter__c = encounter.Id;
        INSERT chargeGroup1;

        Charge_Group__c chargeGroup2 = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1215);
        chargeGroup2.Encounter__c = encounter.Id;
        INSERT chargeGroup2;
        Test.stopTest();

        // Check system assert.
        encounter = getTestEncounter();
        System.assertEquals(2, encounter.Billed_Charge_Group_Count__c, 'Expected Billed_Charge_Group_Count__c to be 2 but we got ' + encounter.Billed_Charge_Group_Count__c);

        // Delete one CG record.
        DELETE chargeGroup1;

        // Check system assert.
        encounter = getTestEncounter();
        System.assertEquals(1, encounter.Billed_Charge_Group_Count__c, 'Expected Billed_Charge_Group_Count__c to be 1 but we got ' + encounter.Billed_Charge_Group_Count__c);
    }
}