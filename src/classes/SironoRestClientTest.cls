/**
 * Tests for the SironoRestClient class.
 */

@IsTest
private class SironoRestClientTest {

    @isTest
    static void verifyGetUrls() {
        Test.startTest();
        Map<String, String> urls = new SironoRestClient.AuthRestClient().getUrls();
        Test.stopTest();
        System.assertEquals(RestClientConstants.AUTH_URLS, urls, 'Should be configured with auth urls.');
    }

    @isTest
    static void getJwtTokenSuccess() {
        String actualToken;
        Test.setMock(HttpCalloutMock.class, new AuthRestClientMock());

        Test.startTest();
        SironoRestClient.AuthRestClient AuthRestClient = new SironoRestClient.AuthRestClient();
        actualToken = AuthRestClient.getJwtToken();
        Test.stopTest();

        System.assertEquals(RestClientConstants.HTTP_SUCCESS, AuthRestClient.getStatusCode(), 'Should get a 200 status code.');
        System.assertEquals(RestClientMockUtil.TOKEN, actualToken, 'Should get valid token.');
    }

    @isTest
    static void getJwtTokenFailure() {
        String actualToken;
        Test.setMock(HttpCalloutMock.class, new RestClientFailMock(TestUtility.JSON_ERROR_BODIES.get(TestUtility.JSON_BODY_TYPE.UNAUTHORIZED)));
        SironoRestClient.AuthRestClient AuthRestClient;
        try {
            Test.startTest();
            AuthRestClient = new SironoRestClient.AuthRestClient();
            actualToken = AuthRestClient.getJwtToken();
        } catch (SironoServiceException e) {
            Test.stopTest();
            System.assertEquals(null, actualToken, 'Should not have set the token.');
            System.assertNotEquals(null, e, 'Should have an exception');
            System.assertEquals(1, e.errors.size(), 'Should have a single error message');
            System.assertEquals('Permission Denied Exception: Incorrect authentication credentials.', e.errors.get(0),
                    'Should have proper message.');
            System.assertEquals(RestClientConstants.HTTP_BAD_REQUEST, AuthRestClient.getStatusCode(), 'Should have bad request status code.');
        } catch (Exception ex) {
            System.assert(false, 'Should have been a SironoServiceException.');
        }

    }

    @isTest
    static void getCsrfSuccess() {
        String actualCsrf;
        Test.setMock(HttpCalloutMock.class, new AuthRestClientMock());

        Test.startTest();
        SironoRestClient.AuthRestClient AuthRestClient = new SironoRestClient.AuthRestClient();
        actualCsrf = AuthRestClient.getCsrfToken();
        Test.stopTest();

        System.assertEquals(RestClientConstants.HTTP_SUCCESS, AuthRestClient.getStatusCode(), 'Should get a 200 status code.');
        System.assertEquals(RestClientMockUtil.CSRF, actualCsrf, 'Should get valid csrf value.');
    }

    @isTest
    static void getCsrfFailure() {
        String actualCsrf;
        Test.setMock(HttpCalloutMock.class, new RestClientFailMock(TestUtility.JSON_ERROR_BODIES.get(TestUtility.JSON_BODY_TYPE.UNAUTHORIZED)));
        SironoRestClient.AuthRestClient AuthRestClient;
        try {
            Test.startTest();
            AuthRestClient = new SironoRestClient.AuthRestClient();
            actualCsrf = AuthRestClient.getCsrfToken();
        } catch (SironoServiceException e) {
            Test.stopTest();
            System.assertEquals(null, actualCsrf, 'Should not have set the token.');
            System.assertNotEquals(null, e, 'Should have an exception');
            System.assertEquals(1, e.errors.size(), 'Should have a single error message');
            System.assertEquals('Permission Denied Exception: Incorrect authentication credentials.', e.errors.get(0),
                    'Should have proper message.');
            System.assertEquals(RestClientConstants.HTTP_BAD_REQUEST, AuthRestClient.getStatusCode(), 'Should have bad request status code.');
        } catch (Exception ex) {
            System.assert(false, 'Should have been a SironoServiceException.');
        }

    }

