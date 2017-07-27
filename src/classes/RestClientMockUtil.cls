/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Utility class around mocking rest client class in for the HTTP services.
 */
@IsTest
public with sharing class RestClientMockUtil {

    public static final String TOKEN = 'at0ta11yfak3T0ken';
    public static final String CSRF = 'csrfT0kens1s1n';
    public static final String CSRF_BODY = '<html><body>' + RestClientConstants.CSRF_BODY_KEY + CSRF + '\' ></body></html>';

    /**
     * Processes the auth related request and populates a response if the endpoint and method are found.
     *
     * @param - HttpRequest req The http request.
     * @returns - HttpResponse A populated response if a match was found, otherwise null.
     */
    public static HttpResponse handleAuthRequest(HttpRequest req) {
        HttpResponse res;
        Boolean found = false;
        String body = null;

        String method = req.getMethod();
        String url = req.getEndpoint();
        Map<String, String> urls = RestClientConstants.AUTH_URLS;

        if (method == RestClientConstants.GET) {

            if (url.endsWith(urls.get(RestClientConstants.CSRF_KEY).substringAfter(RestClientConstants.SIRONO_BASE_URL))) {
                found = true;
                body = CSRF_BODY;
            }

        } else if (method == RestClientConstants.POST) {

            if (url.endsWith(urls.get(RestClientConstants.TOKEN_KEY).substringAfter(RestClientConstants.SIRONO_BASE_URL))) {
                found = true;
                body = generateTokenBody();
            }

        }

        if (found) {
            res = new HttpResponse();
            res.setStatusCode(RestClientConstants.HTTP_SUCCESS);
            res.setBody(body);
        }

        return res;
    }

    /**
     * Helper method for building urls.
     *
     * @param - String url The url string ready for use with String.format.
     * @param - List<String> props The values to be populated in the url.
     * @returns - String The updated url.
     */
    public static String urlBuilder(String url, List<String> props) {
        return String.format(url, props);
    }

     /**
     * Utility for generating the JSON string returned from a JWT token call.
     */
    private static String generateTokenBody() {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('token', TOKEN);
        gen.writeEndObject();

        return gen.getAsString();
    }

}