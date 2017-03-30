/*
* @author: Sirono
* @version 1.0.1
* @Date: 05-20-2016
* 08-16-2016: launch Add to Payment Plan from contact Guarantor record 
* Ticket # 06638015 - Updated the request parameter value to send the Sirono External ID and NOT salesforce record Id.
* 08-01-2016: Ticket # 06638016 - Updated the QueryString parameter value to fix the "URL No Longer Exists" error.
* 
*/

public with sharing class AddToPaymentPlanLightning {
    public String username {get; set;}
    public String password {get; set;}
    public String guarantorRecordId {get; set;}
    public Boolean chargeGroupsSelected {get; set;}
    public String guarantorId {get; set;}
    public String guarantorName {get; set;}
    public String chargeGroupId {get; set;}
    public String paymentPlanId {get; set;}
    public String paymentPlanExtId {get; set;}
    public List<ChargeGroupWrapper> chargeGroupList {get; set;}
	  public String errorMessage{get;set;}
	
    // Constructor of a class and initialize the variables.
    public AddToPaymentPlanLightning(String gId) {
        username = PayStaffWSUtillLightning.un;
        password = PayStaffWSUtillLightning.pw;
        chargeGroupsSelected = false;
        chargeGroupList = new List<ChargeGroupWrapper>();
        guarantorName = '';
        errorMessage = '';
        paymentPlanExtId = (Test.isRunningTest() && Apexpages.currentPage().getParameters().containsKey('paymentPlanExtId')) ? Apexpages.currentPage().getParameters().get('paymentPlanExtId') : null;
        paymentPlanId = (Test.isRunningTest() && Apexpages.currentPage().getParameters().containsKey('paymentPlanId')) ? Apexpages.currentPage().getParameters().get('paymentPlanId') : null;

        guarantorRecordId = gId;
        
        if (guarantorRecordId != null) {
            Contact gc = PayStaffWSUtillLightning.fetchGuarantorContactWithCGConstraints(guarantorRecordId);
            guarantorName = PayStaffWSUtillLightning.fetchGuarantorName(gc);
            guarantorId = PayStaffWSUtillLightning.fetchGuarantorId(gc);
            //chargeGroupList = PayStaffWSUtillLightning.fetchChargeGroupList(gc);
            for (ChargeGroupWrapper cgw : PayStaffWSUtillLightning.fetchChargeGroupList(gc)) {
                System.debug('cgw:'+cgw);
                if (cgw.cg.Active__c && cgw.cg.Balance__c != 0) {
                    cgw.isSelected = true;
					          chargeGroupList.add(cgw);
                }
            }
            chargeGroupId = '';
        }

        //Mohan Kumar 08-16-2016: launch Add to Payment Plan from contact Guarantor record 
        if (String.isBlank(paymentPlanExtId)) {
            paymentPlanExtId = getActivePaymentPlan(guarantorRecordId);
            if (String.isBlank(paymentPlanExtId)) {
                errorMessage += 'No active Payment Plan exist for this Guarantor. Please click Cancel to go previous page.';
            }
        }
    }
    
    //Check Charge group is selected or not.
    public Pagereference doNext() {
        chargeGroupsSelected = false;
        chargeGroupId = PayStaffWSUtillLightning.fetchChargeGroupIds(chargeGroupList);
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
    public String submit() {
        System.debug('submit'+ paymentPlanExtId +';'+guarantorId+';'+chargeGroupId);
        try {
            if (!isEmpty(paymentPlanExtId) && !isEmpty(guarantorId) && !isEmpty(chargeGroupId)) {
                String jwtToken = PayStaffWSUtillLightning.getJWTToken(username, password);
                String csrfToken = PayStaffWSUtillLightning.getCSRFToken();
                if (csrfToken != null && jwtToken != null) {
                    addToPaymentPlanCall(csrfToken, jwtToken);
                }
            } else {
                errorMessage += 'Please provide all details.';
                if (Test.IsRunningTest()) {
                    TestUtility.generateException();
                }
            }
        } catch (Exception e) {
            // Debug error response
            errorMessage += 'ERROR: ' + e.getMessage();
        }
        return errorMessage;
    }   
    
    /*Mohan Kumar 2016-08-02: Ticket # 06638015
    * Updated the request parameter value to send the Sirono External ID and NOT salesforce record Id.
    */
    private void addToPaymentPlanCall(String csrfToken, String jwtToken) {
        String requestData = '{"csrfmiddlewaretoken":"' + csrfToken + '",' +
                '"chargegroups": ' + PayStaffWSUtillLightning.buildChargeGroupsURL(chargeGroupId) + '}';

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        Http http = new Http();
        String responseBody;

        req.setMethod('POST');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/paymentplan/'
                + PayStaffWSUtillLightning.trimCommas(paymentPlanExtId) + '/add_chargegroups/');
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
            errorMessage += 'PROCESS PAYMENT EXCEPTION RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody + ' EXCEPTION:: ' + e.getMessage();
        }

        if (res.getStatusCode() != null && res.getStatusCode() == 200) {
            callPaymentPlanRequest(csrfToken, jwtToken);
        } else {
            errorMessage += 'RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody;
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
                + PayStaffWSUtillLightning.trimCommas(paymentPlanExtId) + '/');
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
            errorMessage += 'Added Successfully!';
        } else {
            errorMessage += 'RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody;
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
        upsert paymentPlanObj;

        List<Charge_Group__c> lstCG = new List<Charge_Group__c>();
        lstCG = objPaymentPlanWrapper.chargeGroupRecords;
        for (Charge_Group__c cg : lstCG) {
            cg.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
            cg.Payment_Plan__c = paymentPlanObj.Id;
        }
        Update lstCG;
    }
}