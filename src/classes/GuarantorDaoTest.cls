/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
public with sharing class GuarantorDaoTest {

    private static String GT_SIRONO_ID = '12345';


    @TestSetup
    public static void setup() {
        Contact gt = TestUtility.generateGuarantorContact();
        gt.Profile_Pointer_ID__c = Decimal.valueOf(GT_SIRONO_ID);
        insert gt;

        Contact pt = TestUtility.generatePatientContact();
        pt.Patient_Id__c = Decimal.valueOf(GT_SIRONO_ID);
        insert pt;

        // Create Charge Group Record.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(gt.Id, pt.Id, 12345);
        insert chargeGroup;

        Transaction__c transactionObj = TestUtility.generateTransaction(chargeGroup, 100, Constants.AUTOMATIC);
        insert transactionObj;

        // Check system asserts.
        System.assertEquals(Decimal.valueOf(GT_SIRONO_ID), gt.Profile_Pointer_ID__c, 'Expected ' + GT_SIRONO_ID + ' but we got ' + gt.Profile_Pointer_ID__c);
    }

    @IsTest
    public static void getGTBySironoIdTest() {
        Contact gt = GuarantorDao.getGuarantorBySironoId(GT_SIRONO_ID);
        System.assertNotEquals(gt, null, 'Expected guarantor but got null');
        System.assertEquals(GT_SIRONO_ID, String.valueOf(gt.Profile_Pointer_ID__c),
            'Expected Sirono_ID__c of ' + GT_SIRONO_ID + ' but got: ' + gt.Profile_Pointer_ID__c);
        System.assertEquals(RecordTypeUtil.guarantorRt, gt.RecordTypeId,
            'Expected RecordTypeId of ' + RecordTypeUtil.guarantorRt + ' but got: ' + gt.RecordTypeId);
    }


    /**
     * Test the logic of getGuarantorFilterCGByAcctSubStatus
     * CG account substatus is "Preinvoiced" so we get contact with 1 CG.
     **/
    @IsTest
    public static void getGuarantorFilterCGByAcctSubStatusTest() {
        Contact gt = [
            SELECT Id
            FROM Contact
            WHERE RecordTypeId = :RecordTypeUtil.guarantorRt
            LIMIT 1
        ];

        // Call getGuarantorFilterCGByAcctSubStatus method.
        Test.startTest();
        Contact contact = GuarantorDao.getGuarantorFilterCGByAcctSubStatus(gt.Id, Constants.CGConstraintsForDiscount);
        Test.stopTest();

        // Check system assert, Charge Group size of Contact.
        System.assertEquals(contact.Charge_Groups__r.size(), 1);
        System.assertEquals(gt.Id, contact.Id);
        System.assertEquals(contact.Charge_Groups__r.get(0).Account_Sub_Status__c, Constants.ACCT_SUBSTATUS_PREINVOICED);
    }

    /**
     * Test getGuarantorFilterCGByAcctSubStatus. Guarantor has 2 chargegroups, one with BadDebt and 1 PreInvoiced;
     * just the PreInvoiced should be returned
     **/
    @IsTest
    public static void getGuarantorFilterCGByAcctSubStatusBDChargegroupsTest() {
        Contact gt = [
            SELECT Id
            FROM Contact
            WHERE RecordTypeId = :RecordTypeUtil.guarantorRt
            LIMIT 1
        ];

        Contact pt = [
            SELECT Id
            FROM Contact
            WHERE RecordTypeId = :RecordTypeUtil.patientRt
            LIMIT 1
        ];

        // Create BD Charge Group Record.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(gt.Id, pt.Id, 123456);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_BAD_DEBT;
        insert chargeGroup;

        Test.startTest();
        Contact contact = GuarantorDao.getGuarantorFilterCGByAcctSubStatus(gt.Id, Constants.CGConstraintsForDiscount);
        Test.stopTest();

        // Check system assert, Charge Group size of Contact.
        System.assertEquals(contact.Charge_Groups__r.size(), 1);
        System.assertEquals(gt.Id, contact.Id);
        System.assertEquals(contact.Charge_Groups__r.get(0).Account_Sub_Status__c, Constants.ACCT_SUBSTATUS_PREINVOICED);
    }

    /**
     * Test getGuarantorAllActiveCG. Guarantor has 2 chargegroups, one Active and 1 not;
     * just the Active, PreInvoiced should be returned
     **/
    @IsTest
    public static void getGuarantorAllActiveCGTest() {
        Contact gt = [
            SELECT Id
            FROM Contact
            WHERE RecordTypeId = :RecordTypeUtil.guarantorRt
            LIMIT 1
        ];

        Contact pt = [
            SELECT Id
            FROM Contact
            WHERE RecordTypeId = :RecordTypeUtil.patientRt
            LIMIT 1
        ];

        // Create BD Charge Group Record.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(gt.Id, pt.Id, 123456);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DUE_BY;
        chargeGroup.Active__c = false;
        insert chargeGroup;

        Test.startTest();
        Contact contact = GuarantorDao.getGuarantorWithActiveCG(gt.Id);
        Test.stopTest();

        // Check system assert, Charge Group size of Contact.
        System.assertEquals(contact.Charge_Groups__r.size(), 1);
        System.assertEquals(gt.Id, contact.Id);
        System.assertEquals(contact.Charge_Groups__r.get(0).Account_Sub_Status__c, Constants.ACCT_SUBSTATUS_PREINVOICED);
    }

    @IsTest
    public static void getGuarantorTest() {
        Contact gt1 = GuarantorDao.getGuarantorBySironoId(GT_SIRONO_ID);
        Contact gt2 = GuarantorDao.getGuarantor(gt1.Id);
        System.assertEquals(gt1.Id, gt2.Id, 'Guarantor Ids should be the same');
        System.assertEquals(GT_SIRONO_ID, gt2.Profile_Pointer_ID__c.toPlainString(),
            'Expected Sirono_ID__c of ' + GT_SIRONO_ID + ' but got: ' + gt2.Profile_Pointer_ID__c.toPlainString());
        System.assertEquals(RecordTypeUtil.guarantorRt, gt2.RecordTypeId,
            'Expected RecordTypeId of ' + RecordTypeUtil.guarantorRt + ' but got: ' + gt2.RecordTypeId);
    }

    /**
     * This method tests the logic of getGuarantorsWithCG method.
     **/
    @IsTest
    public static void getGuarantorsWithCGTest() {
        Contact gt = GuarantorDao.getGuarantorBySironoId(GT_SIRONO_ID);

        // Check system assert.
        System.assertEquals(0, gt.Charge_Groups__r.size(), 'Should be defualt charge group size is 0 but we got ' + gt.Charge_Groups__r.size());

        Charge_Group__c cg = [SELECT Id, Pre_Collection_Sent__c FROM Charge_Group__c];
        cg.Pre_Collection_Sent__c = System.today();
        update cg;

        Test.startTest();
        List<Contact> contacts = GuarantorDao.getGuarantorsWithCG(new Set<Id> { gt.Id });
        Test.stopTest();

        // Check system assert.
        System.assertEquals(1, contacts[0].Charge_Groups__r.size(), 'Expected contact\'s charge groups size equals to 1 but we got ' + contacts[0].Charge_Groups__r.size());
    }

    /**
     * This method tests the logic of getGuarantorsWithPmtPlan method.
     **/
    @IsTest
    public static void getGuarantorsWithPmtPlanTest() {
        Contact gt = GuarantorDao.getGuarantorBySironoId(GT_SIRONO_ID);

        // Check system assert.
        System.assertEquals(0, gt.Payment_Plans__r.size(), 'Should be defualt Payment Plan size is 0 but we got ' + gt.Payment_Plans__r.size());

        Payment_Plan__c pp = TestUtility.generatePaymentPlan(gt.Id);
        pp.Active__c = true;
        pp.Plan_Type__c = Constants.AUTOMATIC;
        pp.Delinquent_Date__c = System.today();
        insert pp;

        Test.startTest();
        List<Contact> contacts = GuarantorDao.getGuarantorsWithPmtPlan(new Set<Id> { gt.Id });
        Test.stopTest();

        // Check system assert.
        System.assertEquals(1, contacts[0].Payment_Plans__r.size(), 'Expected contact\'s Payment Plan size equals to 1 but we got ' + contacts[0].Payment_Plans__r.size());
    }

    /**
     * This method tests the logic of getGuarantorsWithEncounterTest method.
     **/
    @IsTest
    public static void getGuarantorsWithEncounterTest() {
        Contact gt = GuarantorDao.getGuarantorBySironoId(GT_SIRONO_ID);

        // Check system assert.
        System.assertEquals(0, gt.Encounters__r.size(), 'Should be defualt Encounter size is 0 but we got ' + gt.Encounters__r.size());

        Encounter__c encounter = TestUtility.generateEncounter(gt.Id, 500, System.today());
        encounter.Liability__c = 50;
        insert encounter;

        Test.startTest();
        List<Contact> contacts = GuarantorDao.getGuarantorsWithEncounters(new Set<Id> { gt.Id });
        Test.stopTest();

        // Check system assert.
        System.assertEquals(contacts[0].Id, gt.Id, 'Expected contact Id same as gt Id but we got ' + contacts[0].Id);
    }

    /**
     * This method tests the logic of getGuarantorsByFilter method with Overdue Filter.
     **/
    @IsTest
    public static void getGuarantorsByOverdueFilterTest() {
        Contact gt = GuarantorDao.getGuarantorBySironoId(GT_SIRONO_ID);

        List<Contact> contacts = GuarantorDao.getGuarantorsByFilter(new Set<String> { gt.Id }, CaseUtil.Overdue_Bal_GT);
        // Check system assert.
        System.assertEquals(0, contacts.size(), 'Should be defualt Contact size is 0 but we got ' + contacts.size());

        Test.startTest();
        Charge_Group__c cg = [SELECT Id, Account_Sub_Status__c FROM Charge_Group__c];
        cg.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        update cg;

        contacts = GuarantorDao.getGuarantorsByFilter(new Set<String> { gt.Id }, CaseUtil.Overdue_Bal_GT);
        Test.stopTest();

        // Check system assert.
        System.assertEquals(1, contacts.size(), 'Expected contact size equals to 1 but we got ' + contacts.size());
    }

    /**
     * This method tests the logic of getGuarantorsByFilter method with Delinquent Filter.
     **/
    @IsTest
    public static void getGuarantorsByDelinquentFilterTest() {
        Contact gt = GuarantorDao.getGuarantorBySironoId(GT_SIRONO_ID);

        List<Contact> contacts = GuarantorDao.getGuarantorsByFilter(new Set<String> { gt.Id }, CaseUtil.Delinquent_Bal_GT);
        // Check system assert.
        System.assertEquals(0, contacts.size(), 'Should be defualt Contact size is 0 but we got ' + contacts.size());

        Test.startTest();
        Charge_Group__c cg = [SELECT Id, Account_Sub_Status__c FROM Charge_Group__c];
        cg.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        update cg;

        contacts = GuarantorDao.getGuarantorsByFilter(new Set<String> { gt.Id }, CaseUtil.Delinquent_Bal_GT);
        Test.stopTest();

        // Check system assert.
        System.assertEquals(1, contacts.size(), 'Expected contact size equals to 1 but we got ' + contacts.size());
    }

    /**
     * This method tests the logic of getGuarantorsWithNumbers method.
     **/
    @IsTest
    public static void getGuarantorsWithNumbersTest() {
        Contact gt = GuarantorDao.getGuarantorBySironoId(GT_SIRONO_ID);

        Test.startTest();
        gt.HomePhone = '6157187745';
        update gt;

        List<Contact> contacts = GuarantorDao.getGuarantorsWithNumbers(new Set<Id> { gt.Id });
        Test.stopTest();

        // Check system assert.
        System.assertEquals(1, contacts.size(), 'Expected contact size equals to 1 but we got ' + contacts.size());
        System.assert(contacts[0].Home_Phone_Type__c != null, 'Expected Home_Phone_Type__c not equals to null but we got null.');
    }

    /**
     * This method tests the logic of getGuarantorsWithStatement method.
     **/
    @IsTest
    public static void getGuarantorsWithStatementTest() {
        Contact gt = GuarantorDao.getGuarantorBySironoId(GT_SIRONO_ID);

        // Check system assert.
        System.assertEquals(0, gt.Statements__r.size(), 'Should be defualt Statement size is 0 but we got ' + gt.Statements__r.size());

        Statement__c smt = TestUtility.generateStatement(gt.Id);
        insert smt;

        Test.startTest();
        List<Contact> contacts = GuarantorDao.getGuarantorsWithStatement(new List<Contact> { gt });
        Test.stopTest();

        // Check system assert.
        System.assertEquals(1, contacts[0].Statements__r.size(), 'Expected contact\'s Statement size equals to 1 but we got ' + contacts[0].Statements__r.size());
    }

    /**
     * This method tests the logic of getGuarantorsWithTask method.
     **/
    @IsTest
    public static void getGuarantorsWithTaskTest() {
        Contact gt = GuarantorDao.getGuarantorBySironoId(GT_SIRONO_ID);

        // Check system assert.
        System.assertEquals(0, gt.Tasks.size(), 'Should be defualt Task size is 0 but we got ' + gt.Tasks.size());

        Task task = TestUtility.generateTask(gt.Id);
        insert task;

        Test.startTest();
        List<Contact> contacts = GuarantorDao.getGuarantorsWithTask(new Set<Id> { gt.Id }, null, new Set<String> { 'Pre-collection' }, new Set<String> { 'Final' });
        Test.stopTest();

        // Check system assert.
        System.assertEquals(1, contacts[0].Tasks.size(), 'Expected contact\'s Task size equals to 1 but we got ' + contacts[0].Tasks.size());
    }

    /**
     * Check all Read rights for a Chatter User using runAs.
     **/
    @IsTest
    static void checkAccessRightsForRead() {
        List<ContactSecurityContext> allContexts = new List<ContactSecurityContext> {
            ContactSecurityContext.SELECT_CONTEXT,
            ContactSecurityContext.CTH_SELECT_CONTEXT,
            ContactSecurityContext.SB_SELECT_CONTEXT,
            ContactSecurityContext.PPTH_SELECT_CONTEXT,
            ContactSecurityContext.CU_SELECT_CONTEXT
        };

        System.runAs(TestUtility.generateChatterOnlyUser()) {
            for (ContactSecurityContext context : allContexts) {
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

    /**
     * Verify the getContactsNoResults query returns zero results.
     */
    @IsTest
    static void verifyNoContacts() {

        Test.startTest();
        String noConactsQuery = GuarantorDao.getNoContactsQuery();
        Test.stopTest();

        System.assert(noConactsQuery != null, 'Should have a query string.');

        List<Contact> contacts = Database.query(noConactsQuery);
        System.assertEquals(0, contacts.size(), 'Should have zero results.');
    }

    /**
     * Test to verify the query string provided by the getContactsByRecordType method is valid.
     */
    @IsTest
    static void getContactsByRecordTypeTest() {

        Test.startTest();
        String getContactQueryString = GuarantorDao.getBatchContactsQuery();
        Test.stopTest();

        System.assert(getContactQueryString != null, 'Query string should not be null.');
        System.assert(getContactQueryString.length() != 0, 'Query string should not be zero length.');

        // A variable with this name is required as a bind parameter for the query string
        //noinspection ApexUnusedDeclaration
        List<Id> existingMembers = new List<Id> {};

        List<Contact> contacts = Database.query(getContactQueryString);
        System.assert(contacts != null, 'Should be a query to get contacts.');
    }
}