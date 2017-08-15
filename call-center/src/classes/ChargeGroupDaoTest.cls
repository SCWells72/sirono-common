/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Test the ChargeGroupDao methods
 */
@IsTest
public with sharing class ChargeGroupDaoTest {

    @TestSetup
    public static void setup() {
        Contact gt = TestUtility.generateGuarantorContact();
        insert gt;
        System.debug('gt.Id: ' + gt.Id);

        Contact exgt = TestUtility.generateExternalGuarantor();
        insert exgt;
        System.debug('exgt.Id: ' + exgt.Id);

        Contact pt = TestUtility.generatePatientContact();
        insert pt;
        System.debug('pt.Id: ' + pt.Id);

        List<Charge_Group__c> cgToAddList = TestUtility.generateChargeGroupList(gt.Id);
        Decimal i = 1;
        for (Charge_Group__c cg : cgToAddList) {
            cg.Sirono_Id__c = i++;
            cg.External_Guarantor_Id__c = exgt.Id;
            cg.Patient__c = pt.Id;
        }

        insert cgToAddList;



        // Check system assert.
        System.assertEquals(1, cgToAddList[0].Sirono_Id__c, 'Expected Chargegroup Sirono_Id__c equals to 1 but we got ' + cgToAddList[0].Sirono_Id__c);
    }

    @IsTest
    public static void getBySironoIdsAllFoundTest() {

        List<Decimal> cgSironoIds = new Decimal[] { 1, 3, 5, 10 };

        Test.startTest();
        Charge_Group__c[] cgs = ChargeGroupDao.getBySironoIds(cgSironoIds);
        Test.stopTest();

        Map<Decimal, Charge_Group__c> cgMap = new Map<Decimal, Charge_Group__c>();
        for (Charge_Group__c cg : cgs) {
            cgMap.put(cg.Sirono_Id__c, cg);
        }

        for (Decimal sironoId : cgSironoIds) {
            System.assert(cgMap.containsKey(sironoId), 'ChargeGroup with sironoId: ' + sironoId + ' not in result set');
        }
    }


    @IsTest
    public static void getBySironoIdsNotAllFoundTest() {

        List<Decimal> cgSironoIds = new Decimal[] { 1, 3, 5, 10, 99 };

        Test.startTest();
        Charge_Group__c[] cgs = ChargeGroupDao.getBySironoIds(cgSironoIds);
        Test.stopTest();

        Map<Decimal, Charge_Group__c> cgMap = new Map<Decimal, Charge_Group__c>();
        for (Charge_Group__c cg : cgs) {
            cgMap.put(cg.Sirono_Id__c, cg);
        }

        for (Decimal sironoId : cgSironoIds) {
            if (sironoId != 99) {
                System.assert(cgMap.containsKey(sironoId), 'ChargeGroup with sironoId: ' + sironoId + ' not in result set');
            } else {
                System.assert(!cgMap.containsKey(sironoId), 'ChargeGroup with sironoId: ' + sironoId + ' was in result set');
            }
        }
    }

    @IsTest
    public static void updateChargeGroupsTest() {

        Charge_Group__c[] cgs = [SELECT Id, Name, Sirono_Id__c FROM Charge_Group__c];

        for (Charge_Group__c cg : cgs) {
            cg.Name = 'test_name_' + cg.Sirono_Id__c;
        }

        Test.startTest();
        ChargeGroupDao.updateChargeGroups(cgs);
        Test.stopTest();

        cgs = [SELECT Id, Name, Sirono_Id__c FROM Charge_Group__c];

        for (Charge_Group__c cg : cgs) {
            String newName = 'test_name_' + cg.Sirono_Id__c;
            System.assertEquals(cg.Name, newName, 'Chargegroup name expected: ' + newName + ' but is: ' + cg.Name);
        }
    }

    /**
     * This method tests the logic of getBilledCGCountByEncounterIds method positive.
     **/
    @IsTest
    public static void getBilledCGCountPositiveTest() {

        Contact guarantorContact = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];

        Encounter__c encounter = TestUtility.generateEncounter(guarantorContact.Id, 500, System.today());
        insert encounter;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1214);
        chargeGroup.Encounter__c = encounter.Id;
        insert chargeGroup;

        Test.startTest();
        List<AggregateResult> results = ChargeGroupDao.getBilledCGCountByEncounterIds(new Set<Id> { encounter.Id });
        Test.stopTest();

        // Check system assert.
        System.assertEquals(1, results.size(), 'Expected AggregateResult size to be 1 but we got ' + results.size());
    }

    /**
     * This method tests the logic of getBilledCGCountByEncounterIds method negative.
     **/
    @IsTest
    public static void getBilledCGCountNegativeTest() {

        Contact guarantorContact = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];

        Encounter__c encounter = TestUtility.generateEncounter(guarantorContact.Id, 500, System.today());
        insert encounter;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1214);
        insert chargeGroup;

        Test.startTest();
        List<AggregateResult> results = ChargeGroupDao.getBilledCGCountByEncounterIds(new Set<Id> { encounter.Id });
        Test.stopTest();

        // Check system assert.
        System.assertEquals(0, results.size(), 'AggregateResult size should have 0 but we got ' + results.size());
    }

    /**
     * This method tests the logic of getCGOrderByCreatedDate method.
     **/
    @IsTest
    public static void getCGOrderByCreatedDateTest() {

        Contact guarantorContact = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1244);
        insert chargeGroup;
        Test.setCreatedDate(chargeGroup.Id, System.now().addDays(-5));

        Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1234);
        insert chargeGroup1;
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
    @IsTest
    public static void getCGOrderByServiceDateTest() {

        Contact guarantorContact = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1242);
        chargeGroup.Date_Of_Service_Start_Date__c = System.today().addDays(-5);
        insert chargeGroup;

        Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1241);
        chargeGroup1.Date_Of_Service_Start_Date__c = System.today();
        insert chargeGroup1;

        Test.startTest();
        List<Charge_Group__c> chargeGroups = ChargeGroupDao.getCGOrderByServiceDate(new Set<Id> { chargeGroup.Id, chargeGroup1.Id });
        Test.stopTest();

        // Check system assert.
        System.assertEquals(chargeGroups[0].Id, chargeGroup.Id, 'Expected oldest Date_Of_Service_Start_Date__c related Charge Group but got different Charge Group.');
    }

    /**
     * This method tests the logic of getCGIdsFromCaseCGJun method Positive.
     **/
    @IsTest
    public static void getCGIdsFromCaseCGJunPositiveTest() {

        Contact guarantorContact = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];
        Decimal cgSironoId = 123456;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, cgSironoId);
        chargeGroup.Sirono_Id__c = cgSironoId;
        insert chargeGroup;

        Case objCase = TestUtility.generateCase(RecordTypeUtil.automatedCaseRt, Constants.CASE_TYPE_OVERDUE, guarantorContact.Id);
        insert objCase;

        Case_Charge_Group_Junction__c caseCGJun = new Case_Charge_Group_Junction__c(Case__c = objCase.Id, Charge_Group__c = chargeGroup.Id);
        insert caseCGJun;

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
    @IsTest
    public static void getCGIdsFromCaseCGJunNegativeTest() {

        Contact guarantorContact = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];
        Decimal cgSironoId = 123456;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, cgSironoId);
        chargeGroup.Sirono_Id__c = cgSironoId;
        insert chargeGroup;

        Case objCase = TestUtility.generateCase(RecordTypeUtil.automatedCaseRt, Constants.CASE_TYPE_OVERDUE, guarantorContact.Id);
        insert objCase;

        Test.startTest();
        List<String> chargeGroupIds = ChargeGroupDao.getCGIdsFromCaseCGJun(objCase.Id);
        Test.stopTest();

        // Check system assert.
        System.assertEquals(0, chargeGroupIds.size(), 'chargeGroupIds size should have 0 but we got ' + chargeGroupIds.size());
    }

    /**
     * This method tests the logic of getCGBasedOnGuarantorAndPreCollDate method.
     **/
    @IsTest
    public static void getCGBasedOnGuarantorAndPreCollDateTest() {

        Contact guarantorContact = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];
        Date preCollDate = System.today().addDays(-5);

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1242);
        chargeGroup.Pre_Collection_Sent__c = preCollDate;
        insert chargeGroup;

        Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1241);
        chargeGroup1.Pre_Collection_Sent__c = System.today();
        insert chargeGroup1;

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
    @IsTest
    public static void getCGForInvoiceControllerWithOrderByTest() {

        Contact guarantorContact = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1244);
        insert chargeGroup;
        Test.setCreatedDate(chargeGroup.Id, System.now());

        Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1234);
        insert chargeGroup1;
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
    @IsTest
    public static void getCGForInvoiceControllerWithoutOrderByTest() {

        Contact guarantorContact = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1244);
        insert chargeGroup;
        Test.setCreatedDate(chargeGroup.Id, System.now());

        Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1234);
        insert chargeGroup1;
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
    @IsTest
    public static void testGetByGuarantorAndSubStatus() {

        Contact guarantorContact = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1234);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        insert chargeGroup;

        Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(guarantorContact.Id, null, 12345);
        chargeGroup1.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_BAD_DEBT;
        insert chargeGroup1;

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
    @IsTest
    public static void testGetByGuarantorAndSubStatusNegative() {

        Contact guarantorContact = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 12345);
        chargeGroup.Account_Status__c = Constants.ACCT_STATUS_PENDING;
        insert chargeGroup;

        Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1234);
        chargeGroup1.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_BAD_DEBT;
        insert chargeGroup1;

        Test.startTest();
        List<Charge_Group__c> chargeGroups = ChargeGroupDao.getByGuarantorAndSubStatus(new Set<Id> { guarantorContact.Id }, new Set<String> { Constants.ACCT_SUBSTATUS_OVERDUE });
        Test.stopTest();

        // Check system assert.
        System.assertEquals(0, chargeGroups.size(), 'chargeGroups size should have 0 but we got ' + chargeGroups.size());
    }

    /**
     * Check all Read rights for a Chatter User using runAs.
     **/
    @IsTest
    static void checkAccessRightsForRead() {
        List<ChargeGroupSecurityContext> allContexts = new List<ChargeGroupSecurityContext> {
            ChargeGroupSecurityContext.SELECT_CONTEXT,
            ChargeGroupSecurityContext.GD_SELECT_CONTEXT,
            ChargeGroupSecurityContext.IU_SELECT_CONTEXT
        };

        System.runAs(TestUtility.generateChatterOnlyUser()) {
            for (ChargeGroupSecurityContext context : allContexts) {
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

    @IsTest
    public static void testGetCGForPaymentPlan() {

        Contact guarantorContact = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];

        Payment_Plan__c payPlan = TestUtility.generatePaymentPlan(guarantorContact);
        insert payPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1234);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        chargeGroup.Payment_Plan__c = payPlan.Id;
        insert chargeGroup;

        Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(guarantorContact.Id, null, 12345);
        chargeGroup1.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_BAD_DEBT;
        chargeGroup1.Payment_Plan__c = payPlan.Id;
        insert chargeGroup1;

        Test.startTest();
        List<Charge_Group__c> cgs = ChargeGroupDao.getCGForPaymentPlan(payPlan.Id);
        Test.stopTest();

        System.assertEquals(2, cgs.size());
    }

    @IsTest
    public static void testGetPayableByInvoiceId() {
        Contact gt = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];
        Contact pt = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.patientRt];

        Invoice__c invoice = TestUtility.generateInvoice(gt.Id, pt.Id);
        insert invoice;

        Charge_Group__c[] cgs = [SELECT Id FROM Charge_Group__c];
        Service2__c[] svcs = new List<Service2__c>();
        for (Integer i = 0; i < cgs.size(); i++) {
            Charge_Group__c cg = cgs[i];
            cg.Invoice__c = invoice.Id;
            if (i == cgs.size()-1) {
                cg.Active__c = false;
            } else {
                cg.Active__c = true;
            }
            cg.Account_Status__c = Constants.ACCT_STATUS_BILLED;
            cg.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DUE_BY;
            Service2__c svc = TestUtility.generateService(gt, 200.00);
            svcs.add(svc);
        }
        insert svcs;
        update cgs;

        Transaction__c[] txns = new List<Transaction__c>();
        for (Integer i = 0; i<svcs.size(); i++) {
            Transaction__c txn = TestUtility.generateServiceTxn(cgs[i], 200.00, svcs[i]);
            txns.add(txn);
        }
        insert txns;

        Test.startTest();
        Charge_Group__c[] byInvoice = ChargeGroupDao.getPayableByInvoiceId(new Set<String>(new List<String>{invoice.Id}));
        Test.stopTest();

        System.assertEquals(cgs.size()-1, byInvoice.size(), 'Expected a difference of 1 cg');
    }
}