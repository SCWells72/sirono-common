/**
 * Test the ChargeGroupService
 **/

@isTest
public with sharing class ChargeGroupServiceTest{
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

    public static List<RecordType> getRecordTypeId(){
        return [SELECT Id FROM RecordType
                WHERE SobjectType = 'Case'
                AND DeveloperName = 'Automated_Cases'
        ];
    }

    /**
     * This method tests the logic of insertCaseCGJunRecords method for Overdue CG and Case.
     **/
    @isTest
    public static void insertCaseCGJunRecordsForOverdueTest(){
        Contact gt = [SELECT Id FROM Contact];
        Charge_Group__c chargeGroup = [SELECT Id FROM Charge_Group__c];
        List<RecordType> rt = getRecordTypeId();

        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        UPDATE chargeGroup;

        Test.startTest();
        Case objCase = TestUtility.generateCase(rt[0].Id, Constants.CASE_TYPE_OVERDUE, gt.Id);
        INSERT objCase;
        Test.stopTest();

        // Check system asserts.
        List<Case_Charge_Group_Junction__c> caseCGJun = [SELECT Id, Case__c, Charge_Group__c FROM Case_Charge_Group_Junction__c];
        System.assertEquals(1, caseCGJun.size(), 'Expected Case_Charge_Group_Junction__c size equals to 1 but we got ' + caseCGJun.size());
        System.assertEquals(chargeGroup.Id, caseCGJun[0].Charge_Group__c, 'Expected Charge_Group__c equals to ' + chargeGroup.Id + ' but we got ' + caseCGJun[0].Charge_Group__c);
        System.assertEquals(objCase.Id, caseCGJun[0].Case__c, 'Expected Case__c equals to ' + objCase.Id + ' but we got ' + caseCGJun[0].Case__c);
    }

    /**
     * This method tests the logic of insertCaseCGJunRecords method for Delinquent CG and Case.
     **/
    @isTest
    public static void insertCaseCGJunRecordsForDelinquentTest(){
        Contact gt = [SELECT Id FROM Contact];
        Charge_Group__c chargeGroup = [SELECT Id FROM Charge_Group__c];
        List<RecordType> rt = getRecordTypeId();

        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        UPDATE chargeGroup;

        Test.startTest();
        Case objCase = TestUtility.generateCase(rt[0].Id, Constants.CASE_TYPE_PRECOLLECTIONS, gt.Id);
        INSERT objCase;
        Test.stopTest();

        // Check system asserts.
        List<Case_Charge_Group_Junction__c> caseCGJun = [SELECT Id, Case__c, Charge_Group__c FROM Case_Charge_Group_Junction__c];
        System.assertEquals(1, caseCGJun.size(), 'Expected Case_Charge_Group_Junction__c size equals to 1 but we got ' + caseCGJun.size());
        System.assertEquals(chargeGroup.Id, caseCGJun[0].Charge_Group__c, 'Expected Charge_Group__c equals to ' + chargeGroup.Id + ' but we got ' + caseCGJun[0].Charge_Group__c);
        System.assertEquals(objCase.Id, caseCGJun[0].Case__c, 'Expected Case__c equals to ' + objCase.Id + ' but we got ' + caseCGJun[0].Case__c);
    }

    /**
     * This method tests the logic of insertCaseCGJunRecords method for PaymentPlan CG and Case.
     **/
    @isTest
    public static void insertCaseCGJunRecordsForPaymentPlanTest(){
        Contact gt = [SELECT Id FROM Contact];
        Charge_Group__c chargeGroup = [SELECT Id FROM Charge_Group__c];
        List<RecordType> rt = getRecordTypeId();

        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        UPDATE chargeGroup;

        Test.startTest();
        Case objCase = TestUtility.generateCase(rt[0].Id, Constants.CASE_TYPE_PAYMENT_PLAN_ERROR, gt.Id);
        INSERT objCase;
        Test.stopTest();

        // Check system asserts.
        List<Case_Charge_Group_Junction__c> caseCGJun = [SELECT Id, Case__c, Charge_Group__c FROM Case_Charge_Group_Junction__c];
        System.assertEquals(1, caseCGJun.size(), 'Expected Case_Charge_Group_Junction__c size equals to 1 but we got ' + caseCGJun.size());
        System.assertEquals(chargeGroup.Id, caseCGJun[0].Charge_Group__c, 'Expected Charge_Group__c equals to ' + chargeGroup.Id + ' but we got ' + caseCGJun[0].Charge_Group__c);
        System.assertEquals(objCase.Id, caseCGJun[0].Case__c, 'Expected Case__c equals to ' + objCase.Id + ' but we got ' + caseCGJun[0].Case__c);
    }

    /**
     * This method tests the logic of insertCaseCGJunRecords method for multiple CG and Case.
     **/
    @isTest
    public static void insertCaseCGJunRecordsWithMultipleCGTest(){
        Contact gt = [SELECT Id FROM Contact];
        Charge_Group__c chargeGroup = [SELECT Id FROM Charge_Group__c];
        List<RecordType> rt = getRecordTypeId();

        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        UPDATE chargeGroup;

        Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(gt.Id, null, 1214);
        chargeGroup1.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        INSERT chargeGroup1;

        Test.startTest();
        Case objCase = TestUtility.generateCase(rt[0].Id, Constants.CASE_TYPE_OVERDUE, gt.Id);
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
    public static void insertCaseCGJunRecordsWithDifferentContactTest(){
        Contact gt = [SELECT Id FROM Contact];
        Charge_Group__c chargeGroup = [SELECT Id FROM Charge_Group__c];
        List<RecordType> rt = getRecordTypeId();

        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        UPDATE chargeGroup;

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1214);
        chargeGroup1.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        INSERT chargeGroup1;

        Test.startTest();
        Case objCase = TestUtility.generateCase(rt[0].Id, Constants.CASE_TYPE_OVERDUE, gt.Id);
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
    public static void insertCaseCGJunRecordsNegativeTest(){
        Contact gt = [SELECT Id FROM Contact];
        Charge_Group__c chargeGroup = [SELECT Id FROM Charge_Group__c];
        List<RecordType> rt = getRecordTypeId();

        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_BAD_DEBT;
        UPDATE chargeGroup;

        Test.startTest();
        Case objCase = TestUtility.generateCase(rt[0].Id, Constants.CASE_TYPE_OVERDUE, gt.Id);
        INSERT objCase;
        Test.stopTest();

        // Check system asserts.
        List<Case_Charge_Group_Junction__c> caseCGJun = [SELECT Id, Case__c, Charge_Group__c FROM Case_Charge_Group_Junction__c];
        System.assertEquals(0, caseCGJun.size(), 'Case_Charge_Group_Junction__c size should have 0 but we got ' + caseCGJun.size());
    }
}