/*
* @author Sirono
* @version 1.0.1
* @Date: 05-23-2016
*/

public with sharing class PaymentPlanGoodStanding {
   /* public String username {get; set;}
    public String password {get; set;}
    public String guarantorId {get; set;}
    public String paymentPlanId {get; set;}
    public String paymentPlanExtId {get; set;}*/

    //Constructor  initializing member variables
    public PaymentPlanGoodStanding() {
       /* username = PayStaffWSUtill.un;
        password = PayStaffWSUtill.pw;
        guarantorId = null;
        paymentPlanId = null;
        paymentPlanExtId = null;

        if (Apexpages.currentPage().getParameters().containsKey('guarantorId')) {
            guarantorId = Apexpages.currentPage().getParameters().get('guarantorId');
        }
        if (Apexpages.currentPage().getParameters().containsKey('paymentPlanId')) {
            paymentPlanId = Apexpages.currentPage().getParameters().get('paymentPlanId');
        }
        if (Apexpages.currentPage().getParameters().containsKey('paymentPlanExtId')) {
            paymentPlanExtId = Apexpages.currentPage().getParameters().get('paymentPlanExtId');
        }*/
    }
	/*
    //private method returns a boolean value 
    private Boolean isEmpty(String str) {
        return (str == null || str.trim().equals(''));
    }

    //Mohan Kumar 08-01-2016: Ticket # 06638016 - Updated the QueryString parameter value to fix the "URL No Longer Exists" error.
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

    //Controller Method
    public void doSubmit() {
        try {
            if (!isEmpty(paymentPlanExtId)) {
                String jwtToken = PayStaffWSUtill.getJWTToken(username, password);
                String csrfToken = PayStaffWSUtill.getCSRFToken();
                if (csrfToken != null && jwtToken != null) {
                    doPaymentPlanGoodStanding(csrfToken, jwtToken);
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
    * Mohan Kumar 08-02-2016: Ticket # 06638015 - Updated the request parameter value to send
    * the Sirono External ID and NOT salesforce record Id.
    *
    private void doPaymentPlanGoodStanding(String csrfToken, String jwtToken) {
        String requestData = '{"csrfmiddlewaretoken":"' + csrfToken + '"}';
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        String responseBody;
        req.setMethod('POST');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/paymentplan/' +
                PayStaffWSUtill.trimCommas(paymentPlanExtId) + '/unset_delinquent/');
        req.setBody(requestData);

        try {
            res = http.send(req);
            responseBody = res.getBody();

            if (Test.IsRunningTest()) {
                TestUtility.generateException();
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'PROCESS PAYMENT EXCEPTION RESPONSE : ' + res.toString()
                            + '  RESPONSE BODY::' + responseBody + ' EXCEPTION:: ' + e.getMessage()));
        }

        if (res.getStatusCode() != null && res.getStatusCode() == 200) {
            parseResponse(responseBody);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'successfully completed.'));
        } else {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'CSRF_Token : '+ csrfToken));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'JWT_Token : '+ jwtToken));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody));
        }
    }
    
    /*
    * 09-19-2016: Viraj Rana - Tracker # 129177827
    *  Call this method to test
    *
    Public void doTesting() {
        String str = PaymentPlanJSONParsing.testResponse();
        parseResponse(str);
    }
    
    /*
    * 09-19-2016: Viraj Rana - Tracker # 129177827
    * parse the Response 
    * update the Payment Plan object with the data provided
    *
    Public void parseResponse(String jsonStr) {
        PaymentPlanJSONParsing.PaymentPlanWrapper objPaymentPlanWrapper;
        objPaymentPlanWrapper = PaymentPlanJSONParsing.createPaymentPlanRecord(jsonStr, guarantorId,
                paymentPlanExtId, null);
        test__c paymentPlanObj = objPaymentPlanWrapper.paymentPlanRecord;
        upsert paymentPlanObj;
    }*/
}