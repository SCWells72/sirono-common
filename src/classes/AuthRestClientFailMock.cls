/**
 * HttpCalloutMock implementor that will return fail all requests, but allows for successful calls to the AuthRestClient
 * code for getting tokens and such.
 */

@IsTest
public class AuthRestClientFailMock implements HttpCalloutMock {

    /**
     * Respond method for all calls but the Auth calls.  Used to test other Http requests that have a dependancy on
     * token responses.
     *
     * @param - HttpRequest req The req being mocked.
     */
    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse res;

        // First see if the req matches any of the auth routes
        res = RestClientMockUtil.handleAuthRequest(req);
        if (res != null) {
            return res;
        }

        res = new HttpResponse();
        res.setStatusCode(RestClientConstants.HTTP_BAD_REQUEST);
        res.setBody(TestUtility.JSON_ERROR_BODIES.get(TestUtility.JSON_BODY_TYPE.UNAUTHORIZED));

        // Check system assert.
        System.assertNotEquals(res, null, 'Should have failed due to res is null.');

        return res;
    }
}