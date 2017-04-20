/**
 * The Rest client for Sirono web services.
 */

public abstract with sharing class SironoRestClient {

    //TODO make this private once everything is moved to the restclient framework & there is another way to force creds reload
    public static String endpointURL;
    private static final String HTTP_EXCEPTION_MSG = 'An error occurred when calling the Sirono service ' +
            '[METHOD: {0}] [ENDPOINT: {1}] [STATUS_CODE: {2}].';
    private static final String HTTP_DEBUG_MSG = 'Non-200 status returned when calling the Sirono service ' +
            '[METHOD: {0}] [statusCode: {1}] [url: {2}] [responseBody: {3}].';

    private Http http;
    private HttpRequest req;
    private HttpResponse res;
    private String jwtToken;
    private String csrfToken;
    private Set<Integer> validStatuses;

    {
        req = new HttpRequest();
        http = new Http();
        validStatuses = new Set<Integer>{
                RestClientConstants.HTTP_SUCCESS
        };
    }

    /**
     * Configure the request for the GET method.
     *
     * @returns - SironoRestClient The SironoRestClient object, allows chaining.
     */
    public SironoRestClient getRequestor() {
        return this.getRequestor(true);
    }

    /**
     * Configure the request for the GET method.
     *
     * @params - Boolean addDefaults If true, include the default request settings.
     * @returns - SironoRestClient The SironoRestClient object, allows chaining.
     */
    public SironoRestClient getRequestor(Boolean addDefaults) {
        if (addDefaults) {
            addDefaults();
        }

        req.setMethod(RestClientConstants.GET);
        return this;
    }

    /**
     * Configure the request for the DELETE method.
     *
     * @returns - SironoRestClient The SironoRestClient object, allows chaining.
     */
    public SironoRestClient deleteRequestor() {
        addDefaults();
        setSuccessStatuses(new Set<Integer>{
                RestClientConstants.HTTP_DELETED
        });
        req.setMethod(RestClientConstants.REMOVE);
        return this;
    }

    /**
     * Configure the request for the POST method.
     *
     * @returns - SironoRestClient The SironoRestClient object, allows chaining.
     */
    public SironoRestClient postRequestor() {
        return postRequestor(true);
    }

    /**
     * Configure the request for the POST method.
     *
     * @params - Boolean addDefaults If true, include the default request settings.
     * @returns - SironoRestClient The SironoRestClient object, allows chaining.
     */
    public SironoRestClient postRequestor(Boolean addDefaults) {
        if (addDefaults) {
            addDefaults();
        }
        setSuccessStatuses(new Set<Integer>{
                RestClientConstants.HTTP_CREATED, RestClientConstants.HTTP_SUCCESS
        });
        req.setMethod(RestClientConstants.POST);
        return this;
    }

    /**
     * Configure the request for the PUT method.
     *
     * @returns - SironoRestClient The SironoRestClient object, allows chaining.
     */
    public SironoRestClient putRequestor() {
        req.setMethod(RestClientConstants.PUT);
        return this;
    }

    /**
     * Set a header on the request.
     *
     * @param - String key The header key value.
     * @param - String value The value to set for the header.
     * @returns - SironoRestClient The SironoRestClient object, allows chaining.
     */
    public SironoRestClient header(String key, String value) {
        req.setHeader(key, value);
        return this;
    }

    /**
     * Set a request body on the request.
     *
     * @param String body The value to set for the request body.
     * @returns - SironoRestClient The SironoRestClient object, allows chaining.
     */
    public SironoRestClient body(String body) {
        req.setBody(body);
        return this;
    }

    /**
     * Set a timeout on the request.
     *
     * @param Integer timeout The request timeout value.
     * @returns - SironoRestClient The SironoRestClient object, allows chaining.
     */
    public SironoRestClient timeout(Integer timeout) {
        req.setTimeout(timeout);
        return this;
    }

    /**
     * Set the url to be called by the request.
     *
     * @param - String key The key used to lookup the URL from the URLs map.
     * @param - List<String> props Any property that should be used to update the url.
     * @returns - SironoRestClient The SironoRestClient object, allows chaining.
     */
    public SironoRestClient url(String key, List<String> props) {
        String urlString = String.format(this.getUrls().get(key), props);
        return url(urlString);
    }

    /**
     * Set the url to be called by the reqeust.
     *
     * @param - String url The full url to be called.
     * @returns - SironoRestClient The SironoRestClient object, allows chaining.
     */
    public SironoRestClient url(String urlString) {
        req.setEndpoint(urlString);
        return this;
    }

    /**
     * Set the acceptable status codes that can be returned from the call.
     *
     * @param - Set<Integer> statuses A set of status codes that indicate a valid response.  The default acceptable
     * value is a 200.
     * @returns - SironoRestClient The SironoRestClient object, allows chaining.
     */
    public SironoRestClient setSuccessStatuses(Set<Integer> statuses) {
        if (validStatuses != null && validStatuses.size() != 0) {
            validStatuses = statuses;
        }

        return this;
    }

    /**
     * Execute the HttpRequest.
     *
     * @returns - HttpResponse The response from the reqeust.
     */
    public HttpResponse call() {
        try {

            res = http.send(req);

            if (!validStatuses.contains(res.getStatusCode())) {
                logFailedRequest();
                List<String> errors = processFailedResponse(res.getBody());
                throw new SironoServiceException(errors);
            }
        } catch (SironoServiceException e) {
            // If we get a Service exception just rethrow
            throw e;
        } catch (Exception e) {
            System.debug('Exception encountered when calling Sirono service: ' + e.getMessage());
            System.debug('>>>>>req.method: '+req.getMethod());
            System.debug('>>>>>req.endpoint: '+req.getEndpoint());
            System.debug('>>>>>req.Headers - '+RestClientConstants.AUTHORIZATION+': '+req.getHeader(RestClientConstants.AUTHORIZATION)+' '+RestClientConstants.CONTENT_TYPE+': '+req.getHeader(RestClientConstants.CONTENT_TYPE));
            System.debug('>>>>>req.body: '+req.getBody());

            String message = String.format(HTTP_EXCEPTION_MSG, new String[]{
                    req.getMethod(),
                    req.getEndpoint(),
                    String.valueOf(res.getStatusCode())
            });
            throw new SironoServiceException(new String[]{
                    message
            });
        }
        return res;
    }

    /**
     * Method to be implements by each extending class in order to provide the list of URLs available for the web service.
     */
    abstract Map<String, String> getUrls();

    /**
     * Utility method for getting the response body returned from the call.
     *
     * @returns - String the response body.
     */
    public String getResponseBody() {
        checkResponse();
        return res.getBody();
    }

    /**
     * Utility method for getting the status code returned from the call.
     *
     * @returns - Integer The status code from the exectued call.
     */
    public Integer getStatusCode() {
        checkResponse();
        return res.getStatusCode();
    }

    /**
     * Utility for adding the default headers, compression & timeout to a request.
     */
    private void addDefaults() {
        req.setHeader(RestClientConstants.AUTHORIZATION, getJwtHeaderValue());
        req.setHeader(RestClientConstants.CONTENT_TYPE, RestClientConstants.APPLICATION_JSON);
        req.setTimeout(RestClientConstants.DEFAULT_TIMEOUT);
    }

    /**
     * Utiltiy to verify that the response is set prior to acting upon it.
     */
    private void checkResponse() {
        if (res == null) {
            throw new SironoServiceException('No response was found for the instance of SironoRestClient');
        }
    }

    /**
     * Get the jwtToken.  It is lazy loaded when requested.
     *
     * @returns - String The JWT token.
     */
    private String getJwt() {
        if (jwtToken == null) {
            jwtToken = new AuthRestClient().getJwtToken();
        }
        return jwtToken;
    }

    /**
     * When a request fails logs out information so that we can debug accordingly.
     */
    private void logFailedRequest() {
        System.debug(String.format(HTTP_DEBUG_MSG, new String[]{
                req.getMethod(),
                String.valueOf(res.getStatusCode()),
                req.getEndpoint(),
                res.getBody()
        }));
    }

    /**
     * Getter for request that allows tests access.
     */
    @TestVisible
    private HttpRequest getRequest() {
        return req;
    }

    /**
     * Utility for getting the value used in the JWT token header.
     *
     * @returns - String The value to be set in the header.
     */
    protected String getJwtHeaderValue() {
        return String.format(RestClientConstants.JWT_HEADER, new String[]{
                getJwt()
        });
    }

    /**
     * Utility for getting the CSRF token.
     *
     * @returns - String csrfToken The CSRF Token value.
     */
    protected String getCsrf() {
        if (csrfToken == null) {
            csrfToken = new AuthRestClient().getCsrfToken();
        }
        return csrfToken;
    }

    /**
     * Process the JSON from the responseBody of a failed request and convert to a list of error messages if possible.
     *
     * @param - String jsonString The JSON string from a bad response from the Sirono Server.
     * @returns - List<String> The list of errors parsed from the JSON.  If unable to parse the JSON a JSONException is thrown.
     */
    @TestVisible
    private List<String> processFailedResponse(String jsonString) {
        System.debug('processFailedResponse: '+jsonString);
        JSONParser parser = JSON.createParser(jsonString);
        WrapperBadResponse wrapper;

        // Try the wrapper first with no kind field as those JSON strings will be processed by the other types.
        try {
            wrapper = (WrapperNonFieldErrorArray) parser.readValueAsStrict(WrapperNonFieldErrorArray.class);
            return wrapper.getErrors();
        } catch (JSONException e) {
            System.debug('Not a WrapperNonFieldErrorArray');
        }

        parser = JSON.createParser(jsonString);
        try {
            wrapper = (WrapperError) parser.readValueAs(WrapperError.class);
            return wrapper.getErrors();
        } catch (JSONException e) {
            System.debug('Not a WrapperError');
        }

        parser = JSON.createParser(jsonString);
        try {
            wrapper = (WrapperErrorArray) parser.readValueAs(WrapperErrorArray.class);
            return wrapper.getErrors();
        } catch (JSONException e) {
            System.debug('Not a WrapperErrorArray');
        }

        parser = JSON.createParser(jsonString);
        try {
            wrapper = (WrapperListError) parser.readValueAs(WrapperListError.class);
            return wrapper.getErrors();
        } catch (JSONException e) {
            System.debug('Not a WrapperListError');
        }

        throw new JSONException('Unknown JSON format for failed response. [body: ' + jsonString + ']');
    }

    /**
     *
     * Generally used to ensure that the sironoId (which is numeric) being passed in the url doesn't contain
     * commas as that causes all kinds of grief and pain.
     */
    protected String stripCommas(String val) {
        return (String.isNotBlank(val) ? val.replaceAll(',', '') : val);
    }

    /**
     *
     * Return the given sironoId formatted as a chargegroup absolute URI
     */
    protected String asChargeGroupURL(String chargeGroupId) {
        String cgUrl = String.format(RestClientConstants.CHARGE_GROUP_URLS.get(RestClientConstants.CHARGEGROUP_KEY),
                new String[]{stripCommas(chargeGroupId)
				});

        return resolveBaseURL(cgUrl);
    }

    /**
     *
     * Return the given sironoId formatted as a paymentplan absolute URI
     */
    protected String asPaymentPlanURL(String planId) {
        String ppUrl =  String.format(RestClientConstants.PAYMENT_PLAN_URLS.get(RestClientConstants.PAYMENT_PLAN_KEY), new String[]{
                stripCommas(planId)
        		});

        return resolveBaseURL(ppUrl);
    }

    /**
     *
     * Return the given sironoId formatted as a guarantor absolute URI
     **/
    protected String asGuarantorURL(String guarantorId) {
        String guarantorUrl =  String.format(RestClientConstants.GUARANTOR_URLS.get(RestClientConstants.GUARANTOR_KEY), new String[]{
                stripCommas(guarantorId)
        });

        return resolveBaseURL(guarantorUrl);
    }

    /**
     * Replace the named creds server placeholder with the actual endpointURL from the sirono_server named creds
     */
    protected String resolveBaseURL(String newURL) {
        return newURL.replace(RestClientConstants.SIRONO_BASE_URL, getEndpointString());
    }

    /**
     * Get the actual endpointURL from the sirono_server named creds in order to resolve the urls in the JSON payloads
     * @TODO make this protected when everything is using the restclient framework
     */
    public static String getEndpointString() {
        if (endpointURL == null) {
            NamedCredential nc = [
                    SELECT DeveloperName, Endpoint, Id, MasterLabel, PrincipalType
                    FROM NamedCredential
                    WHERE DeveloperName = :RestClientConstants.SIRONO_NAMED_CREDS_ID
                    LIMIT 1
            ];
            endpointURL = nc.Endpoint;
        }
        return endpointURL;
    }


    /**
     * Class used for making authentication based calls against the Sirono Server.
     */
    public class AuthRestClient extends SironoRestClient {

        /**
         * Provides the URL map to the SironoRestClient class for looking up urls.
         */
        @TestVisible
        private override Map<String, String> getUrls() {
            return RestClientConstants.AUTH_URLS;
        }

        /**
         * Get a JWT Token from the Sirono web service.
         */
        public String getJwtToken() {

            // Do not include the default request headers.
            HttpResponse res = postRequestor(false)
                    .url(RestClientConstants.AUTH_URLS.get(RestClientConstants.TOKEN_KEY))
                    .body(RestClientConstants.TOKEN_BODY)
                    .call();

            String responseBody = res.getBody();
            TokenAuthResponse tokenRes = (TokenAuthResponse) JSON.deserializeStrict(responseBody, TokenAuthResponse.class);
            String jwtToken = tokenRes.token;
            return jwtToken;

        }

        /**
         * Get a CSRF Token from the Sirono Service.
         */
        public String getCsrfToken() {
            String csrfToken;
            // Do not include the default request headers.
            HttpResponse res = getRequestor(false)
                    .url(RestClientConstants.AUTH_URLS.get(RestClientConstants.CSRF_KEY))
                    .call();

            String responseBody = res.getBody();

            if (responseBody.indexOf(RestClientConstants.CSRF_BODY_KEY) > 0) {
                Integer startIndex = responseBody.indexOf(RestClientConstants.CSRF_BODY_KEY) + RestClientConstants.CSRF_BODY_KEY.length();
                csrfToken = responseBody.substring(startIndex, responseBody.indexOf('\'', startIndex));
            }

            return csrfToken;
        }

    }

    /**
     * Used for deserializing the JSON returned from the getJwtToken Call.
     */
    private class TokenAuthResponse {
        public String token { get; set; }
    }

}
