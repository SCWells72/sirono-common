/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Class used to Mock responses from the payment plan endpoints in Sirono.
 */
@IsTest
public class PaymentPlanRestClientMock implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res;

        // First see if the req matches any of the auth routes
        res = RestClientMockUtil.handleAuthRequest(req);
        if (res != null) {
            return res;
        }

        String method = req.getMethod();
        String url = req.getEndpoint();
        Map<String, String> urls = RestClientConstants.PAYMENT_PLAN_URLS;

        res = new HttpResponse();

        System.debug('>>>>>>>> method: '+method+' url: '+url);
        if (method == RestClientConstants.GET) {
            if (url == RestClientMockUtil.urlBuilder(urls.get(RestClientConstants.PAYMENT_PLAN_KEY), new String[]{RestClientConstants.PAYMENT_PLAN_EXT_ID})) {
                res.setStatusCode(RestClientConstants.HTTP_SUCCESS);
                res.setHeader('Content-Type', 'application/json');
                res.setBody(MockHttpResponseGenerator.getPaymentPlanJSONBody());
            } else {
                throw new SironoServiceException('Unexpected GET url sent to PaymentPlanRestClientMock');
            }

        } else if (method == RestClientConstants.POST) {
            String expectedUrl = RestClientMockUtil.urlBuilder(urls.get(RestClientConstants.ADD_CHARGEGROUP_KEY), new String[]{RestClientConstants.PAYMENT_PLAN_EXT_ID});
            if (url == expectedUrl) {
                res.setStatusCode(RestClientConstants.HTTP_SUCCESS);
            } else {
                throw new SironoServiceException('Unexpected POST url: '+url+' sent to PaymentPlanRestClientMock. Expected: '+expectedUrl);
            }

        } else {
            throw new SironoServiceException('Unexpected method sent to PaymentPlanRestClientMock');
        }
        
        // Check system assert.
        System.assertNotEquals(res, null, 'Should have failed due to res is null.');

        return res;
    }

}
