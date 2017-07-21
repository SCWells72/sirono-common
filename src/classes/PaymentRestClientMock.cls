/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Class used to Mock responses from the payment plan endpoints in Sirono.
 */
@IsTest
public class PaymentRestClientMock implements HttpCalloutMock {
    public static final String GT_SIRONO_ID = '1111111';
    public static final String PT_SIRONO_ID = '2222222';
    public static final String CG_SIRONO_ID = '3333333';
    public static final String PMT_SIRONO_ID = '4444444';
    public static final String TXN_SIRONO_ID = '5555555';

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res;

        // First see if the req matches any of the auth routes
        res = RestClientMockUtil.handleAuthRequest(req);
        if (res != null) {
            return res;
        }

        String method = req.getMethod();
        String url = req.getEndpoint();
        Map<String, String> urls = RestClientConstants.PAYMENT_URLS;

        res = new HttpResponse();

        System.debug('>>>>>>>> method: '+method+' url: '+url);
        if (method == RestClientConstants.GET) {
            if (url == RestClientMockUtil.urlBuilder(urls.get(RestClientConstants.PAYMENT_TXNS_KEY), new String[]{PMT_SIRONO_ID})) {
                res.setStatusCode(RestClientConstants.HTTP_SUCCESS);
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{'+
                        '   "url":"https://toledo.stage.sirono.com/paystaff/api/transaction/'+TXN_SIRONO_ID+'/", ' +
                        '   "amount":1000,'+
                        '   "post_date":"2016-10-17T00:00:00",'+
                        '   "fail_date":"2016-10-17T00:00:00",'+
                        '   "export_date":"2016-10-17T00:00:00",'+
                        '   "created_at":"2016-10-17T12:41:22.562824",'+
                        '   "modified_at":"2016-10-17T12:41:22.562843",' +
                        '   "method":"credit",' +
                        '   "notes":null,' +
                        '   "credit_balance":false,' +
                        '   "payment":null,' +
                        '   "chargegroup":"https://toledo.stage.sirono.com/paystaff/api/chargegroups/'+CG_SIRONO_ID+'/" ' +
                        '}');
            } else {
                throw new SironoServiceException('Unexpected GET url sent to PaymentRestClientMock: ' + url);
            }

        } else if (method == RestClientConstants.POST) {
            String expectedUrl = RestClientMockUtil.urlBuilder(urls.get(RestClientConstants.PAY_CHARGEGROUPS_KEY), new String[]{CG_SIRONO_ID});
            if (url == expectedUrl) {
                res.setStatusCode(RestClientConstants.HTTP_SUCCESS);
                res.setHeader('Content-Type', 'application/json');
                res.setBody('[{'+
                '   "url": "https://toledo.stage.sirono.com/paystaff/api/payments/'+PMT_SIRONO_ID+'/", ' +
                '   "guarantor":"https://toledo.stage.sirono.com/paystaff/api/guarantors/'+GT_SIRONO_ID+'/",'+
                '   "amount":1000,'+
                '   "transaction_number":"TD-0000020690",'+
                '   "payment_date":"2016-10-13",'+
                '   "method":"credit",'+
                '   "last_4":"0004",'+
                '   "processor_transaction_id":"3f8ex1ft",'+
                '   "receipt_link":"https://toledo.stage.sirono.com/portal/staff/guarantor-mask/72407/?next=/portal/receipt/'+PMT_SIRONO_ID+'/",'+
                '   "payment_info":"Credit Card | Last Digits: 0004",'+
                '   "payment_type":"Online",'+
                '   "account_number":null,'+
                '   "routing_number":null,'+
                '   "bank_account_type":null,'+
                '   "is_voidable":null'+
                '}]');
            } else {
                throw new SironoServiceException('Unexpected POST url: '+url+' sent to PaymentRestClientMock. Expected: '+expectedUrl);
            }

        } else {
            throw new SironoServiceException('Unexpected method sent to PaymentRestClientMock');
        }
        
        // Check system assert.
        System.assertNotEquals(res, null, 'Should have failed due to res is null.');

        return res;
    }

}
