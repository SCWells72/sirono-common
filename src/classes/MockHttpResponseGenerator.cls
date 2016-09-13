@isTest global class MockHttpResponseGenerator implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {

        if (req.getEndpoint().contains('/paystaff/api/guarantors/') &&
                req.getEndpoint().endsWith('statements/')) {
            // Mock statement urls
            HttpResponse res = new HttpResponse();
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

        return null;
    }
}