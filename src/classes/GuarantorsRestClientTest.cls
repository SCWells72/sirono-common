/**
 * Test class for the GuarantorsRestClient.
 */

@IsTest
private class GuarantorsRestClientTest {

    @isTest
    static void verifyGetUrls() {
        Test.startTest();
        Map<String, String> urls = new GuarantorsRestClient().getUrls();
        Test.stopTest();
        System.assertEquals(RestClientConstants.GUARANTOR_URLS, urls, 'Should be configured with guarantors urls.');
    }

    @isTest
    static void getStatementsSuccess() {

        Test.setMock(HttpCalloutMock.class, new GuarantorsRestClientMock());

        Test.startTest();
        GuarantorsRestClient guarantorsRestClient = new GuarantorsRestClient();
        guarantorsRestClient.getStatements(RestClientConstants.GUARANTOR_ID);
        Test.stopTest();

        System.assertEquals(RestClientConstants.HTTP_SUCCESS, guarantorsRestClient.getStatusCode(), 'Should have successfully called statements endpoint.');

        HttpRequest req = guarantorsRestClient.getRequest();
        System.assert(req != null, 'Should have populated the request object.');
        System.assert(req.getHeader(RestClientConstants.AUTHORIZATION) != null, 'Should have set the authorization header.');
        System.assertEquals(RestClientConstants.APPLICATION_JSON, req.getHeader(RestClientConstants.CONTENT_TYPE), 'Should have set the authorization header.');

        String body = guarantorsRestClient.getResponseBody();
        System.assert(!String.isEmpty(body), 'Should have a json body in response.');
    }

    @isTest
    static void getStatementsFailure() {

        Test.setMock(HttpCalloutMock.class, new AuthRestClientFailMock());
        GuarantorsRestClient guarantorsRestClient;
        try {
            Test.startTest();
            guarantorsRestClient = new GuarantorsRestClient();
            guarantorsRestClient.getStatements(RestClientConstants.GUARANTOR_ID);
        } catch (SironoServiceException e) {
            Test.stopTest();
            System.assertNotEquals(null, e, 'Should have an exception');
            System.assertEquals(1, e.errors.size(), 'Should have gotten the unauthorized error.');
            System.assertEquals('Permission Denied Exception: Incorrect authentication credentials.', e.errors.get(0),
                    'Should have auth failure message.');
            System.assertEquals(RestClientConstants.HTTP_BAD_REQUEST, guarantorsRestClient.getStatusCode(), 'Should have bad request status code.');
        }

    }
}
