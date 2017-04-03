/**
 * Test the functionality of GuarantorService
 */
@isTest
public with sharing class GuarantorServiceTest {

    private static String SIRONO_ID = '99887766';
    private static String FIRST = 'TestFirstName';
    private static String MIDDLE = 'TestMiddleName';
    private static String LAST = 'TestLastName';
    private static String SUFFIX = 'Jr.';
    private static Date BIRTHDATE = Date.today().addYears(-20);
    private static String MRN = 'TEST_MRN_12345';

    @TestSetup
    public static void setup() {
        Contact gt = TestUtility.generateGuarantorContact();
        gt.FirstName = FIRST;
        gt.MiddleName = MIDDLE;
        gt.LastName = LAST;
        gt.Suffix = SUFFIX;
        gt.Birthdate = BIRTHDATE;
        gt.Medical_Record_Number__c = MRN;

        gt.Profile_Pointer_ID__c = Decimal.valueOf(SIRONO_ID);
        INSERT gt;

        Contact pt = TestUtility.generatePatientContact();
        pt.Patient_Id__c = Decimal.valueOf(SIRONO_ID);
        INSERT pt;

        // Create Charge Group Record.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(gt.Id, pt.Id, 12345);
        chargeGroup.Active__c = true;
        INSERT chargeGroup;

        // Create Charge Group Record.
        chargeGroup = TestUtility.generateChargeGroup(gt.Id, pt.Id, 67890);
        chargeGroup.Active__c = false;
        INSERT chargeGroup;
    }

    /*
        Test building full detail string
     */
    @isTest
    public static void buildGuarantorDetailStringTest() {
        Contact gt = GuarantorDao.getGuarantorBySironoId(SIRONO_ID);
        String expected = FIRST + ' ' + MIDDLE+' ' + LAST+' '+SUFFIX+' (DOB: '+BIRTHDATE.format()+', MRN: '+MRN+')';
        String built = GuarantorService.buildGuarantorDetailString(gt);
        System.assertEquals(expected, built, 'Expected details: '+expected+' but got: '+built);
    }

    @isTest
    public static void getSironoIdTest() {
        Contact gt = GuarantorDao.getGuarantorBySironoId(SIRONO_ID);
        String foundId = GuarantorService.getGuarantorSironoId(gt);
        System.assertEquals(SIRONO_ID, foundId, 'Expected sironoId: '+SIRONO_ID+' but got: '+foundId);
    }

    @isTest
    public static void getSironoIdFromDBTest() {
        Contact gt = GuarantorDao.getGuarantorBySironoId(SIRONO_ID);
        Contact newContact = new Contact();
        newContact.Id = gt.Id;
        String foundId = GuarantorService.getGuarantorSironoId(newContact);
        System.assertEquals(SIRONO_ID, foundId, 'Expected sironoId: '+SIRONO_ID+' but got: '+foundId);
    }

    @isTest
    public static void getSironoIdExceptionTest() {
        try {
            String foundId = GuarantorService.getGuarantorSironoId(null);
            System.assert(false, 'Expected SironoServiceException to be thrown');
        } catch (SironoServiceException ex) {
            System.assertEquals(ex.getMessage(), 'Invalid request - Contact required to retrieve SironoId');
        }
    }

    @isTest
    public static void getGTBySironoIdTest() {
        Contact gt = GuarantorService.getGuarantorBySironoId(SIRONO_ID);
        System.assertNotEquals(gt, null, 'Expected guarantor but got null');
        System.assertEquals(SIRONO_ID, String.valueOf(gt.Profile_Pointer_ID__c),
                'Expected Sirono_ID__c of ' + SIRONO_ID + ' but got: ' + gt.Profile_Pointer_ID__c);
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
        Contact contact = GuarantorService.getGuarantorFilterCGByAcctSubStatus(gt.Id, Constants.CGConstraintsForDiscount);
        Test.stopTest();

        // Check system assert, Charge Group size of Contact.
        System.assertEquals(contact.Charge_Groups__r.size(), 1);
        System.assertEquals(gt.Id, contact.Id);
        System.assertEquals(contact.Charge_Groups__r.get(0).Account_Sub_Status__c, Constants.ACCT_SUBSTATUS_PREINVOICED);
    }

    /**
     * Test the logic of getGuarantorWithActiveCG
     * Only one CG is active, so should return 1 CG
     **/
    @isTest
    public static void getGuarantorWithActiveCGTest() {
        Contact gt = [
                SELECT Id
                FROM Contact
                WHERE RecordTypeId = :RecordTypeUtil.guarantorRt
                LIMIT 1
        ];

        // Call getGuarantorFilterCGByAcctSubStatus method.
        Test.startTest();
        Contact contact = GuarantorService.getGuarantorWithActiveCG(gt.Id);
        Test.stopTest();

        // Check system assert, Charge Group size of Contact.
        System.assertEquals(contact.Charge_Groups__r.size(), 1);
        System.assertEquals(gt.Id, contact.Id);
        System.assert(contact.Charge_Groups__r.get(0).Active__c);
    }
}