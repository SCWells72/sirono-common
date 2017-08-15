/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This class is use to test the logic of PatientDao class.
 **/
@IsTest
public with sharing class PatientDaoTest {

    private static String SIRONO_ID = '12345';

    @TestSetup
    public static void setup() {
        Contact gt = TestUtility.generateGuarantorContact();
        gt.Profile_Pointer_Id__c = Decimal.valueOf(SIRONO_ID);
        insert gt;

        Contact pt = TestUtility.generatePatientContact();
        pt.Patient_Id__c = Decimal.valueOf(SIRONO_ID);
        insert pt;

        // Create Charge Group Record.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(gt.Id, pt.Id, 12345);
        insert chargeGroup;

        Transaction__c transactionObj = TestUtility.generateTransaction(chargeGroup, 100, Constants.AUTOMATIC);
        insert transactionObj;

        // Check system assert.
        System.assertEquals(Decimal.valueOf(SIRONO_ID), pt.Patient_Id__c, 'Expected ' + SIRONO_ID + ' but we got ' + pt.Patient_Id__c);
    }

    private static Contact getTestPatientContact() {
        return [
            SELECT Id, Patient_Id__c
            FROM Contact
            WHERE Patient_Id__c = :Decimal.valueOf(SIRONO_ID)
        ];
    }

    /**
     * This method tests the logic of getPatientContact method.
     **/
    @IsTest
    public static void getPatientContactTest() {
        Contact pt1 = getTestPatientContact();

        Test.startTest();
        Contact pt2 = PatientDao.getPatientContact(pt1.Id);
        Test.stopTest();

        // Check system asserts.
        System.assertEquals(pt1.Id, pt2.Id, 'Patient Ids should be the same');
        System.assertEquals(SIRONO_ID, pt2.Patient_Id__c.toPlainString(),
            'Expected Patient_Id__c of ' + SIRONO_ID + ' but got: ' + pt2.Patient_Id__c.toPlainString());
        System.assertEquals(RecordTypeUtil.patientRt, pt2.RecordTypeId,
            'Expected RecordTypeId of ' + RecordTypeUtil.patientRt + ' but got: ' + pt2.RecordTypeId);
    }

    /**
     * Test the logic of getPatientFilterCGByAcctSubStatus method.
     * CG account substatus is "Preinvoiced" so we get contact with 1 CG.
     **/
    @IsTest
    public static void getPatientFilterCGByAcctSubStatusTest() {
        Contact pt = getTestPatientContact();

        // Call getPatientFilterCGByAcctSubStatus method.
        Test.startTest();
        Contact contact = PatientDao.getPatientFilterCGByAcctSubStatus(pt.Id, Constants.CGConstraintsForCase);
        Test.stopTest();

        // Check system asserts.
        System.assertEquals(1, contact.Charge_Groups_Patient__r.size(), 'Expected contact\'s charge groups size equals to 1 but we got ' + contact.Charge_Groups_Patient__r.size());
        System.assertEquals(pt.Id, contact.Id, 'Patient Ids should be the same.');
        System.assertEquals(Constants.ACCT_SUBSTATUS_PREINVOICED, contact.Charge_Groups_Patient__r.get(0).Account_Sub_Status__c,
            'Expected charge group Account_Sub_Status__c equals to ' + Constants.ACCT_SUBSTATUS_PREINVOICED + ' but we got ' + contact.Charge_Groups_Patient__r.get(0).Account_Sub_Status__c);
    }

    /**
     * Test the logic of getPatientFilterCGByAcctSubStatus method negative.
     **/
    @IsTest
    public static void getPatientFilterCGByAcctSubStatusNegativeTest() {
        Contact pt = getTestPatientContact();

        // Call getPatientFilterCGByAcctSubStatus method.
        Test.startTest();
        // Update CG with Account_Sub_Status__c equals to "Paid".
        Charge_Group__c chargeGroup = [SELECT Id, Account_Sub_Status__c FROM Charge_Group__c];
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAID;
        update chargeGroup;

        Contact contact = PatientDao.getPatientFilterCGByAcctSubStatus(pt.Id, Constants.CGConstraintsForCase);
        Test.stopTest();

        // Check system asserts.
        System.assertEquals(0, contact.Charge_Groups_Patient__r.size(), 'Expected contact\'s charge groups size equals to 0 but we got ' + contact.Charge_Groups_Patient__r.size());
        System.assertEquals(pt.Id, contact.Id, 'Patient Ids should be the same.');
    }
}