/**
 * Class used for making guarantor calls against the Sirono Rest service.
 */
public with sharing class GuarantorsRestClient extends SironoRestClient {

    /**
     * Provides the URL map to the SironoRestClient class for looking up urls.
     */
    @TestVisible
    private Map<String, String> getUrls() {
        return RestClientConstants.GUARANTOR_URLS;
    }

    /**
     * Get the statemnts for the guarantor from the siroro service.
     *
     * @param - String guarantorId The guarantorId.
     */
    public void getStatements(String guarantorId) {

        getRequestor()
                .url(RestClientConstants.STATEMENTS, new String[]{
                    guarantorId
                })
                .call();

    }
}
