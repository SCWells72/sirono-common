/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Test the CaseService
 **/
@isTest
public with sharing class CaseServiceTest{

    private static String GT_SIRONO_ID = '12345';

    @TestSetup
    public static void setup() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_ID__c = Decimal.valueOf(GT_SIRONO_ID);
        INSERT guarantorContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1214);
        INSERT chargeGroup;

        // Check system assert.
        System.assertEquals(Decimal.valueOf(GT_SIRONO_ID), guarantorContact.Profile_Pointer_ID__c, 'Expected Profile_Pointer_ID__c is ' + GT_SIRONO_ID + ' but got '+ guarantorContact.Profile_Pointer_ID__c);
    }

    /**
     * This method tests the logic of insertCaseCGJunRecords method for Overdue CG and Case.
     **/
    @isTest
    public static void testCreateCaseCGJunctionsOverdue(){
        Contact gt = [SELECT Id FROM Contact];
        Charge_Group__c chargeGroup = [SELECT Id FROM Charge_Group__c];

        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        UPDATE chargeGroup;

        Test.startTest();
        Case objCase = TestUtility.generateCase(RecordTypeUtil.automatedCaseRt, Constants.CASE_TYPE_OVERDUE, gt.Id);
        INSERT objCase;
        Test.stopTest();

        // Check system asserts.
        List<Case_Charge_Group_Junction__c> caseCGJun = [SELECT Id, Case__c, Charge_Group__c FROM Case_Charge_Group_Junction__c];
        System.assertEquals(1, caseCGJun.size(), 'Expected Case_Charge_Group_Junction__c size equals to 1 but we got ' + caseCGJun.size());
        System.assertEquals(chargeGroup.Id, caseCGJun[0].Charge_Group__c, 'Expected Charge_Group__c equals to ' + chargeGroup.Id + ' but we got ' + caseCGJun[0].Charge_Group__c);
        System.assertEquals(objCase.Id, caseCGJun[0].Case__c, 'Expected Case__c equals to ' + objCase.Id + ' but we got ' + caseCGJun[0].Case__c);
    }

    /**
     * This method tests the logic of createCaseCGJunctions for Delinquent & PaymentPlan CG and Cases
     * for the same guarantor.
     **/
    @isTest
    public static void testCreateCaseCGJunctionsDelinquentAndPaymentPlan(){
        Contact gt = [SELECT Id FROM Contact];

        Charge_Group__c chargeGroup = [SELECT Id FROM Charge_Group__c];
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        UPDATE chargeGroup;

        Charge_Group__c ppChargeGroup = TestUtility.generateChargeGroup(gt.Id, null, 1215);
        ppChargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        INSERT ppChargeGroup;

        //This chargegroup shouldn't be picked up
        Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(gt.Id, null, 1216);
        chargeGroup1.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        INSERT chargeGroup1;

        Test.startTest();
        Case objCase = TestUtility.generateCase(RecordTypeUtil.automatedCaseRt, Constants.CASE_TYPE_PAYMENT_PLAN_ERROR, gt.Id);
        INSERT objCase;

        Case pcObjCase = TestUtility.generateCase(RecordTypeUtil.automatedCaseRt, Constants.CASE_TYPE_PRECOLLECTIONS, gt.Id);
        INSERT pcObjCase;
        Test.stopTest();

        // Check system asserts.
        List<Case_Charge_Group_Junction__c> caseCGJunctions = [SELECT Id, Case__c, Charge_Group__c FROM Case_Charge_Group_Junction__c];
        System.assertEquals(2, caseCGJunctions.size(), 'Expected Case_Charge_Group_Junction__c size equals to 2 but we got ' + caseCGJunctions.size());

        for (Case_Charge_Group_Junction__c junction : caseCGJunctions) {
            Case jCase = [SELECT Id, Type FROM Case WHERE Id = :junction.Case__c];
            Charge_Group__c cg = [SELECT Id, Active__c, Account_Sub_Status__c FROM Charge_Group__c WHERE Id = :junction.Charge_Group__c];

            System.assertEquals(Constants.CASE_CG_SUBSTATUS.get(jCase.Type), cg.Account_Sub_Status__c,
                    'Expected substatus of ' + Constants.CASE_CG_SUBSTATUS.get(jCase.Type) + ' but got ' + cg.Account_Sub_Status__c);
        }
    }

    /**
     * This method tests the logic of insertCaseCGJunRecords method for multiple CG and Case.
     **/
    @isTest
    public static void testCreateCaseCGJunctionMultipleCG(){
        Contact gt = [SELECT Id FROM Contact];
        Charge_Group__c chargeGroup = [SELECT Id FROM Charge_Group__c];

        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        UPDATE chargeGroup;

        Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(gt.Id, null, 1214);
        chargeGroup1.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        INSERT chargeGroup1;

        Test.startTest();
        Case objCase = TestUtility.generateCase(RecordTypeUtil.automatedCaseRt, Constants.CASE_TYPE_OVERDUE, gt.Id);
        INSERT objCase;
        Test.stopTest();

        // Check system asserts.
        List<Case_Charge_Group_Junction__c> caseCGJun = [SELECT Id, Case__c, Charge_Group__c FROM Case_Charge_Group_Junction__c];
        System.assertEquals(2, caseCGJun.size(), 'Expected Case_Charge_Group_Junction__c size equals to 2 but we got ' + caseCGJun.size());
    }

    /**
     * This method tests the logic of insertCaseCGJunRecords method with different contact.
     **/
    @isTest
    public static void testCreateCaseCGJunctionsDifferentContacts(){
        Contact gt = [SELECT Id FROM Contact];
        Charge_Group__c chargeGroup = [SELECT Id FROM Charge_Group__c];

        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        UPDATE chargeGroup;

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1214);
        chargeGroup1.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        INSERT chargeGroup1;

        Test.startTest();
        Case objCase = TestUtility.generateCase(RecordTypeUtil.automatedCaseRt, Constants.CASE_TYPE_OVERDUE, gt.Id);
        INSERT objCase;
        Test.stopTest();

        // Check system asserts.
        List<Case_Charge_Group_Junction__c> caseCGJun = [SELECT Id, Case__c, Charge_Group__c FROM Case_Charge_Group_Junction__c];
        System.assertEquals(1, caseCGJun.size(), 'Expected Case_Charge_Group_Junction__c size equals to 1 but we got ' + caseCGJun.size());
    }

    /**
     * This method tests the logic of insertCaseCGJunRecords method negative.
     **/
    @isTest
    public static void testCreateCaseCGJunctionsNegativeTest(){
        Contact gt = [SELECT Id FROM Contact];
        Charge_Group__c chargeGroup = [SELECT Id FROM Charge_Group__c];

        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_BAD_DEBT;
        UPDATE chargeGroup;

        Test.startTest();
        Case objCase = TestUtility.generateCase(RecordTypeUtil.automatedCaseRt, Constants.CASE_TYPE_OVERDUE, gt.Id);
        INSERT objCase;
        Test.stopTest();

        // Check system asserts.
        List<Case_Charge_Group_Junction__c> caseCGJun = [SELECT Id, Case__c, Charge_Group__c FROM Case_Charge_Group_Junction__c];
        System.assertEquals(0, caseCGJun.size(), 'Case_Charge_Group_Junction__c size should have 0 but we got ' + caseCGJun.size());
    }
}