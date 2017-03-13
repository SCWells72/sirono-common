/*
* @author: Sirono
* @version 1.0.1
* @Date: 05-20-2016
* 08-16-2016: launch Add to Payment Plan from contact Guarantor record 
* Ticket # 06638015 - Updated the request parameter value to send the Sirono External ID and NOT salesforce record Id.
* 08-01-2016: Ticket # 06638016 - Updated the QueryString parameter value to fix the "URL No Longer Exists" error.
* 
*/

public with sharing class AddToPaymentPlan {
    public String username {get; set;}
    public String password {get; set;}
    public String guarantorRecordId {get; set;}
    public Boolean chargeGroupsSelected {get; set;}
    public String guarantorId {get; set;}
    public String guarantorName {get; set;}
    public String chargeGroupId {get; set;}
    public String paymentPlanId {get; set;}
    public String paymentPlanExtId {get; set;}
    public List<ChargeGroupWrapper> chrageGroupList {get; set;}
	
    // Constructor of a class and initialize the variables.
    public AddToPaymentPlan() {
        username = PayStaffWSUtill.un;
        password = PayStaffWSUtill.pw;
        chargeGroupsSelected = false;
        chrageGroupList = new List<ChargeGroupWrapper>();
        guarantorName = '';
        paymentPlanExtId = null;
        paymentPlanId = null;

        if (Apexpages.currentPage().getParameters().containsKey('guarantorId')) {
            guarantorRecordId = Apexpages.currentPage().getParameters().get('guarantorId');
        }
        if (Apexpages.currentPage().getParameters().containsKey('paymentPlanExtId')) {
            paymentPlanExtId = Apexpages.currentPage().getParameters().get('paymentPlanExtId');
        }
        if (Apexpages.currentPage().getParameters().containsKey('paymentPlanId')) {
            paymentPlanId = Apexpages.currentPage().getParameters().get('paymentPlanId');
        }

        if (guarantorRecordId != null) {
            Contact gc = PayStaffWSUtill.fetchGuarantorFilterCGByAcctSubStatus(guarantorRecordId, PayStaffWSUtill.CGConstraints);
            guarantorName = PayStaffWSUtill.fetchGuarantorName(gc);
            guarantorId = PayStaffWSUtill.fetchGuarantorId(gc);
            //chrageGroupList = PayStaffWSUtill.fetchChargeGroupList(gc);
            for (ChargeGroupWrapper cgw : PayStaffWSUtill.fetchChargeGroupList(gc)) {
                if (cgw.cg.Active__c && cgw.cg.Balance__c != 0) {
                    chrageGroupList.add(cgw);
                }
            }
            chargeGroupId = '';
        }

        //Mohan Kumar 08-16-2016: launch Add to Payment Plan from contact Guarantor record 
        if (String.isBlank(paymentPlanExtId)) {
            paymentPlanExtId = getActivePaymentPlan(guarantorRecordId);
            if (String.isBlank(paymentPlanExtId)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,
                        'No active Payment Plan exist for this Guarantor. Please click Cancel to go previous page.'));
            }
        }
    }
    
    /*Mohan Kumar 08-01-2016: Ticket # 06638016
    * Updated the QueryString parameter value to fix the "URL No Longer Exists" error.
    */
    public Pagereference cancel() {
        Pagereference pg = null;
        if (!isEmpty(paymentPlanId)) {
            pg = new Pagereference('/' + paymentPlanId);
        } else if (!isEmpty(guarantorRecordId)) {
            pg = new Pagereference('/' + guarantorRecordId);
        } else {
            pg = new Pagereference('/home/home.jsp');
        }
        pg.setRedirect(true);
        return pg;
    }

    //Check Charge group is selected or not.
    public Pagereference doNext() {
        chargeGroupsSelected = false;
        chargeGroupId = PayStaffWSUtill.fetchChargeGroupIds(chrageGroupList);
        if (!isEmpty(chargeGroupId)) {
            chargeGroupsSelected = true;
        }/*else {
            chargeGroupsSelected = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                                    'Please select atleast one Charge Group'));
        }*/
        return null;
    }

    //Check String is empty or not
    private Boolean isEmpty(String str) {
        return (str == null || str.trim().equals(''));
    }

    //Get the Active Payment plan id
    private String getActivePaymentPlan(String guarantorRecordId) {
        String ppId;
        List<Payment_Plan__c> activePaymentPlans = [
                Select Id, Sirono_ID__c
                From Payment_Plan__c
                Where Active__c = true
                and Sirono_ID__c != null
                and Guarantor__c = :guarantorRecordId
                limit 1
        ];
        if (activePaymentPlans.size() > 0) ppId = activePaymentPlans[0].Sirono_ID__c.format();
        return ppId;
    }

    //call addToPaymentPlanCall and send the request to end point.
    public void submit() {
        try {
            if (!isEmpty(paymentPlanExtId) && !isEmpty(guarantorId) && !isEmpty(chargeGroupId)) {
                String jwtToken = PayStaffWSUtill.getJWTToken(username, password);
                String csrfToken = PayStaffWSUtill.getCSRFToken();
                if (csrfToken != null && jwtToken != null) {
                    addToPaymentPlanCall(csrfToken, jwtToken);
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                        'Please provide all details.'));
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
    
    /*Mohan Kumar 2016-08-02: Ticket # 06638015
    * Updated the request parameter value to send the Sirono External ID and NOT salesforce record Id.
    */
    private void addToPaymentPlanCall(String csrfToken, String jwtToken) {
        String requestData = '{"csrfmiddlewaretoken":"' + csrfToken + '",' +
                '"chargegroups": ' + PayStaffWSUtill.buildChargeGroupsURL(chargeGroupId) + '}';

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        Http http = new Http();
        String responseBody;

        req.setMethod('POST');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/paymentplan/'
                + PayStaffWSUtill.trimCommas(paymentPlanExtId) + '/add_chargegroups/');
        req.setTimeout(120000);
        req.setBody(requestData);

        try {
            res = http.send(req);
            responseBody = res.getBody();

            if (Test.isRunningTest()) {
                TestUtility.generateException();
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'PROCESS PAYMENT EXCEPTION RESPONSE : ' + res.toString() +
                            '  RESPONSE BODY::' + responseBody + ' EXCEPTION:: '
                            + e.getMessage()));
        }

        if (res.getStatusCode() != null && res.getStatusCode() == 200) {
            callPaymentPlanRequest(csrfToken, jwtToken);
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'RESPONSE : ' + res.toString() +
                            '  RESPONSE BODY::' + responseBody));
        }
    }
    
    /*
    * 09-20-2016: Viraj Rana 
    *  Call the Web Service to get the request and parse the response 
    */
    private void callPaymentPlanRequest(String csrfToken, String jwtToken) {
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        Http http = new Http();
        String responseBody;

        req.setMethod('GET');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/paymentplan/'
                + PayStaffWSUtill.trimCommas(paymentPlanExtId) + '/');
        req.setTimeout(120000);
        try {
            res = http.send(req);
            responseBody = res.getBody();

            if (Test.isRunningTest()) {
                res.setStatusCode(TestUtility.statusCode2);
                TestUtility.generateException();
            }
        } catch (Exception e) {

        }
        if (res.getStatusCode() != null && res.getStatusCode() == 200) {
            parseResponse(responseBody);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,
                    'Added Successfully!'));
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'RESPONSE : ' + res.toString() +
                            '  RESPONSE BODY::' + responseBody));
        }
    }
    
    /*
    * 09-16-2016: Viraj Rana 
    *  Call this method to test
    */
    Public void doTesting() {
        String str = PaymentPlanJSONParsing.testResponse();
        parseResponse(str);
    }
    
    /*
    * 09-16-2016: Viraj Rana - Tracker # 129071767
    *  parse the Response 
    * Update the substatus to 'Payment Plan' on all the newly added charge groups connected to the paymentPlan
    * Update the Payment Plan lookup on the newly added Charge Groups to point to the Payment Plan
    */
    Public void parseResponse(String jsonStr) {

        PaymentPlanJSONParsing.PaymentPlanWrapper objPaymentPlanWrapper;
        objPaymentPlanWrapper = PaymentPlanJSONParsing.createPaymentPlanRecord(jsonStr, guarantorRecordId,
                null, chargeGroupId);
        Payment_Plan__c paymentPlanObj = objPaymentPlanWrapper.paymentPlanRecord;

	if (PaymentPlanSecurityContext.UPSERT_CONTEXT.actionAllowed()) {
	    UPSERT paymentPlanObj;
	}

        List<Charge_Group__c> lstCG = new List<Charge_Group__c>();
        lstCG = objPaymentPlanWrapper.chargeGroupRecords;
        for (Charge_Group__c cg : lstCG) {
            cg.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
            cg.Payment_Plan__c = paymentPlanObj.Id;
        }
	if (ChargeGroupSecurityContext.UPDATE_CONTEXT.actionAllowed()) {
	    UPDATE lstCG;
    	}
    }
}