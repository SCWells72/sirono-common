/**
 * This class generates MockHttpResponseGenerator for HttpCalloutMock.
 **/

@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {

    /**
     * This method generates & returns HttpResponse for provided HTTPRequest.
     **/
    global HTTPResponse respond(HTTPRequest req) {
        System.debug('MockHttpResponseGenerator.respond endpoint: '+req.getEndpoint());

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
            } else {
                res.setBody(getPaymentPlanJSONBody());
            }

            return res;

        }

    	HttpResponse res = new HttpResponse();
        if (req.getEndpoint().contains('/paystaff/api/guarantors/') &&
                req.getEndpoint().endsWith('statements/')) {
            // Mock statement urls
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"statement_date": "2015-11-22", ' +
                    '"pdf_url": "https://accudoc-toledo.s3.amazonaws.com/20151123/13_55_13_sir.0x1355137f.pdf?' +
                    'Signature=TLcx4lV6cNNZ0eGPuiyRXe6LrAQ%3D&Expires=1469037622&AWSAccessKeyId=AKIAJDZKICOKPTWZUYQA"}, ' +
                    '{"statement_date": "2015-12-22", ' +
                    '"pdf_url": "https://accudoc-toledo.s3.amazonaws.com/20151222/13_b6_4f_sir.0x13b64f16.pdf?' +
                    'Signature=lPtjuaCk%2FNyQBByqWaM6NLNA4nw%3D&Expires=1469037622&AWSAccessKeyId=AKIAJDZKICOKPTWZUYQA"}, ' +
                    '{"statement_date": "2016-01-22", ' +
                    '"pdf_url": "https://accudoc-toledo.s3.amazonaws.com/20160122/14_22_ad_sir.0x1422ad09.pdf?' +
                    'Signature=WVvV4DXwQcvmQr%2BWDJ0U0Zvb4gA%3D&Expires=1469037622&AWSAccessKeyId=AKIAJDZKICOKPTWZUYQA"}, ' +
                    '{"statement_date": "2016-02-22", ' +
                    '"pdf_url": "https://accudoc-toledo.s3.amazonaws.com/20160222/14_8c_c7_sir.0x148cc7bb.pdf?' +
                    'Signature=AYC3U2PM4MrVppq402jszEHWK60%3D&Expires=1469037622&AWSAccessKeyId=AKIAJDZKICOKPTWZUYQA"}, ' +
                    '{"statement_date": "2016-03-22", ' +
                    '"pdf_url": None}]');

            res.setStatusCode(200);
            return res;
        } else if (req.getEndpoint().contains('/paystaff')) {
            // Mock statement urls
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"statement_date": "2015-11-22", ' +
                    '"pdf_url": "https://accudoc-toledo.s3.amazonaws.com/20151123/13_55_13_sir.0x1355137f.pdf?' +
                    'Signature=TLcx4lV6cNNZ0eGPuiyRXe6LrAQ%3D&Expires=1469037622&AWSAccessKeyId=AKIAJDZKICOKPTWZUYQA"}, ' +
                    '{"statement_date": "2015-12-22", ' +
                    '"pdf_url": "https://accudoc-toledo.s3.amazonaws.com/20151222/13_b6_4f_sir.0x13b64f16.pdf?' +
                    'Signature=lPtjuaCk%2FNyQBByqWaM6NLNA4nw%3D&Expires=1469037622&AWSAccessKeyId=AKIAJDZKICOKPTWZUYQA"}, ' +
                    '{"statement_date": "2016-01-22", ' +
                    '"pdf_url": "https://accudoc-toledo.s3.amazonaws.com/20160122/14_22_ad_sir.0x1422ad09.pdf?' +
                    'Signature=WVvV4DXwQcvmQr%2BWDJ0U0Zvb4gA%3D&Expires=1469037622&AWSAccessKeyId=AKIAJDZKICOKPTWZUYQA"}, ' +
                    '{"statement_date": "2016-02-22", ' +
                    '"pdf_url": "https://accudoc-toledo.s3.amazonaws.com/20160222/14_8c_c7_sir.0x148cc7bb.pdf?' +
                    'Signature=AYC3U2PM4MrVppq402jszEHWK60%3D&Expires=1469037622&AWSAccessKeyId=AKIAJDZKICOKPTWZUYQA"}, ' +
                    '{"statement_date": "2016-03-22", ' +
                    '"pdf_url": None}]');

            res.setStatusCode(200);
            return res;
        }

        // Check system assert, HttpResponse should not be null.
        System.assertNotEquals(res, null, 'HttpResponse is not generated for submitted HTTPRequest');

        return null;
    }

    public static String getPaymentPlanJSONBody() {
        return '{'+
                '   "url": "http://127.0.0.1:8000/paystaff/api/paymentplan/2876/",'+
                '   "active": true,'+
                '   "installment_amount": 5000,'+
                '   "number_installments": 7,'+
                '   "plan_value": 32772,'+
                '   "plan_type": "auto",'+
                '   "payable_amount": 32772,'+
                '   "execute_on_day": 13,'+
                '   "guarantor": "http://127.0.0.1:8000/paystaff/api/guarantors/23232323/",'+
                '   "next_payment_date": "2017-05-13",'+
                '   "installments_paid": 0,'+
                '   "installments_total": 7,'+
                '   "credit_card": {'+
                '       "card_type": "Visa",'+
                '       "last_4": "1881"'+
                '   },'+
                '   "has_error": false,'+
                '   "charges_added_since_start": null,'+
                '   "error_date": null, '+
                '   "chargegroups": ["http://127.0.0.1:8000/paystaff/api/chargegroups/123456/", "http://127.0.0.1:8000/paystaff/api/chargegroups/12345/"],'+
                '   "delinquent": false,'+
                '   "delinquent_date": null, '+
                '   "encounters": [],'+
                '   "authorized_amount": 0,'+
                '   "skip_payment_until": null,'+
                '   "status":"started"'+
                '}';
    }
}