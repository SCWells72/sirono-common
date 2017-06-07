/**
 * Test the NumVerifyValidator
 */

@isTest
public class NumVerifyValidatorTest {

    @isTest
    public static void testNumberCleaning_NumberTooLong() {
        String phoneNumber = '+1-852-999-3456 x9292';
        NumVerifyValidator.VerifiedNumber nbr = new NumVerifyValidator.VerifiedNumber(phoneNumber);
        System.assert(!nbr.isValid(), 'Expected number to be invalid - too many digits');
    }

    @isTest
    public static void testNumberCleaning_NumberTooShort() {
        String phoneNumber = '852-999-345';
        NumVerifyValidator.VerifiedNumber nbr = new NumVerifyValidator.VerifiedNumber(phoneNumber);
        System.assert(!nbr.isValid(), 'Expected number to be invalid - too short');
    }

    @isTest
    public static void testNumberCleaning_NumberValid_Local() {
        String phoneNumber = '(852) 999-3451';
        NumVerifyValidator.VerifiedNumber nbr = new NumVerifyValidator.VerifiedNumber(phoneNumber);
        System.assert(nbr.isValid(), 'Expected number to be valid');
    }

    @isTest
    public static void testNumberCleaning_NumberValid_Intl() {
        String phoneNumber = '+1 (852) 999-3451';
        NumVerifyValidator.VerifiedNumber nbr = new NumVerifyValidator.VerifiedNumber(phoneNumber);
        System.assert(nbr.isValid(), 'Expected number to be valid');
    }

    @isTest
    public static void testRequestConstruction() {
        //Set up a valid number
        String phoneNumber = '+1 (852) 999-3451';

        Sirono_Settings__c sironoSettings = Sirono_Settings__c.getOrgDefaults();
        sironoSettings.Country_Code__c = 'GB';
        sironoSettings.Format__c = 3;
        sironoSettings.Apikey__c = 'thisisthetestapikey';
        UPSERT sironoSettings;

        //Make sure the query parameters are in alpha order to match the way HttpRequest constructs them
        String validUrl = 'https://apilayer.net/api/validate?access_key=thisisthetestapikey&country_code=GB&format=3&number=18529993451';

        NumVerifyValidator.VerifiedNumber vnbr =  new NumVerifyValidator.VerifiedNumber(phoneNumber);
        HttpRequest request = NumVerifyValidator.buildRequest(vnbr);

        System.assert(validURL.equals(request.getEndpoint()), 'Expected urls to match! built: '+request.getEndpoint()+' static: '+validUrl);
        System.assert('post'.equalsIgnoreCase(request.getMethod()), 'Expected method to be POST');
        System.assert(String.isEmpty(request.getBody()), 'Expected empty body');
        System.assert('application/json'.equalsIgnoreCase(request.getHeader('Content-Type')), 'Content-Type should be json');

        DELETE sironoSettings;
    }

    //test to verify a number with an invalid line type
    @isTest
    public static void testVerifyInvalidLineType() {

        TestUtility.statusCode = 200;
        TestUtility.body = PhoneNumberCalloutResponseBody.responseInvalid();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());

        Test.startTest();
        NumVerifyValidator.VerifiedNumber nbr = NumVerifyValidator.verifyPhoneNumber('1234567890');
        Test.stopTest();

        System.assert(nbr.isValid(), 'Expected the number to be valid');
        System.assertEquals(nbr.getLineType(), NumVerifyValidator.INVALID, 'Expected lineType to be Invalid, but was: '+nbr.getLineType());
    }
}