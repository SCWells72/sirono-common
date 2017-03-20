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
}