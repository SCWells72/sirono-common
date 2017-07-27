/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class PaymentPlanGoodStanding {

    public String guarantorId { get; set; }
    public String paymentPlanId { get; set; }
    public String paymentPlanExtId { get; set; }

    //Constructor  initializing member variables
    public PaymentPlanGoodStanding() {

        guarantorId = null;
        paymentPlanId = null;
        paymentPlanExtId = null;

        if (ApexPages.currentPage().getParameters().containsKey('guarantorId')) {
            guarantorId = ApexPages.currentPage().getParameters().get('guarantorId');
        }
        if (ApexPages.currentPage().getParameters().containsKey('paymentPlanId')) {
            paymentPlanId = ApexPages.currentPage().getParameters().get('paymentPlanId');
        }
        if (ApexPages.currentPage().getParameters().containsKey('paymentPlanExtId')) {
            paymentPlanExtId = ApexPages.currentPage().getParameters().get('paymentPlanExtId');
        }
    }

    //private method returns a boolean value 
    private Boolean isEmpty(String str) {
        return (str == null || str.trim().equals(''));
    }

    //Mohan Kumar 08-01-2016: Ticket # 06638016 - Updated the QueryString parameter value to fix the "URL No Longer Exists" error.
    public PageReference cancel() {
        PageReference pg = null;
        if (!isEmpty(paymentPlanId)) {
            pg = new PageReference('/' + paymentPlanId);
        } else if (!isEmpty(guarantorId)) {
            pg = new PageReference('/' + guarantorId);
        } else {
            pg = new PageReference('/home/home.jsp');
        }
        pg.setRedirect(true);
        return pg;
    }

    //Controller Method
    public void doSubmit() {
        try {
            if (!isEmpty(paymentPlanExtId)) {
                String jwtToken = new SironoRestClient.AuthRestClient().getJwtToken();
                String csrfToken = new SironoRestClient.AuthRestClient().getCsrfToken();
                if (csrfToken != null && jwtToken != null) {
                    doPaymentPlanGoodStanding(csrfToken, jwtToken);
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Payment Plan Id is missing.'));
                if (Test.isRunningTest()) {
                    TestUtility.generateException();
                }
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'ERROR: ' + e.getMessage()));
        }
    }
    
    /*
    * Mohan Kumar 08-02-2016: Ticket # 06638015 - Updated the request parameter value to send
    * the Sirono External ID and NOT salesforce record Id.
    */
    private void doPaymentPlanGoodStanding(String csrfToken, String jwtToken) {
        String requestData = '{"csrfmiddlewaretoken":"' + csrfToken + '"}';
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        String responseBody;
        req.setMethod('POST');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(RestClientConstants.SIRONO_BASE_URL + '/paystaff/api/paymentplan/' +
            PayStaffWSUtill.trimCommas(paymentPlanExtId) + '/unset_delinquent/');
        req.setBody(requestData);

        try {
            res = http.send(req);
            responseBody = res.getBody();

            if (Test.isRunningTest()) {
                TestUtility.generateException();
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'PROCESS PAYMENT EXCEPTION RESPONSE : ' + res.toString()
                    + '  RESPONSE BODY::' + responseBody + ' EXCEPTION:: ' + e.getMessage()));
        }

        if (res.getStatusCode() != null && res.getStatusCode() == 200) {
            parseResponse(responseBody);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'successfully completed.'));
        } else {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'CSRF_Token : '+ csrfToken));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'JWT_Token : '+ jwtToken));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody));
        }
    }
    
    /*
    * 09-19-2016: Viraj Rana - Tracker # 129177827
    *  Call this method to test
    */
    public void doTesting() {
        String str = PaymentPlanJSONParsing.testResponse();
        parseResponse(str);
    }
    
    /*
    * 09-19-2016: Viraj Rana - Tracker # 129177827
    * parse the Response 
    * update the Payment Plan object with the data provided
    */
    public void parseResponse(String jsonStr) {
        PaymentPlanJSONParsing.PaymentPlanWrapper objPaymentPlanWrapper;
        objPaymentPlanWrapper = PaymentPlanJSONParsing.createPaymentPlanRecord(jsonStr, guarantorId,
            paymentPlanExtId, null);
        Payment_Plan__c paymentPlanObj = objPaymentPlanWrapper.paymentPlanRecord;

        if (PaymentPlanSecurityContext.UPSERT_CONTEXT.actionAllowed()) {
            upsert paymentPlanObj;
        }
    }
}