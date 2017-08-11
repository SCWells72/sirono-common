/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * HttpCalloutMock implementor that will return fail all requests.
 */
@IsTest
public class RestClientFailMock implements HttpCalloutMock {
    private String body = '';

    public RestClientFailMock(String responseBody) {
        body = responseBody;
    }

    public HttpResponse respond(HttpRequest req) {

        HttpResponse res = new HttpResponse();
        res.setStatusCode(RestClientConstants.HTTP_BAD_REQUEST);
        res.setBody(body);

        // Check system assert.
        System.assertNotEquals(res, null, 'Should have failed due to res is null.');

        return res;
    }
}