/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Test class for thee PaymentPlayRestClient Service.
 */
@IsTest
private class PaymentPlanRestClientTest {

    @IsTest
    static void verifyGetUrls() {
        Test.startTest();
        Map<String, String> urls = new PaymentPlanService.PaymentPlanRestClient().getUrls();
        Test.stopTest();
        System.assertEquals(RestClientConstants.PAYMENT_PLAN_URLS, urls, 'Should be configured with payment plan urls.');
    }

    @IsTest
    static void addToPaymentPlanSuccess() {

        Test.setMock(HttpCalloutMock.class, new PaymentPlanRestClientMock());

        Test.startTest();
        PaymentPlanService.PaymentPlanRestClient paymentPlanRestClient = new PaymentPlanService.PaymentPlanRestClient();
        paymentPlanRestClient.addToPlan(RestClientConstants.PAYMENT_PLAN_EXT_ID, new String[] { RestClientConstants.CHARGE_GROUP_ID });
        Test.stopTest();

        System.assertEquals(RestClientConstants.HTTP_SUCCESS, paymentPlanRestClient.getStatusCode(), 'Should have successfully called add charge group endpoint.');

        HttpRequest req = paymentPlanRestClient.getRequest();
        System.assert(req != null, 'Should have populated the request object.');
        System.assert(req.getHeader(RestClientConstants.AUTHORIZATION) != null, 'Should have set the authorization header.');
        System.assertEquals(RestClientConstants.APPLICATION_JSON, req.getHeader(RestClientConstants.CONTENT_TYPE), 'Should have set the authorization header.');
        String body = req.getBody();
        System.assert(body.indexOf(RestClientConstants.CHARGE_GROUP_ID) != -1, 'Should have a json body including the charge group id.');
    }

    @IsTest
    static void addToPaymentPlanFailure() {

        Test.setMock(HttpCalloutMock.class, new AuthRestClientFailMock());
        PaymentPlanService.PaymentPlanRestClient paymentPlanRestClient;
        try {
            Test.startTest();
            paymentPlanRestClient = new PaymentPlanService.PaymentPlanRestClient();
            paymentPlanRestClient.addToPlan(RestClientConstants.PAYMENT_PLAN_EXT_ID, new String[] { RestClientConstants.CHARGE_GROUP_ID });
        } catch (SironoServiceException e) {
            Test.stopTest();
            System.assertNotEquals(null, e, 'Should have an exception');
            System.assertEquals('Permission Denied Exception: Incorrect authentication credentials.', e.errors.get(0),
                'Should have proper message.');
            System.assertEquals(RestClientConstants.HTTP_BAD_REQUEST, paymentPlanRestClient.getStatusCode(), 'Should have bad request status code.');
        }

    }

    @IsTest
    static void getPaymentPlanSuccess() {

        Test.setMock(HttpCalloutMock.class, new PaymentPlanRestClientMock());

        Test.startTest();
        PaymentPlanService.PaymentPlanRestClient paymentPlanRestClient = new PaymentPlanService.PaymentPlanRestClient();
        paymentPlanRestClient.getPlan(RestClientConstants.PAYMENT_PLAN_EXT_ID);
        Test.stopTest();

        System.assertEquals(RestClientConstants.HTTP_SUCCESS, paymentPlanRestClient.getStatusCode(), 'Should have successfully called add charge group endpoint.');

        HttpRequest req = paymentPlanRestClient.getRequest();
        System.assert(req != null, 'Should have populated the request object.');
        System.assert(req.getHeader(RestClientConstants.AUTHORIZATION) != null, 'Should have set the authorization header.');
        System.assertEquals(RestClientConstants.APPLICATION_JSON, req.getHeader(RestClientConstants.CONTENT_TYPE), 'Should have set the authorization header.');
        System.assert(String.isEmpty(req.getBody()), 'Should not have set the body.');

    }

    @IsTest
    static void getPaymentPlanFailure() {

        Test.setMock(HttpCalloutMock.class, new AuthRestClientFailMock());
        PaymentPlanService.PaymentPlanRestClient paymentPlanRestClient;
        try {
            Test.startTest();
            paymentPlanRestClient = new PaymentPlanService.PaymentPlanRestClient();
            paymentPlanRestClient.getPlan(RestClientConstants.PAYMENT_PLAN_EXT_ID);
        } catch (SironoServiceException e) {
            Test.stopTest();
            System.assertNotEquals(null, e, 'Should have an exception');
            System.assertEquals('Permission Denied Exception: Incorrect authentication credentials.', e.errors.get(0),
                'Should have proper message.');
            System.assertEquals(RestClientConstants.HTTP_BAD_REQUEST, paymentPlanRestClient.getStatusCode(), 'Should have bad request status code.');
        }

    }


}
