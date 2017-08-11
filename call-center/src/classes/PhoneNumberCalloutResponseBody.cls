/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Mock Responses to MockCallout that verifies guarantor contact phone numbers- Tracker #127517419
*/
public class PhoneNumberCalloutResponseBody {
    //mock response for mobile phone 
    public static String responseMobile() {
        String body = '{' +
            '   "valid":true,' +
            '   "number":"14158586276",' +
            '   "local_format":"4158586273",' +
            '   "international_format":"+14158586273",' +
            '   "country_prefix":"+1",' +
            '   "country_code":"US",' +
            '   "country_name":"United States of America",' +
            '   "location":"Novato",' +
            '   "carrier":"AT&T Mobility LLC",' +
            '   "line_type":"mobile"' +
            '}';
        return body;
    }

    //mock response for landline phone
    public static String responseLandline() {
        String body = '{' +
            '   "valid":true,' +
            '   "number":"16157187745",' +
            '   "local_format":"6157187745",' +
            '   "international_format":"+16157187745",' +
            '   "country_prefix":"+1",' +
            '   "country_code":"US",' +
            '   "country_name":"United States of America",' +
            '   "location":"Nashville",' +
            '   "carrier":"",' +
            '   "line_type":"landline"' +
            '}';
        return body;
    }

    //mock response for invalid number
    public static String responseInvalid() {

        String body = '{' +
            '   "valid":false,' +
            '   "number":"9781235423",' +
            '   "local_format":"",' +
            '   "international_format":"",' +
            '   "country_prefix":"",' +
            '   "country_code":"",' +
            '   "country_name":"",' +
            '   "location":"",' +
            '   "carrier":"",' +
            '   "line_type":null' +
            '}';
        return body;
    }
}