/**
 * Class used to Mock responses from the guarantor endpoints in Sirono.
 */

@IsTest
public class GuarantorsRestClientMock implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
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

            if (url == RestClientMockUtil.urlBuilder(urls.get(RestClientConstants.STATEMENTS), new String[]{RestClientConstants.GUARANTOR_ID})) {
                res.setStatusCode(RestClientConstants.HTTP_SUCCESS);
                res.setBody(RestClientConstants.STATEMENTS_JSON);
            } else {
                throw new SironoServiceException('Unexpected GET url in GuarantorsRestClientMock');
            }

        } else {
            throw new SironoServiceException('Unexpected method in GuarantorsRestClientMock');
        }

        return res;
    }

}
