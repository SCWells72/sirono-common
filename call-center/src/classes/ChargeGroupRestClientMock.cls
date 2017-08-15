/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Class used to Mock responses from the chargegroups endpoints in Sirono.
 */
@IsTest
public class ChargeGroupRestClientMock implements HttpCalloutMock {

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res;

        // First see if the req matches any of the auth routes
        res = RestClientMockUtil.handleAuthRequest(req);
        if (res != null) {
            return res;
        }

        String method = req.getMethod();
        String url = req.getEndpoint();
        Map<String, String> urls = RestClientConstants.CHARGE_GROUP_URLS;

        res = new HttpResponse();

        System.debug('>>>>>>>> method: ' + method + ' url: ' + url);
        if (method == RestClientConstants.GET) {
            if (url == RestClientMockUtil.urlBuilder(urls.get(RestClientConstants.CHARGEGROUP_KEY), new String[] { RestClientConstants.CHARGE_GROUP_ID })) {
                res.setStatusCode(RestClientConstants.HTTP_SUCCESS);
                res.setHeader('Content-Type', 'application/json');
                res.setBody(getChargeGroupJSONBody());
            } else {
                throw new SironoServiceException('Unexpected GET url sent to ChargeGroupRestClientMock');
            }

        } else if (method == RestClientConstants.POST) {
            String expectedUrl = RestClientMockUtil.urlBuilder(urls.get(RestClientConstants.CHARGEGROUP_KEY), new String[] { RestClientConstants.CHARGE_GROUP_ID });
            if (url == expectedUrl) {
                res.setStatusCode(RestClientConstants.HTTP_SUCCESS);
            } else {
                throw new SironoServiceException('Unexpected POST url: ' + url + ' sent to ChargeGroupRestClientMock. Expected: ' + expectedUrl);
            }

        } else {
            throw new SironoServiceException('Unexpected method sent to ChargeGroupRestClientMock');
        }

        // Check system assert.
        System.assertNotEquals(res, null, 'Should have failed due to res is null.');

        return res;
    }

    public static String getChargeGroupJSONBody() {
        return '{"url":"https://toledo.stage.sirono.com/paystaff/api/chargegroups/' + RestClientConstants.CHARGE_GROUP_ID + '/",' +
            '"account_type":"HB",' +
            '"account_number":"A1424501471",' +
            '"active":true,' +
            '"status":"Third Party Payer",' +
            '"extended_status":"These charges have been submitted to a third party payor for processing",' +
            '"pas_specific_origin_code":"HBO",' +
            '"balance":0,' +
            '"invoice":null,' +
            '"bad_debt_status":false,' +
            '"date_of_service_start":"2014-09-02",' +
            '"date_of_service_end":"2014-09-02",' +
            '"charges_since_paymentplan":false,' +
            '"mapped_location_or_provider":"Fulton County Cardiology Clinic",' +
            '"processed_charges_details":"These services will not be sent to insurance for processing.",' +
            '"patient_data":{"mrn":"A01048800",' +
            '"patient_name":"MICHELE BLEVINS"},' +
            '"guarantor_data":{' +
            '"display_id":"TD571",' +
            '"url":"https://toledo.stage.sirono.com/paystaff/api/guarantors/571/",' +
            '"full_name":"Michele Blevins"' +
            '},' +
            '"services_by_description":{},' +
            '"account_status":"Pending",' +
            '"account_sub_status":"Third Party Payer",' +
            '"paymentplan":null ' +
            '}';
    }

    public static ChargeGroupJSONParser.ChargeGroupJSON getParsedChargeGroup() {
        return ChargeGroupJSONParser.parse(getChargeGroupJSONBody());
    }

}
