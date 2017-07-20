/**
 * This class tests callouts implemented to take Discount, Adjustment and Payment in SF using fake callout
 * response.
 **/

@isTest
global class MockHttpResponseGeneratorTest implements HttpCalloutMock {

    /**
     * This method generates & returns HttpResponse for provided HTTPRequest.
     **/
    global HTTPResponse respond(HTTPRequest req) {

        if (req.getEndpoint().contains('/paystaff/token-auth/') ||
                req.getEndpoint().contains('/portal/account/forgot-password/')) {
            AuthRestClientMock authMock = new AuthRestClientMock();
            return authMock.respond(req);
        }
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if (req.getEndpoint().contains('/paymentplan')) {
            res.setBody(PaymentPlanJSONParsing.testResponse());
        } else if (req.getEndpoint().contains('api/chargegroups')) {
            res.setBody(ChargeGroupJSONParser.testResponse());
        } else if (req.getEndpoint().contains('api/adjustments')) {
            if (req.getEndpoint().contains('/transactions/')) {
                res.setBody(TransactionJSONParsing.testResponse());
            } else {
                res.setBody(PaymentAdjustmentJSONParsing.testResponse());
            }            
        } else if (req.getEndpoint().contains('api/paychargegroups')) {
            if (req.getEndpoint().contains('/transactions/')) {
                res.setBody(TransactionJSONParsing.testResponse());
            } else {
                res.setBody(PaymentJSONParsing.testResponse());
            }            
        } else {
            res.setBody(TestUtility.body);
        }

        if (req.getMethod() == 'DELETE') {
            res.setStatusCode(204);
        } else {
            res.setStatusCode(TestUtility.statusCode);
        }

        res.setStatus(TestUtility.status);

        // Check system assert, HttpResponse should not be null.
        System.assertNotEquals(res, null, 'HttpResponse is not generated for submitted HTTPRequest');

        return res;
    }
}