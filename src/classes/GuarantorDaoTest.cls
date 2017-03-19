/**
 * Created by mmartin on 3/14/17.
 */
@IsTest
public with sharing class GuarantorDaoTest {

    private static String GT_SIRONO_ID = '12345';


    @TestSetup
    public static void setup() {
        Contact gt = TestUtility.generateGuarantorContact();
        gt.Profile_Pointer_ID__c = Decimal.valueOf(GT_SIRONO_ID);
        INSERT gt;

        Contact pt = TestUtility.generatePatientContact();
        pt.Patient_Id__c = Decimal.valueOf(GT_SIRONO_ID);
        INSERT pt;

        // Create Charge Group Record.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(gt.Id, pt.Id, 12345);
        INSERT chargeGroup;

    }

    @isTest
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
    @isTest
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
    @isTest
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
        INSERT chargeGroup;

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
    @isTest
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
        INSERT chargeGroup;

        Test.startTest();
        Contact contact = GuarantorDao.getGuarantorAllActiveCG(gt.Id);
        Test.stopTest();

        // Check system assert, Charge Group size of Contact.
        System.assertEquals(contact.Charge_Groups__r.size(), 1);
        System.assertEquals(gt.Id, contact.Id);
        System.assertEquals(contact.Charge_Groups__r.get(0).Account_Sub_Status__c, Constants.ACCT_SUBSTATUS_PREINVOICED);
    }
}