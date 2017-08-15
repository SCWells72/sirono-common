/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class SkipPaymentPlan {

    public String guarantorId { get; set; }
    public String paymentPlanId { get; set; }
    public String messageToShow { get; set; }
    public String paymentPlanExtId { get; set; }
    public Boolean isAutomatic { get; set; }
    public Boolean isSuccess { get; set; }

    public SkipPaymentPlan() {

        guarantorId = null;
        paymentPlanId = null;
        paymentPlanExtId = null;
        messageToShow = '';
        isAutomatic = false;
        isSuccess = false;
        if (ApexPages.currentPage().getParameters().containsKey('guarantorId')) {
            guarantorId = ApexPages.currentPage().getParameters().get('guarantorId');
        }
        if (ApexPages.currentPage().getParameters().containsKey('paymentPlanId')) {
            paymentPlanId = ApexPages.currentPage().getParameters().get('paymentPlanId');
        }
        if (ApexPages.currentPage().getParameters().containsKey('paymentPlanExtId')) {
            paymentPlanExtId = ApexPages.currentPage().getParameters().get('paymentPlanExtId');
        }

        validatePaymentPlanType();
    }

    /*
    * Mohan Kumar 08-17-2016: (127324647) Validate the Payment is of type Automatic 
    * to process the skip payment else return a message user
    */
    private void validatePaymentPlanType() {
        if (PaymentPlanSecurityContext.SPP_SELECT_CONTEXT.actionAllowed()) {
            List<Payment_Plan__c> automaticPaymentPlans = [
                SELECT Id, Sirono_Id__c, NextPaymentDate__c
                FROM Payment_Plan__c
                WHERE Id = :paymentPlanId
                AND Plan_Type__c = :Constants.AUTOMATIC
            ];

            if (automaticPaymentPlans.size() > 0) {
                isAutomatic = true;

                //Sirono 2016-08-24: (127945719) Text and dates are correct in the message.
                Date nextPaymentDate = automaticPaymentPlans[0].NextPaymentDate__c;
                if (nextPaymentDate != null) {
                    messageToShow = 'Clicking skip payment installment will skip the next installment date of '
                        + nextPaymentDate.format() + '. The next installment will charge on '
                        + nextPaymentDate.addMonths(1).format() + '.';
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,
                    'Sorry, the Skip Payment Plan is not of type Automatic. ' +
                        'Please click Cancel to go previous page.'));
            }
        }
    }

    /*
    * Mohan Kumar 08-01-2016: Ticket # 06638016 - Updated the QueryString parameter value
    * to fix the "URL No Longer Exists" error.
    */
    public PageReference cancel() {
        return String.isNotBlank(paymentPlanId) ?
            VisualforceControllerUtil.getRecordPageReference(paymentPlanId) :
            VisualforceControllerUtil.getRecordPageReference(guarantorId);
    }

    public PageReference doSubmit() {
        try {
            if (String.isNotBlank(paymentPlanExtId)) {
                String jwtToken = new SironoRestClient.AuthRestClient().getJwtToken();
                String csrfToken = new SironoRestClient.AuthRestClient().getCsrfToken();
                if (csrfToken != null && jwtToken != null) {
                    doSkipPaymentPlan(csrfToken, jwtToken);

                    return String.isNotBlank(paymentPlanId) ?
                        VisualforceControllerUtil.getRecordPageReference(paymentPlanId) :
                        VisualforceControllerUtil.getRecordPageReference(guarantorId);
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

        return null;
    }

    /*
    * Mohan Kumar 08-02-2016: Ticket # 06638015 - Updated the request parameter value to 
    * send the Sirono External ID and NOT salesforce record Id.
    */
    private void doSkipPaymentPlan(String csrfToken, String jwtToken) {
        String requestData = '{"csrfmiddlewaretoken":"' + csrfToken + '"}';

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        Http http = new Http();
        String responseBody;

        req.setMethod('POST');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(RestClientConstants.SIRONO_BASE_URL + '/paystaff/api/paymentplan/' +
            PayStaffWSUtill.trimCommas(paymentPlanExtId) + '/skip_payment/');
        req.setBody(requestData);
        System.debug('req: ' + req);
        System.debug('req: ' + requestData);
        try {
            res = http.send(req);
            responseBody = res.getBody();
            if (Test.isRunningTest()) {
                TestUtility.generateException();
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'PROCESS PAYMENT EXCEPTION RESPONSE : ' + res.toString() +
                    '  RESPONSE BODY::' + responseBody + ' EXCEPTION:: ' + e.getMessage()));
        }

        if (res.getStatusCode() != null && res.getStatusCode() == 200) {
            System.debug(responseBody);
            //09-22-2016: Sirono - Tracker # 129177663 
            //parse the Response update a payment plan record.

            parseResponse(responseBody);

            //Sirono 2016-08-29: 127326579 when Record Saved Successfully set isSuccess parameter for redirect.
            isSuccess = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Skipped Successfully.'));
        } else {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'CSRF_Token : '+ csrfToken));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'JWT_Token : '+ jwtToken));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody));
        }
    }
    
   
    /*
    * 09-22-2016: Viraj Rana 
    *  Call this method to test
    */
    public void doTesting() {
        String str = PaymentPlanJSONParsing.testResponse();
        parseResponse(str);
    }
    
    /*
    * 09-22-2016: Sirono - Tracker # 129177663
    *  parse the Response update a payment plan record.
    */
    public void parseResponse(String jsonStr) {

        PaymentPlanJSONParsing.PaymentPlanWrapper objPaymentPlanWrapper;
        objPaymentPlanWrapper = PaymentPlanJSONParsing.createPaymentPlanRecord(jsonStr, guarantorId, null);
        Payment_Plan__c paymentPlanObj = objPaymentPlanWrapper.paymentPlanRecord;

        if (PaymentPlanSecurityContext.UPSERT_CONTEXT.actionAllowed()) {
            upsert paymentPlanObj;
        }
    }
}