/*
* @author Sirono
* @version 1.0.1
* @Date: 05-23-2016
* @SkipPaymentPlan Class for the Skip Payment.
*
* Mohan Kumar 08-17-2016: (127324647) Validate the Payment is of type Automatic to process 
* the skip payment else return a message user
*
* Sirono 08-24-2016: (127945719) Text and dates are correct in the message.
*
* Mohan Kumar 08-01-2016: Ticket # 06638016 - Updated the QueryString parameter value 
* to fix the "URL No Longer Exists" error.
*
* Mohan Kumar 08-02-2016: Ticket # 06638015 - Updated the request parameter value to 
* send the Sirono External ID and NOT salesforce record Id.
*
* Sirono 08-29-2016: 127326579 when Record Saved Successfully set isSuccess parameter for redirect.
*/

public with sharing class SkipPaymentPlan {
    public String username {get; set;}
    public String password {get; set;}
    public String guarantorId {get; set;}
    public String paymentPlanId {get; set;}
    public String messageToShow {get; set;}
    public String paymentPlanExtId {get; set;}
    public Boolean isAutomatic {get; set;}
    public Boolean isSuccess {get; set;}

    public SkipPaymentPlan() {
        username = PayStaffWSUtill.un;
        password = PayStaffWSUtill.pw;
        guarantorId = null;
        paymentPlanId = null;
        paymentPlanExtId = null;
        messageToShow = '';
        isAutomatic = false;
        isSuccess = false;
        if (Apexpages.currentPage().getParameters().containsKey('guarantorId')) {
            guarantorId = Apexpages.currentPage().getParameters().get('guarantorId');
        }
        if (Apexpages.currentPage().getParameters().containsKey('paymentPlanId')) {
            paymentPlanId = Apexpages.currentPage().getParameters().get('paymentPlanId');
        }
        if (Apexpages.currentPage().getParameters().containsKey('paymentPlanExtId')) {
            paymentPlanExtId = Apexpages.currentPage().getParameters().get('paymentPlanExtId');
        }

        validatePaymentPlanType();
    }

    /*
    * Mohan Kumar 08-17-2016: (127324647) Validate the Payment is of type Automatic 
    * to process the skip payment else return a message user
    */
    private void validatePaymentPlanType() {
        List<Payment_Plan__c> automaticPaymentPlans = [
                Select Id, Sirono_ID__c, Next_Payment_Date__c, NextPaymentDate__c
                From Payment_Plan__c
                Where Id = :paymentPlanId and Plan_Type__c = 'Automatic'
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
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,
                    'Sorry, the Skip Payment Plan is not of type Automatic. ' +
                            'Please click Cancel to go previous page.'));
        }
    }

    private Boolean isEmpty(String str) {
        return (str == null || str.trim().equals(''));
    }

    /*
    * Mohan Kumar 08-01-2016: Ticket # 06638016 - Updated the QueryString parameter value
    * to fix the "URL No Longer Exists" error.
    */
    public Pagereference cancel() {
        Pagereference pg = null;
        if (!isEmpty(paymentPlanId)) {
            pg = new Pagereference('/' + paymentPlanId);
        } else if (!isEmpty(guarantorId)) {
            pg = new Pagereference('/' + guarantorId);
        } else {
            pg = new Pagereference('/home/home.jsp');
        }
        pg.setRedirect(true);
        return pg;
    }

    public void doSubmit() {
        try {
            if (!isEmpty(paymentPlanExtId)) {
                String jwtToken = PayStaffWSUtill.getJWTToken(username, password);
                String csrfToken = PayStaffWSUtill.getCSRFToken();
                if (csrfToken != null && jwtToken != null) {
                    doSkipPaymentPlan(csrfToken, jwtToken);
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                        'Payment Plan Id is missing.'));
                if (Test.IsRunningTest()) {
                    TestUtility.generateException();
                }
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'ERROR: ' + e.getMessage()));
        }
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
        req.setEndpoint(SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/paymentplan/' +
                PayStaffWSUtill.trimCommas(paymentPlanExtId) + '/skip_payment/');
        req.setBody(requestData);
        System.debug('req: ' + req);
        System.debug('req: ' + requestData);
        try {
            res = http.send(req);
            responseBody = res.getBody();
            if (test.isRunningTest()) {
                TestUtility.generateException();
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
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
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'Skipped Successfully.'));
        } else {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'CSRF_Token : '+ csrfToken));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'JWT_Token : '+ jwtToken));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody));
        }
    }
    
   
    /*
    * 09-22-2016: Viraj Rana 
    *  Call this method to test
    */
    Public void doTesting() {
        String str = PaymentPlanJSONParsing.testResponse();
        parseResponse(str);
    }
    
    /*
    * 09-22-2016: Sirono - Tracker # 129177663
    *  parse the Response update a payment plan record.
    */
    Public void parseResponse(String jsonStr) {

        PaymentPlanJSONParsing.PaymentPlanWrapper objPaymentPlanWrapper;
        objPaymentPlanWrapper = PaymentPlanJSONParsing.createPaymentPlanRecord(jsonStr, guarantorId,
                null, null);
        Payment_Plan__c paymentPlanObj = objPaymentPlanWrapper.paymentPlanRecord; 
        upsert paymentPlanObj;
    }
}