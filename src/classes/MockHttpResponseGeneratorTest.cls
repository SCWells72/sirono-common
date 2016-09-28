/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 09-06-2016
 * Viraj: Dummy class for the call out.
 */

@isTest
global class MockHttpResponseGeneratorTest implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if (req.getEndpoint().contains('/paymentplan')) {
            res.setBody(TestUtility.responseBody);
        } else if (req.getEndpoint().contains('api/chargegroups')) {
            res.setBody(ChargeGroupJSONParsing.testParse());
        } else {
            res.setBody(TestUtility.body);
        }

        if (req.getMethod() == 'DELETE') {
            res.setStatusCode(204);
        } else {
            res.setStatusCode(TestUtility.statusCode);
        }

        res.setStatus(TestUtility.status);

        return res;
    }
}