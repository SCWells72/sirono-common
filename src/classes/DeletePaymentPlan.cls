/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class DeletePaymentPlan {

    public String guarantorId { get; set; }
    public String paymentPlanId { get; set; }
    public String paymentPlanExtId { get; set; }
    private List<Charge_Group__c> lstCG = new List<Charge_Group__c>();
    private Payment_Plan__c paymentPlanObj = new Payment_Plan__c();
    public Boolean blnHasError = true;
    public Boolean blnHasFirstRequest = true;
    // Constructor of a class and initialize the variables.
    public DeletePaymentPlan() {

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

    //Check String is empty or not
    private Boolean isEmpty(String str) {
        return (str == null || str.trim().equals(''));
    }

    /*Mohan Kumar 08-01-2016: Ticket # 06638016 - 
     *Updated the QueryString parameter value to fix the "URL No Longer Exists" error.
     */
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

    //call doDeletePaymentPlan and send the request to end point.
    public void doSubmit() {
        try {
            if (!isEmpty(paymentPlanExtId)) {
                String jwtToken = new SironoRestClient.AuthRestClient().getJwtToken();
                String csrfToken = new SironoRestClient.AuthRestClient().getCsrfToken();
                if (csrfToken != null && jwtToken != null) {
                    callPaymentPlanRequest(csrfToken, jwtToken);
                    //doDeletePaymentPlan(csrfToken, jwtToken);
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
    * 09-22-2016: Viraj Rana - Tracker #129177479
    *  Call the paymentplan Web Service to get the paymentplan information.
    */
    private void callPaymentPlanRequest(String csrfToken, String jwtToken) {
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        Http http = new Http();
        String responseBody;

        req.setMethod('GET');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(RestClientConstants.SIRONO_BASE_URL + '/paystaff/api/paymentplan/'
            + PayStaffWSUtill.trimCommas(paymentPlanExtId) + '/');
        req.setTimeout(120000);
        try {
            res = http.send(req);
            responseBody = res.getBody();
            //system.debug('Payment Plan Response : ' + responseBody);

            if (Test.isRunningTest()) {
                res.setStatusCode(TestUtility.statusCode2);
                TestUtility.generateException();
            }
        } catch (Exception e) {

        }
        if (res.getStatusCode() != null && res.getStatusCode() == 200) {

            parsePaymentPlanResponse(responseBody, csrfToken, jwtToken);

        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'RESPONSE : ' + res.toString() +
                    '  RESPONSE BODY::' + responseBody));
        }
    }
    
    /*
    * 09-22-2016: Viraj Rana - Tracker # 129177479    
    * parse the Payment Plan JSON and Make a new request to get the charge group detailsyment Plan
    */
    private void parsePaymentPlanResponse(String jsonStr, String csrfToken, String jwtToken) {

        PaymentPlanJSONParsing.PaymentPlanWrapper objPaymentPlanWrapper;
        objPaymentPlanWrapper = PaymentPlanJSONParsing.createPaymentPlanRecord(jsonStr, guarantorId,
            null, null);

        paymentPlanObj = new Payment_Plan__c();
        paymentPlanObj = objPaymentPlanWrapper.paymentPlanRecord;
        paymentPlanObj.Active__c = false;
        paymentPlanObj.Cancellation_Date__c = System.today();

        if (blnHasFirstRequest) {
            lstCG = new List<Charge_Group__c>();
            lstCG = objPaymentPlanWrapper.chargeGroupRecords;
        }

        if (blnHasError && blnHasFirstRequest) {
            doDeletePaymentPlan(csrfToken, jwtToken);
        }
    }
    
    /*
    * 09-22-2016: Viraj Rana - Tracker # 129177479
    * make a Charge group Reqeuest to get the chargeGroupInformation
    */
    private void callChargeGroupRequest(String chargeGroupId, String jwtToken, Charge_Group__c cg) {
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        Http http = new Http();
        String responseBody;

        req.setMethod('GET');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(RestClientConstants.SIRONO_BASE_URL + '/paystaff/api/chargegroups/'
            + PayStaffWSUtill.trimCommas(chargeGroupId) + '/');

        req.setTimeout(120000);
        try {
            res = http.send(req);
            responseBody = res.getBody();
            //system.debug('Charge Group ResponseBody : ' + responseBody);
            if (Test.isRunningTest()) {
                res.setStatusCode(TestUtility.statusCode3);
                TestUtility.generateException();
            }
        } catch (Exception e) {
            //blnHasError = false;
        }
        if (res.getStatusCode() != null && res.getStatusCode() == 200) {

            parseChargeGroupResponse(responseBody, cg);
        } else {

            blnHasError = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'RESPONSE : ' + res.toString() +
                    '  RESPONSE BODY::' + responseBody));
        }
    }
    
    
    /*
    * 09-22-2016: Viraj Rana - Tracker # 129177479
    * parse the chargroup json and update the sub status
    * 10-12-2016: Viraj Rana - Tracker # 129177479
    * Update the Account_Sub_Status__c and Account_Status__c.
    */
    private void parseChargeGroupResponse(String responseBody, Charge_Group__c cg) {
        ChargeGroupJSONParser objChargeGroup = ChargeGroupJSONParser.parse(responseBody);
        cg.Account_Sub_Status__c = objChargeGroup.account_sub_status;
        cg.Account_Status__c = objChargeGroup.account_status;
        cg.Payment_Plan__c = null;
    }
    
    
    /*Mohan Kumar 08-02-2016: Ticket # 06638015 - 
     *Updated the request parameter value to send the Sirono External ID and NOT salesforce record Id.
     */
    private void doDeletePaymentPlan(String csrfToken, String jwtToken) {
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        Http http = new Http();
        String responseBody;

        req.setMethod('DELETE');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(RestClientConstants.SIRONO_BASE_URL + '/paystaff/api/paymentplan/' +
            PayStaffWSUtill.trimCommas(paymentPlanExtId) + '/');

        try {
            res = http.send(req);
            responseBody = res.getBody();
            if (Test.isRunningTest()) {
                res.setStatusCode(TestUtility.statusCode4);
                TestUtility.generateException();
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'PROCESS PAYMENT EXCEPTION RESPONSE : ' + res.toString() +
                    '  RESPONSE BODY::' + responseBody +
                    ' EXCEPTION:: ' + e.getMessage()));
        }

        if (res.getStatusCode() != null && res.getStatusCode() == 204) {
            blnHasFirstRequest = false;

            callPaymentPlanRequest(csrfToken, jwtToken);

            for (Charge_Group__c cg : lstCG) {
                callChargeGroupRequest(String.valueOf(cg.Sirono_ID__c), jwtToken, cg);
            }

            if (blnHasError == true) {
                if (PaymentPlanSecurityContext.DP_UPDATE_CONTEXT.actionAllowed()) {
                    update paymentPlanObj;
                }
                ChargeGroupService.updateChargeGroupsWithStatus(lstCG);
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,
                'Payment plan was successfully cancelled.'));
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'RESPONSE : ' + res.toString() +
                    '  RESPONSE BODY::' + responseBody));
        }
    }
}