/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Test the ChargeGroupDao methods
 */
@isTest
public with sharing class ChargeGroupDaoTest {

    @TestSetup
    public static void setup() {
        Contact gt = TestUtility.generateGuarantorContact();
        INSERT gt;
        System.debug('gt.Id: ' + gt.Id);

        List<Charge_Group__c> cgToAddList = TestUtility.generateChargeGroupList(gt.Id);
        Decimal i = 1;
        for (Charge_Group__c cg : cgToAddList) {
            cg.Sirono_ID__c = i++;
        }

        INSERT cgToAddList;

        // Check system assert.
        System.assertEquals(1, cgToAddList[0].Sirono_ID__c, 'Expected Chargegroup Sirono_ID__c equals to 1 but we got ' + cgToAddList[0].Sirono_ID__c);
    }

    @isTest
    public static void getBySironoIdsAllFoundTest() {

        List<Decimal> cgSironoIds = new Decimal[] { 1, 3, 5, 10 };

        Test.startTest();
        Charge_Group__c[] cgs = ChargeGroupDao.getBySironoIds(cgSironoIds);
        Test.stopTest();

        Map<Decimal, Charge_Group__c> cgMap = new Map<Decimal, Charge_Group__c>();
        for (Charge_Group__c cg : cgs) {
            cgMap.put(cg.Sirono_ID__c, cg);
        }

        for (Decimal sironoId : cgSironoIds) {
            System.assert(cgMap.containsKey(sironoId), 'ChargeGroup with sironoId: ' + sironoId + ' not in result set');
        }
    }


    @isTest
    public static void getBySironoIdsNotAllFoundTest() {

        List<Decimal> cgSironoIds = new Decimal[] { 1, 3, 5, 10, 99 };

        Test.startTest();
        Charge_Group__c[] cgs = ChargeGroupDao.getBySironoIds(cgSironoIds);
        Test.stopTest();

        Map<Decimal, Charge_Group__c> cgMap = new Map<Decimal, Charge_Group__c>();
        for (Charge_Group__c cg : cgs) {
            cgMap.put(cg.Sirono_ID__c, cg);
        }

        for (Decimal sironoId : cgSironoIds) {
            if (sironoId != 99) {
                System.assert(cgMap.containsKey(sironoId), 'ChargeGroup with sironoId: ' + sironoId + ' not in result set');
            } else {
                System.assert(!cgMap.containsKey(sironoId), 'ChargeGroup with sironoId: ' + sironoId + ' was in result set');
            }
        }
    }

    @isTest
    public static void updateChargeGroupsTest() {

        Charge_Group__c[] cgs = [SELECT Id, Name, Sirono_ID__c FROM Charge_Group__c];

        for (Charge_Group__c cg : cgs) {
            cg.Name = 'test_name_' + cg.Sirono_ID__c;
        }

        Test.startTest();
        ChargeGroupDao.updateChargeGroups(cgs);
        Test.stopTest();

        cgs = [SELECT Id, Name, Sirono_ID__c FROM Charge_Group__c];

        for (Charge_Group__c cg : cgs) {
            String newName = 'test_name_' + cg.Sirono_ID__c;
            System.assertEquals(cg.Name, newName, 'Chargegroup name expected: ' + newName + ' but is: ' + cg.Name);
        }
    }

    /**
     * This method tests the logic of getBilledCGCountByEncounterIds method positive.
     **/
    @isTest
    public static void getBilledCGCountPositiveTest() {

        Contact guarantorContact = [SELECT Id FROM Contact];

        Encounter__c encounter = TestUtility.generateEncounter(guarantorContact.Id, 500, System.today());
        INSERT encounter;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1214);
        chargeGroup.Encounter__c = encounter.Id;
        INSERT chargeGroup;

        Test.startTest();
        List<AggregateResult> results = ChargeGroupDao.getBilledCGCountByEncounterIds(new Set<Id> { encounter.Id });
        Test.stopTest();

        // Check system assert.
        System.assertEquals(1, results.size(), 'Expected AggregateResult size to be 1 but we got ' + results.size());
    }

    /**
     * This method tests the logic of getBilledCGCountByEncounterIds method negative.
     **/
    @isTest
    public static void getBilledCGCountNegativeTest() {

        Contact guarantorContact = [SELECT Id FROM Contact];

        Encounter__c encounter = TestUtility.generateEncounter(guarantorContact.Id, 500, System.today());
        INSERT encounter;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1214);
        INSERT chargeGroup;

        Test.startTest();
        List<AggregateResult> results = ChargeGroupDao.getBilledCGCountByEncounterIds(new Set<Id> { encounter.Id });
        Test.stopTest();

        // Check system assert.
        System.assertEquals(0, results.size(), 'AggregateResult size should have 0 but we got ' + results.size());
    }

    /**
     * This method tests the logic of getCGOrderByCreatedDate method.
     **/
    @isTest
    public static void getCGOrderByCreatedDateTest() {

        Contact guarantorContact = [SELECT Id FROM Contact];

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1244);
        INSERT chargeGroup;
        Test.setCreatedDate(chargeGroup.Id, System.now().addDays(-5));

        Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1234);
        INSERT chargeGroup1;
        Test.setCreatedDate(chargeGroup1.Id, System.now());

        Test.startTest();
        Charge_Group__c cg = ChargeGroupDao.getCGOrderByCreatedDate(new Set<Id> { chargeGroup.Id, chargeGroup1.Id });
        Test.stopTest();

        // Check system assert.
        System.assertEquals(cg.Id, chargeGroup1.Id, 'Expected newly created Charge Group but got different Charge Group.');
    }

    /**
     * This method tests the logic of getCGOrderByCreatedDate method.
     **/
    @isTest
    public static void getCGOrderByServiceDateTest() {

        Contact guarantorContact = [SELECT Id FROM Contact];

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1242);
        chargeGroup.Date_Of_Service_Start_Date__c = System.today().addDays(-5);
        INSERT chargeGroup;

        Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1241);
        chargeGroup1.Date_Of_Service_Start_Date__c = System.today();
        INSERT chargeGroup1;

        Test.startTest();
        List<Charge_Group__c> chargeGroups = ChargeGroupDao.getCGOrderByServiceDate(new Set<Id> { chargeGroup.Id, chargeGroup1.Id });
        Test.stopTest();

        // Check system assert.
        System.assertEquals(chargeGroups[0].Id, chargeGroup.Id, 'Expected oldest Date_Of_Service_Start_Date__c related Charge Group but got different Charge Group.');
    }

    /**
     * This method tests the logic of getCGIdsFromCaseCGJun method Positive.
     **/
    @isTest
    public static void getCGIdsFromCaseCGJunPositiveTest() {

        Contact guarantorContact = [SELECT Id FROM Contact];
        Decimal cgSironoId = 123456;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, cgSironoId);
        chargeGroup.Sirono_ID__c = cgSironoId;
        INSERT chargeGroup;

        Case objCase = TestUtility.generateCase(RecordTypeUtil.automatedCaseRt, Constants.CASE_TYPE_OVERDUE, guarantorContact.Id);
        INSERT objCase;

        Case_Charge_Group_Junction__c caseCGJun = new Case_Charge_Group_Junction__c(Case__c = objCase.Id, Charge_Group__c = chargeGroup.Id);
        INSERT caseCGJun;

        Test.startTest();
        List<String> chargeGroupIds = ChargeGroupDao.getCGIdsFromCaseCGJun(objCase.Id);
        Test.stopTest();

        // Check system assert.
        System.assertEquals(String.valueOf(cgSironoId), chargeGroupIds[0], 'Expected ' + cgSironoId + ' but we got ' + chargeGroupIds[0]);
        System.assertEquals(1, chargeGroupIds.size(), 'Expected chargeGroupIds size to be 1 but we got ' + chargeGroupIds.size());
    }

    /**
     * This method tests the logic of getCGIdsFromCaseCGJun method negative.
     **/
    @isTest
    public static void getCGIdsFromCaseCGJunNegativeTest() {

        Contact guarantorContact = [SELECT Id FROM Contact];
        Decimal cgSironoId = 123456;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, cgSironoId);
        chargeGroup.Sirono_ID__c = cgSironoId;
        INSERT chargeGroup;

        Case objCase = TestUtility.generateCase(RecordTypeUtil.automatedCaseRt, Constants.CASE_TYPE_OVERDUE, guarantorContact.Id);
        INSERT objCase;

        Test.startTest();
        List<String> chargeGroupIds = ChargeGroupDao.getCGIdsFromCaseCGJun(objCase.Id);
        Test.stopTest();

        // Check system assert.
        System.assertEquals(0, chargeGroupIds.size(), 'chargeGroupIds size should have 0 but we got ' + chargeGroupIds.size());
    }

    /**
     * This method tests the logic of getCGBasedOnGuarantor method Positive.
     **/
    @isTest
    public static void getCGBasedOnGuarantorPositiveTest() {

        Contact guarantorContact = [SELECT Id FROM Contact];

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1234);
        chargeGroup.Account_Status__c = Constants.ACCT_STATUS_BILLED;
        INSERT chargeGroup;

        Test.startTest();
        List<Charge_Group__c> chargeGroups = ChargeGroupDao.getCGBasedOnGuarantor(new Set<Id> { guarantorContact.Id });
        Test.stopTest();

        // Check system assert.
        System.assertEquals(guarantorContact.Id, chargeGroups[0].Guarantor__c, 'Expected CG Guarantor__c equals to ' + guarantorContact.Id + ' but we got ' + chargeGroups[0].Guarantor__c);
        System.assertEquals(1, chargeGroups.size(), 'Expected chargeGroups size to be 1 but we got ' + chargeGroups.size());
    }

    /**
     * This method tests the logic of getCGBasedOnGuarantor method negative.
     **/
    @isTest
    public static void getCGBasedOnGuarantorNegativeTest() {

        Contact guarantorContact = [SELECT Id FROM Contact];

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 12345);
        chargeGroup.Account_Status__c = Constants.ACCT_STATUS_PENDING;
        INSERT chargeGroup;

        Test.startTest();
        List<Charge_Group__c> chargeGroups = ChargeGroupDao.getCGBasedOnGuarantor(new Set<Id> { guarantorContact.Id });
        Test.stopTest();

        // Check system assert.
        System.assertEquals(0, chargeGroups.size(), 'chargeGroups size should have 0 but we got ' + chargeGroups.size());
    }

    /**
     * This method tests the logic of getCGBasedOnEncounter method positive.
     **/
    @isTest
    public static void getCGBasedOnEncounterPositiveTest() {

        Contact guarantorContact = [SELECT Id FROM Contact];

        Encounter__c encounter = TestUtility.generateEncounter(guarantorContact.Id, 500, System.today());
        INSERT encounter;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1222);
        chargeGroup.Encounter__c = encounter.Id;
        INSERT chargeGroup;

        Test.startTest();
        List<Charge_Group__c> chargeGroups = ChargeGroupDao.getCGBasedOnEncounter(new Set<Id> { encounter.Id });
        Test.stopTest();

        // Check system assert.
        System.assertEquals(encounter.Id, chargeGroups[0].Encounter__c, 'Expected CG Encounter__c equals to ' + encounter.Id + ' but we got ' + chargeGroups[0].Encounter__c);
        System.assertEquals(1, chargeGroups.size(), 'Expected chargeGroups size to be 1 but we got ' + chargeGroups.size());
    }

    /**
     * This method tests the logic of getCGBasedOnEncounter method negative.
     **/
    @isTest
    public static void getCGBasedOnEncounterNegativeTest() {

        Contact guarantorContact = [SELECT Id FROM Contact];

        Encounter__c encounter = TestUtility.generateEncounter(guarantorContact.Id, 500, System.today());
        INSERT encounter;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1214);
        INSERT chargeGroup;

        Test.startTest();
        List<Charge_Group__c> chargeGroups = ChargeGroupDao.getCGBasedOnEncounter(new Set<Id> { encounter.Id });
        Test.stopTest();

        // Check system assert.
        System.assertEquals(0, chargeGroups.size(), 'chargeGroups size should have 0 but we got ' + chargeGroups.size());
    }

    /**
     * This method tests the logic of getCGBasedOnGuarantorAndPreCollDate method.
     **/
    @isTest
    public static void getCGBasedOnGuarantorAndPreCollDateTest() {

        Contact guarantorContact = [SELECT Id FROM Contact];
        Date preCollDate = System.today().addDays(-5);

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1242);
        chargeGroup.Pre_Collection_Sent__c = preCollDate;
        INSERT chargeGroup;

        Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1241);
        chargeGroup1.Pre_Collection_Sent__c = System.today();
        INSERT chargeGroup1;

        Test.startTest();
        List<Charge_Group__c> chargeGroups = ChargeGroupDao.getCGBasedOnGuarantorAndPreCollDate(new List<Contact> { guarantorContact }, preCollDate);
        Test.stopTest();

        // Check system assert.
        System.assertEquals(preCollDate, chargeGroups[0].Pre_Collection_Sent__c, 'Expected Pre_Collection_Sent__c equals to ' + preCollDate + 'but got ' + chargeGroups[0].Pre_Collection_Sent__c);
        System.assertEquals(1, chargeGroups.size(), 'Expected chargeGroups size to be 1 but we got ' + chargeGroups.size());
    }

    /**
     * This method tests the logic of getCGForInvoiceController method with Order by.
     **/
    @isTest
    public static void getCGForInvoiceControllerWithOrderByTest() {

        Contact guarantorContact = [SELECT Id FROM Contact];

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1244);
        INSERT chargeGroup;
        Test.setCreatedDate(chargeGroup.Id, System.now());

        Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1234);
        INSERT chargeGroup1;
        Test.setCreatedDate(chargeGroup1.Id, System.now().addDays(-5));

        Test.startTest();
        List<Charge_Group__c> chargeGroups = ChargeGroupDao.getCGForInvoiceController(new Set<Id> { chargeGroup.Id, chargeGroup1.Id }, true);
        Test.stopTest();

        // Check system assert.
        System.assertEquals(chargeGroups[0].Id, chargeGroup1.Id, 'Expected Charge Group that order by created date but got different Charge Group.');
    }

    /**
     * This method tests the logic of getCGForInvoiceController method without Order by.
     **/
    @isTest
    public static void getCGForInvoiceControllerWithoutOrderByTest() {

        Contact guarantorContact = [SELECT Id FROM Contact];

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1244);
        INSERT chargeGroup;
        Test.setCreatedDate(chargeGroup.Id, System.now());

        Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1234);
        INSERT chargeGroup1;
        Test.setCreatedDate(chargeGroup1.Id, System.now().addDays(-5));

        Test.startTest();
        List<Charge_Group__c> chargeGroups = ChargeGroupDao.getCGForInvoiceController(new Set<Id> { chargeGroup.Id, chargeGroup1.Id }, false);
        Test.stopTest();

        // Check system assert.
        System.assertEquals(chargeGroups[0].Id, chargeGroup.Id, 'Expected newly created Charge Group but got different Charge Group.');
    }

    /**
     * This method tests the logic of getCGBasedOnGuarantorFilterByStatus method Positive.
     **/
    @isTest
    public static void testGetByGuarantorAndSubStatus() {

        Contact guarantorContact = [SELECT Id FROM Contact];

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1234);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        INSERT chargeGroup;

        Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(guarantorContact.Id, null, 12345);
        chargeGroup1.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_BAD_DEBT;
        INSERT chargeGroup1;

        Test.startTest();
        List<Charge_Group__c> chargeGroups = ChargeGroupDao.getByGuarantorAndSubStatus(new Set<Id> { guarantorContact.Id }, new Set<String> { Constants.ACCT_SUBSTATUS_OVERDUE });
        Test.stopTest();

        // Check system assert.
        System.assertEquals(guarantorContact.Id, chargeGroups[0].Guarantor__c, 'Expected CG Guarantor__c equals to ' + guarantorContact.Id + ' but we got ' + chargeGroups[0].Guarantor__c);
        System.assertEquals(1, chargeGroups.size(), 'Expected chargeGroups size to be 1 but we got ' + chargeGroups.size());
    }

    /**
     * This method tests the logic of getCGBasedOnGuarantorFilterByStatus method negative.
     **/
    @isTest
    public static void testGetByGuarantorAndSubStatusNegative() {

        Contact guarantorContact = [SELECT Id FROM Contact];

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 12345);
        chargeGroup.Account_Status__c = Constants.ACCT_STATUS_PENDING;
        INSERT chargeGroup;

        Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1234);
        chargeGroup1.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_BAD_DEBT;
        INSERT chargeGroup1;

        Test.startTest();
        List<Charge_Group__c> chargeGroups = ChargeGroupDao.getByGuarantorAndSubStatus(new Set<Id> { guarantorContact.Id }, new Set<String> { Constants.ACCT_SUBSTATUS_OVERDUE });
        Test.stopTest();

        // Check system assert.
        System.assertEquals(0, chargeGroups.size(), 'chargeGroups size should have 0 but we got ' + chargeGroups.size());
    }

    /**
     * Check all Read rights for a Chatter User using runAs.
     **/
    @isTest
    static void checkAccessRightsForRead() {
        List<ChargeGroupSecurityContext> allContexts = new List<ChargeGroupSecurityContext> {
            ChargeGroupSecurityContext.SELECT_CONTEXT,
            ChargeGroupSecurityContext.GD_SELECT_CONTEXT,
            ChargeGroupSecurityContext.IU_SELECT_CONTEXT
        };

        System.runAs(TestUtility.generateChatterOnlyUser()) {
            for (ChargeGroupSecurityContext context: allContexts) {
                try {
                    context.actionAllowed();
                    System.assert(false, 'Expected permission to be denied for ' + context);
                } catch (SecurityUtils.SecurityException ex) {
                    System.debug('SecurityException : ' + ex);
                } catch (Exception e) {
                    System.assert(false, 'Expected SecurityUtils.SecurityException to be thrown, but got ' + e);
                }
            }
        }
    }
}