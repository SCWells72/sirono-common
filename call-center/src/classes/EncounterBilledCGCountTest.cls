/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Tests for calculating an Encounter's Billed Charge Group Count.
 **/
@IsTest
public with sharing class EncounterBilledCGCountTest {

    public static final String GUARANTOR_CONTACT = 'guarantorContact';

    /**
     * This method is used to setup preliminary data to let's all testmethods to execute as expected.
     **/
    @TestSetup
    public static void setupData() {
        Test.startTest();
        // Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContactByName(GUARANTOR_CONTACT);
        insert guarantorContact;

        // Create Encounter record.
        Encounter__c encounter = TestUtility.generateEncounter(guarantorContact.Id, 500, System.today());
        encounter.Department__c = 'Test Dept';
        insert encounter;
        Test.stopTest();

        // Check system assert.
        System.assertNotEquals(encounter.Id, null, 'Encounter record does not exists/created.');
    }

    private static Encounter__c getTestEncounter(String deptName) {
        return [
            SELECT Id, Patient_Portion__c, Billed_Charge_Group_Count__c
            FROM Encounter__c
            WHERE Department__c = :deptName
        ];
    }

    private static Contact getTestGuarantor() {
        return [SELECT Id FROM Contact WHERE Name = :GUARANTOR_CONTACT LIMIT 1];
    }

    /**
     * This method checks logic for update Billed_Charge_Group_Count__c field when insert CG with Billed status
     * and an encounter
     **/
    @IsTest
    public static void testEncounterBilledCGCount() {
        Contact guarantorContact = getTestGuarantor();
        Encounter__c encounter = getTestEncounter('Test Dept');

        Test.startTest();
        // Insert CG record.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1214);
        chargeGroup.Encounter__c = encounter.Id;
        insert chargeGroup;
        Test.stopTest();

        // Check system assert.
        System.assertEquals(0, encounter.Billed_Charge_Group_Count__c, 'Bill_Charge_Group should have defaulted to 0 but we got ' + encounter.Billed_Charge_Group_Count__c);
        encounter = getTestEncounter('Test Dept');
        System.assertEquals(1, encounter.Billed_Charge_Group_Count__c, 'Expected Billed_Charge_Group_Count__c to be 1 but we got ' + encounter.Billed_Charge_Group_Count__c);
    }

    /**
     * Check that the counts are recalculated when the chargegroup's encounter changes
     **/
    @IsTest
    public static void testChangeCGEncounter() {
        Contact guarantorContact = getTestGuarantor();
        Encounter__c encounter = getTestEncounter('Test Dept');

        // Create Encounter record.
        Encounter__c enc2 = TestUtility.generateEncounter(guarantorContact.Id, 2000, System.today());
        enc2.Department__c = 'New Dept';
        insert enc2;

        Test.startTest();
        // Insert CG record.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1214);
        chargeGroup.Encounter__c = encounter.Id;
        insert chargeGroup;

        // Check system assert.
        System.assertEquals(0, encounter.Billed_Charge_Group_Count__c, 'Bill_Charge_Group should have defaulted to 0 but we got ' + encounter.Billed_Charge_Group_Count__c);
        encounter = getTestEncounter('Test Dept');
        System.assertEquals(1, encounter.Billed_Charge_Group_Count__c, 'Expected Billed_Charge_Group_Count__c to be 1 but we got ' + encounter.Billed_Charge_Group_Count__c);

        chargeGroup.Encounter__c = enc2.Id;
        update chargeGroup;

        enc2 = getTestEncounter('New Dept');
        encounter = getTestEncounter('Test Dept');
        Test.stopTest();

        System.assertEquals(0, encounter.Billed_Charge_Group_Count__c, 'Bill_Charge_Group should have defaulted to 0 but we got ' + encounter.Billed_Charge_Group_Count__c);
        System.assertEquals(1, enc2.Billed_Charge_Group_Count__c, 'Expected Billed_Charge_Group_Count__c to be 1 but we got ' + enc2.Billed_Charge_Group_Count__c);
    }

    /**
     * Check that the counts are recalculated when an encounter is added to the chargegroup
     **/
    @IsTest
    public static void testUpdateCGAddEncounter() {
        Contact guarantorContact = getTestGuarantor();
        Encounter__c encounter = getTestEncounter('Test Dept');

        Test.startTest();
        // Insert CG record.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1214);
        insert chargeGroup;

        encounter = getTestEncounter('Test Dept');
        // Check system assert.
        System.assertEquals(0, encounter.Billed_Charge_Group_Count__c, 'Bill_Charge_Group should have defaulted to 0 but we got ' + encounter.Billed_Charge_Group_Count__c);

        chargeGroup.Encounter__c = encounter.Id;
        update chargeGroup;

        encounter = getTestEncounter('Test Dept');
        Test.stopTest();

        System.assertEquals(1, encounter.Billed_Charge_Group_Count__c, 'Expected Billed_Charge_Group_Count__c to be 1 but we got ' + encounter.Billed_Charge_Group_Count__c);
    }

    /**
     * This method checks logic for update Billed_Charge_Group_Count__c field when update CG with Pending status.
     **/
    @IsTest
    public static void testCGUpdateStatus() {
        Contact guarantorContact = getTestGuarantor();
        Encounter__c encounter = getTestEncounter('Test Dept');

        Test.startTest();
        // Insert CG record.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1214);
        chargeGroup.Encounter__c = encounter.Id;
        insert chargeGroup;
        Test.stopTest();

        // Check system assert.
        encounter = getTestEncounter('Test Dept');
        System.assertEquals(1, encounter.Billed_Charge_Group_Count__c, 'Expected Billed_Charge_Group_Count__c to be 1 but we got ' + encounter.Billed_Charge_Group_Count__c);

        // Update CG record and set Account_Status__c equals to Pending.
        chargeGroup.Account_Status__c = Constants.ACCT_STATUS_PENDING;
        update chargeGroup;

        // Check system assert.
        encounter = getTestEncounter('Test Dept');
        System.assertEquals(0, encounter.Billed_Charge_Group_Count__c, 'Bill_Charge_Group should have 0 but we got ' + encounter.Billed_Charge_Group_Count__c);
    }

    /**
     * Test calculation of the Billed_Charge_Group_Count__c field when the CG & Encounter are disassociated
     **/
    @IsTest
    public static void testRemoveEncounterFromCG() {
        Contact guarantorContact = getTestGuarantor();
        Encounter__c encounter = getTestEncounter('Test Dept');

        Test.startTest();
        // Insert CG record.
        Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1214);
        chargeGroup1.Encounter__c = encounter.Id;
        insert chargeGroup1;

        Charge_Group__c chargeGroup2 = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1215);
        chargeGroup2.Encounter__c = encounter.Id;
        insert chargeGroup2;
        Test.stopTest();

        // Check system assert.
        encounter = getTestEncounter('Test Dept');
        System.assertEquals(2, encounter.Billed_Charge_Group_Count__c, 'Expected Billed_Charge_Group_Count__c to be 2 but we got ' + encounter.Billed_Charge_Group_Count__c);

        // Update CG record.
        chargeGroup1.Encounter__c = null;
        update chargeGroup1;

        // Check system assert.
        encounter = getTestEncounter('Test Dept');
        System.assertEquals(1, encounter.Billed_Charge_Group_Count__c, 'Expected Billed_Charge_Group_Count__c to be 1 but we got ' + encounter.Billed_Charge_Group_Count__c);
    }

    /**
     * This method checks logic for update Billed_Charge_Group_Count__c field when delete CG.
     **/
    @IsTest
    public static void testDeleteCG() {
        Contact guarantorContact = getTestGuarantor();
        Encounter__c encounter = getTestEncounter('Test Dept');

        Test.startTest();
        // Insert CG record.
        Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1214);
        chargeGroup1.Encounter__c = encounter.Id;
        insert chargeGroup1;

        Charge_Group__c chargeGroup2 = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1215);
        chargeGroup2.Encounter__c = encounter.Id;
        insert chargeGroup2;
        Test.stopTest();

        // Check system assert.
        encounter = getTestEncounter('Test Dept');
        System.assertEquals(2, encounter.Billed_Charge_Group_Count__c, 'Expected Billed_Charge_Group_Count__c to be 2 but we got ' + encounter.Billed_Charge_Group_Count__c);

        // Delete one CG record.
        delete chargeGroup1;

        // Check system assert.
        encounter = getTestEncounter('Test Dept');
        System.assertEquals(1, encounter.Billed_Charge_Group_Count__c, 'Expected Billed_Charge_Group_Count__c to be 1 but we got ' + encounter.Billed_Charge_Group_Count__c);
    }
}