/**
 * HttpCalloutMock implementor that will return fail all requests.
 */
@IsTest
public class RestClientFailMock implements HttpCalloutMock {
    private String body = '';

    public RestClientFailMock() {
    }
    public RestClientFailMock(String responseBody) {
        body = responseBody;
    }

    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        res.setStatusCode(RestClientConstants.HTTP_BAD_REQUEST);
        res.setBody(body);
        
        // Check system assert.
        System.assertNotEquals(res, null, 'Should have failed due to res is null.');
        
        return res;
    }
}