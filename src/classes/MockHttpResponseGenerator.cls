/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This class generates MockHttpResponseGenerator for HttpCalloutMock.
 **/
@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {

    // Track if the mock plan has been deleted
    private static Boolean hasBeenDeleted = false;
    /**
     * This method generates & returns HttpResponse for provided HTTPRequest.
     **/
    global HTTPResponse respond(HTTPRequest req) {
        System.debug('MockHttpResponseGenerator.respond endpoint: ' + req.getEndpoint());

        if (req.getEndpoint().contains('/paystaff/token-auth/') ||
            req.getEndpoint().contains('/portal/account/forgot-password/')) {
            AuthRestClientMock authMock = new AuthRestClientMock();
            return authMock.respond(req);
        }

        if (req.getEndpoint().contains('/paystaff/api/paymentplan/')) {
            // Mock a paymentplan request
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            if (req.getEndpoint().endsWith('/add_chargegroups/')) {
                //Do nothing
            } else if (req.getMethod() == RestClientConstants.REMOVE) {
                res.setStatusCode(RestClientConstants.HTTP_DELETED);
                hasBeenDeleted = true;
            } else {
                res.setBody(getPaymentPlanJSONBody());
            }

            if (hasBeenDeleted) {
                String jsonBody = getPaymentPlanJSONBody();
            }
            return res;

        }

        if (req.getEndpoint().contains('/paystaff/api/chargegroups/')) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(RestClientConstants.HTTP_SUCCESS);
            if (req.getEndpoint().endsWith('/add_chargegroups/')) {
            } if (req.getMethod() == RestClientConstants.GET) {
                res.setBody(ChargeGroupRestClientMock.getChargeGroupJSONBody());
            } else {
                throw new SironoServiceException('Unexpected GET url sent to MockHttpResponseGenerator.');
            }

            return res;
        }

        if ('POST'.equalsIgnoreCase(req.getMethod())) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(RestClientConstants.HTTP_SUCCESS);
            res.setBody('');
            // Check system assert, HttpResponse should not be null.
            System.assertNotEquals(res, null, 'HttpResponse is not generated for submitted HTTPRequest');
            return res;
        }
        return null;
    }

    @testVisible
    private static String guarantorSironoId = '23232323';
    @testVisible
    private static String planSironoId = '2876';

    public static String getPaymentPlanJSONBody() {
        String body = '{' +
            '   "url": "http://127.0.0.1:8000/paystaff/api/paymentplan/' + planSironoId + '/",' +
            '   "active": true,' +
            '   "installment_amount": 5000,' +
            '   "number_installments": 7,' +
            '   "plan_value": 32772,' +
            '   "plan_type": "auto",' +
            '   "payable_amount": 32772,' +
            '   "execute_on_day": 13,' +
            '   "guarantor": "http://127.0.0.1:8000/paystaff/api/guarantors/' + guarantorSironoId + '/",' +
            '   "next_payment_date": "2017-05-13",' +
            '   "installments_paid": 0,' +
            '   "installments_total": 7,' +
            '   "credit_card": {' +
            '       "card_type": "Visa",' +
            '       "last_4": "1881"' +
            '   },' +
            '   "has_error": false,' +
            '   "charges_added_since_start": null,' +
            '   "error_date": null, ' +
            '   "delinquent": false,' +
            '   "delinquent_date": null, ' +
            '   "encounters": [],' +
            '   "authorized_amount": 0,' +
            '   "skip_payment_until": null,' +
            '   "status":"started",';

        // If the delete call hasn't been made include the charge groups
        if (!hasBeenDeleted) {
            body += '"chargegroups": ["http://127.0.0.1:8000/paystaff/api/chargegroups/123456/", "http://127.0.0.1:8000/paystaff/api/chargegroups/12345/"]';
        } else {
            body += '"chargegroups": []';
        }

        body += '}';
        return body;
    }
}