    @isTest
    static void processFailedResponseWrapperError() {
        String expected = 'Payments Exception: Nonfield Error - Amount exceeds selected charge groups';
        SironoRestClient.AuthRestClient AuthRestClient;

        Test.startTest();
        AuthRestClient = new SironoRestClient.AuthRestClient();
        List<String> errors = AuthRestClient.processFailedResponse(TestUtility.JSON_ERROR_BODIES.get(TestUtility.JSON_BODY_TYPE.PAYMENT_NON_FIELD));
        Test.stopTest();

        System.assert(errors != null, 'Should have gotten errors.');
        System.assertEquals(1, errors.size(), 'Should have had a single error message');
        System.assertEquals(expected, errors.get(0), 'Should have found PAYMENT_NON_FIELDS error message.');
    }

    @isTest
    static void processFailedResponseWrapperErrorArray() {
        String expected = 'Validation exception: Nonfield Error - Cannot directly change ChargeGroups on an existing plan';
        SironoRestClient.AuthRestClient AuthRestClient;

        Test.startTest();
        AuthRestClient = new SironoRestClient.AuthRestClient();
        List<String> errors = AuthRestClient.processFailedResponse(TestUtility.JSON_ERROR_BODIES.get(TestUtility.JSON_BODY_TYPE.VALIDATION_EXISTING_PLAN));
        Test.stopTest();

        System.assert(errors != null, 'Should have gotten errors.');
        System.assertEquals(1, errors.size(), 'Should have had a single error message');
        System.assertEquals(expected, errors.get(0), 'Should have found VALIDATION_EXISTING_PLAN error message.');
    }

    @isTest
    static void processFailedResponseWrapperListError() {
        String expected = 'Payments Exception: Credit card number is invalid.';
        String merchantExpected = 'Payments Exception: Merchant account does not support payment instrument.';
        SironoRestClient.AuthRestClient AuthRestClient;

        Test.startTest();
        AuthRestClient = new SironoRestClient.AuthRestClient();
        List<String> errors = AuthRestClient.processFailedResponse(TestUtility.JSON_ERROR_BODIES.get(TestUtility.JSON_BODY_TYPE.PAYMENT_LIST));
        Test.stopTest();

        System.assert(errors != null, 'Should have gotten errors.');
        System.assertEquals(2, errors.size(), 'Should have had two error messages');
        System.assertEquals(expected, errors.get(0), 'Should have found PAYMENT_LIST error message.');
        System.assertEquals(merchantExpected, errors.get(1), 'Should have found PAYMENT_LIST error message.');
    }

    @isTest
    static void processFailedResponseWrapperNonFieldErrorArray() {
        String expected = 'Nonfield Error: Cannot directly change ChargeGroups on an existing plan';
        SironoRestClient.AuthRestClient AuthRestClient;

        Test.startTest();
        AuthRestClient = new SironoRestClient.AuthRestClient();
        List<String> errors = AuthRestClient.processFailedResponse(TestUtility.JSON_ERROR_BODIES.get(TestUtility.JSON_BODY_TYPE.NO_KIND));
        Test.stopTest();

        System.assert(errors != null, 'Should have gotten errors.');
        System.assertEquals(1, errors.size(), 'Should have had one error message.');
        System.assertEquals(expected, errors.get(0), 'Should have found NO_KIND error message.');
    }

    @isTest
    static void processFailedResponseJsonException() {
        String expected = 'Unknown JSON format for failed response. [body: ["dummy": "JSON"]]';
        SironoRestClient.AuthRestClient AuthRestClient;

        Test.startTest();
        try {
            AuthRestClient = new SironoRestClient.AuthRestClient();
            List<String> errors = AuthRestClient.processFailedResponse('["dummy": "JSON"]');
        } catch (JSONException jsonException) {
            Test.stopTest();

            System.assert(jsonException != null, 'Should have an exception.');
            System.assertEquals(expected, jsonException.getMessage(), 'Should have json exception error message.');
        } catch (Exception e) {
            System.assert(false, 'Should have been a JSONException.');
        }

    }

    /**
     * Test the Dollar to Cents Conversion
     **/
    @isTest
    public static void testConvertDollarToCents() {
        String inputDollars = '100.00';
        Test.startTest();
        String outputCents = SironoRestClient.convertToCents(inputDollars);
        Test.stopTest();

        // Check system assert.
        System.assert('10000'.equals(outputCents), 'Expected 10000, but got ' + outputCents);
    }
}
