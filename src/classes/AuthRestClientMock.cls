/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * AuthRestClientMock class for testing the AuthRestClient service.
 */
@IsTest
public class AuthRestClientMock implements HttpCalloutMock {

    /**
     * Handler for the mocking the Auth endpoints.
     *
     * @params - HttpRequest req The request associated with the call.
     */
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = RestClientMockUtil.handleAuthRequest(req);
        if (req == null) {
            throw new SironoServiceException(String.format('Unexpected method/endpoint in HttpAuthMock [METHOD: {0}] [Endpoint: {1}].',
                    new String[]{
                            req.getMethod(), req.getEndpoint()
                    }));
        }

        return res;
    }

}
