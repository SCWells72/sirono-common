public with sharing class AddToPaymentPlan {
    public String username {get; set;}
    public String password {get; set;}

    public String guarantorRecordId {get; set;}
    public Boolean chargeGroupsSelected {get; set;}

    public String guarantorId {get; set;}
    public String guarantorName {get; set;}
    public String chargegroupId {get; set;}
    public String paymentPlanId {get; set;}
    public String paymentPlanExtId {get; set;}
    public List<ChargeGroupWrapper> chrageGroupList {get; set;}

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
            Contact gc = PayStaffWSUtill.fetchGuarantorContactWithCGConstraints(guarantorRecordId);
            guarantorName = PayStaffWSUtill.fetchGuarantorName(gc);
            guarantorId = PayStaffWSUtill.fetchGuarantorId(gc);
            //chrageGroupList = PayStaffWSUtill.fetchChargeGroupList(gc);
            for (ChargeGroupWrapper cgw : PayStaffWSUtill.fetchChargeGroupList(gc)) {
                if (cgw.cg.Active__c && cgw.cg.Reported_Selfpay_Balance__c != 0) {
                    chrageGroupList.add(cgw);
                }
            }
            chargegroupId = '';
        }

        //Mohan Kumar 2016-08-16: launch Add to Payment Plan from contact Guarantor record
        if (String.isBlank(paymentPlanExtId)) {
            paymentPlanExtId = getActivePaymentPlan(guarantorRecordId);
            if (String.isBlank(paymentPlanExtId)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'No active Payment Plan exist for this Guarantor. Please click Cancel to go previous page.'));
            }
        }
    }

    //Mohan Kumar 2016-08-01: Ticket # 06638016 - Updated the QueryString parameter value to fix the "URL No Longer Exists" error.
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

    public Pagereference doNext() {
        chargeGroupsSelected = false;
        chargegroupId = PayStaffWSUtill.fetchChargeGroupIds(chrageGroupList);
        if (!isEmpty(chargegroupId)) {
            chargeGroupsSelected = true;
        }/*else{
			chargeGroupsSelected = false;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Please select atleast one Charge Group'));
		}*/
        return null;
    }

    private Boolean isEmpty(String str) {
        return (str == null || str.trim().equals(''));
    }

    private String getActivePaymentPlan(String guarantorRecordId) {
        String ppId;
        List<test__c> activePaymentPlans = [
                Select Id, Sirono_ID__c
                From test__c
                Where Active__c = true
                and Sirono_ID__c != null
                limit 1
        ];
        if (activePaymentPlans.size() > 0) ppId = activePaymentPlans[0].Sirono_ID__c.format();
        return ppId;
    }

    public void submit() {
        try {
            if (!isEmpty(paymentPlanExtId) && !isEmpty(guarantorId) && !isEmpty(chargegroupId)) {
                String jwt_token = PayStaffWSUtill.getJWT_Token(username, password);
                String csrf_token = PayStaffWSUtill.getCSRF_Token();
                if (csrf_token != null && jwt_token != null) {
                    addToPaymentPlan(csrf_token, jwt_token);
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Please provide all details.'));
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'ERROR: ' + e.getMessage()));
        }
    }

    //Mohan Kumar 2016-08-02: Ticket # 06638015 - Updated the request parameter value to send the Sirono External ID and NOT salesforce record Id.
    private void addToPaymentPlan(String csrfToken, String jwtToken) {
        String request_data = '{"csrfmiddlewaretoken":"' + csrfToken + '",' +
                '"chargegroups": ' + PayStaffWSUtill.buildChargeGroupsURL(chargegroupId) + '}';

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        Http http = new Http();
        String responseBody;

        req.setMethod('POST');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/paymentplan/' + PayStaffWSUtill.trimCommas(paymentPlanExtId) + '/add_chargegroups/');
        req.setTimeout(120000);
        req.setBody(request_data);
        System.debug('req: ' + req);
        System.debug('req: ' + request_data);
        //For APEX Test
        if (!Test.isRunningTest()) {
            try {
                res = http.send(req);
                responseBody = res.getBody();
            } catch (Exception e) {
                // Debug error response
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'PROCESS PAYMENT EXCEPTION RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody + ' EXCEPTION:: ' + e.getMessage()));
            }
        } else {
            res.setStatus('CREATED');
            res.setStatusCode(200);
        }

        if (res.getStatusCode() != null && res.getStatusCode() == 200) {
            System.debug('RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'Added Successfully!'));
        } else {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'CSRF_Token : '+ csrfToken));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'JWT_Token : '+ jwtToken));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody));
        }
    }
}