/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Test the functionality of GuarantorService
 */
@IsTest
public with sharing class GuarantorServiceTest {

    private static String SIRONO_ID = '99887766';
    private static String FIRST = 'TestFirstName';
    private static String MIDDLE = 'TestMiddleName';
    private static String LAST = 'TestLastName';
    private static String SUFFIX = 'Jr.';
    private static Date BIRTHDATE = Date.today().addYears(-20);
    private static String MRN = 'TEST_MRN_12345';

    public class GuarantorRestClientMock implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res;

            // First see if the req matches any of the auth routes
            res = RestClientMockUtil.handleAuthRequest(req);
            if (res != null) {
                return res;
            }

            String method = req.getMethod();
            String url = req.getEndpoint();
            Map<String, String> urls = RestClientConstants.GUARANTOR_URLS;

            res = new HttpResponse();
            if (method == RestClientConstants.GET) {
                if (url == RestClientMockUtil.urlBuilder(urls.get(RestClientConstants.STATEMENTS), new String[] { RestClientConstants.GUARANTOR_ID })) {
                    res.setStatusCode(RestClientConstants.HTTP_SUCCESS);
                    res.setBody(RestClientConstants.STATEMENTS_JSON);
                } else {
                    throw new SironoServiceException('Unexpected GET url in GuarantorRestClientMock');
                }

            } else {
                throw new SironoServiceException('Unexpected method in GuarantorRestClientMock');
            }

            // Check system assert.
            System.assertNotEquals(res, null, 'Should have failed due to res is null.');

            return res;
        }

    }

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
        insert gt;

        Contact pt = TestUtility.generatePatientContact();
        pt.Patient_Id__c = Decimal.valueOf(SIRONO_ID);
        insert pt;

        // Create Charge Group Record.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(gt.Id, pt.Id, 12345);
        chargeGroup.Active__c = true;
        insert chargeGroup;

        Transaction__c transactionObj = TestUtility.generateTransaction(chargeGroup, 100, Constants.AUTOMATIC);
        insert transactionObj;

        // Create Charge Group Record.
        chargeGroup = TestUtility.generateChargeGroup(gt.Id, pt.Id, 67890);
        chargeGroup.Active__c = false;
        insert chargeGroup;

        // Check system asserts.
        System.assertEquals(Decimal.valueOf(SIRONO_ID), gt.Profile_Pointer_ID__c, 'Expected ' + SIRONO_ID + ' but we got ' + gt.Profile_Pointer_ID__c);
    }

    /*
        Test building full detail string
     */
    @IsTest
    public static void buildGuarantorDetailStringTest() {
        Contact gt = GuarantorDao.getGuarantorBySironoId(SIRONO_ID);
        String expected = FIRST + ' ' + MIDDLE + ' ' + LAST + ' ' + SUFFIX + ' (DOB: ' + BIRTHDATE.format() + ', MRN: ' + MRN + ')';
        String built = GuarantorService.buildGuarantorDetailString(gt);
        System.assertEquals(expected, built, 'Expected details: ' + expected + ' but got: ' + built);
    }

    @IsTest
    public static void getSironoIdTest() {
        Contact gt = GuarantorDao.getGuarantorBySironoId(SIRONO_ID);
        String foundId = GuarantorService.getGuarantorSironoId(gt);
        System.assertEquals(SIRONO_ID, foundId, 'Expected sironoId: ' + SIRONO_ID + ' but got: ' + foundId);
    }

    @IsTest
    public static void getSironoIdFromDBTest() {
        Contact gt = GuarantorDao.getGuarantorBySironoId(SIRONO_ID);
        Contact newContact = new Contact();
        newContact.Id = gt.Id;
        String foundId = GuarantorService.getGuarantorSironoId(newContact);
        System.assertEquals(SIRONO_ID, foundId, 'Expected sironoId: ' + SIRONO_ID + ' but got: ' + foundId);
    }

    @IsTest
    public static void getSironoIdExceptionTest() {
        try {
            GuarantorService.getGuarantorSironoId(null);
            System.assert(false, 'Expected SironoServiceException to be thrown');
        } catch (SironoServiceException ex) {
            System.assertEquals(ex.getMessage(), 'Invalid request - Contact required to retrieve SironoId');
        }
    }

    @IsTest
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
    @IsTest
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

    /*
     * Test retrieval of a portal user's associated  guarantor contact
     *
     */
    @IsTest
    public static void getPortalGuarantorTest() {
        Test.startTest();
        User usr = TestUtility.getGuarantorCommunityUser();
        Contact gt = GuarantorService.getPortalGuarantor(usr.Id);
        Test.stopTest();

        System.assert(gt != null, 'Guarantor contact not found for user: ' + usr.Username);
    }

    /*
     * Negative test: retrieve a non-portal user's associated guarantor contact (which he doesn't have)
     *
     */
    @IsTest
    public static void nonPortalUserGetGuarantorTest() {
        User usr = TestUtility.generateUser(Constants.STANDARD_USER, null);
        insert usr;
        System.assert(usr.Id != null, 'No user created for test');

        try {
            Test.startTest();
            Contact gt = GuarantorService.getPortalGuarantor(usr.Id);
            Test.stopTest();

            System.assert(gt == null, 'Unexpected guarantor contact found for user' + usr.Username);

        } catch (SironoServiceException ex) {
            System.assert(ex.getMessage().startsWith('No Guarantor associated with user '), 'Unexpected exception caught: ' + ex.getMessage());
        }
    }

    /*
     * Negative test: retrieve a non-portal user's associated guarantor contact (which he doesn't have)
     *
     */
    @IsTest
    public static void invalidUserGetGuarantorTest() {

        try {
            Test.startTest();
            Contact gt = GuarantorService.getPortalGuarantor('12324');
            Test.stopTest();

            System.assert(gt == null, 'Unexpected guarantor contact found for user');

        } catch (SironoServiceException ex) {
            System.assert(ex.getMessage().startsWith('No user with id'), 'Unexpected exception caught: ' + ex.getMessage());
        }
    }

    /**
     * Test the retrieval of the statement pdf urls
     */
    @IsTest
    static void testGetStatementsSuccess() {

        Test.setMock(HttpCalloutMock.class, new GuarantorRestClientMock());

        Test.startTest();
        Map<Date, String> urlMap = GuarantorService.getStatementMap(RestClientConstants.GUARANTOR_ID);
        Test.stopTest();

        for (Date key : urlMap.keySet()) {
            System.debug('key: ' + key.format() + ' url: ' + urlMap.get(key));
        }

        System.assertEquals(urlMap.size(), 5, 'Expected 5 entries in the url map');
    }
}