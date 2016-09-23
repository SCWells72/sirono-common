public with sharing class CreateAdjustment {
    public String username {get; set;}
    public String password {get; set;}

    public String amount {get; set;}
    public String guarantorRecordId {get; set;}
    public Boolean chargeGroupsSelected {get; set;}

    public String guarantorId {get; set;}
    public String guarantorName {get; set;}
    public String chargegroupId {get; set;}
    public List<ChargeGroupWrapper> chrageGroupList {get; set;}

    //Mohan Kumar 2016-08-16: 127328707 to show the adjustment type from the metadata type which are only enabled
    public List<SelectOption> adjustmentTypeOptions {get; set;}
    public String adjustmentTypeSelected {get; set;}

    public CreateAdjustment(ApexPages.StandardController sc) {
        username = PayStaffWSUtill.un;
        password = PayStaffWSUtill.pw;
        chargeGroupsSelected = false;
        guarantorName = '';
        chrageGroupList = new List<ChargeGroupWrapper>();
        String guarantorRecordId = sc.getId();

        //Mohan Kumar 2016-08-16: fetch only those metadata type which are marked as enabled
        adjustmentTypeOptions = new List<SelectOption>();
        adjustmentTypeOptions.add(new SelectOption('', '--None--'));
        for (Adjustment_Type__mdt aType : [Select a.Id, a.Enabled__c, a.Description__c, a.Code__c From Adjustment_Type__mdt a Where Enabled__c = true]) {
            adjustmentTypeOptions.add(new SelectOption(aType.Code__c, aType.Description__c));
        }
        if (guarantorRecordId != null) {
            Contact gc = PayStaffWSUtill.fetchGuarantorContact(guarantorRecordId);
            guarantorName = PayStaffWSUtill.fetchGuarantorName(gc);
            guarantorId = PayStaffWSUtill.fetchGuarantorId(gc);
            chrageGroupList = PayStaffWSUtill.fetchChargeGroupList(gc);
            chargegroupId = '';
        }
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

    public void submit() {
        try {
            if (!isEmpty(amount) && !isEmpty(chargegroupId) && !isEmpty(adjustmentTypeSelected)) {
                String jwt_token = PayStaffWSUtill.getJWT_Token(username, password);
                String csrf_token = PayStaffWSUtill.getCSRF_Token();
                if (csrf_token != null && jwt_token != null) {
                    createAdjustmetWSCall(csrf_token, jwt_token);
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Please provide all details.'));
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'ERROR: ' + e.getMessage()));
        }
    }

    private void createAdjustmetWSCall(String csrfToken, String jwtToken) {
        String request_data = '{"csrfmiddlewaretoken":"' + csrfToken + '",' +
                '"chargegroup":"' + SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/chargegroups/' + chargegroupId + '/",' +
                '"amount":' + PayStaffWSUtill.convertToCents(amount) + ',' +
                '"code":"' + adjustmentTypeSelected + '"}';

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        Http http = new Http();
        String responseBody;

        req.setMethod('POST');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/adjustments/');

        req.setBody(request_data);
        //For APEX Test
        if (!Test.isRunningTest()) {
            try {
                res = http.send(req);
                responseBody = res.getBody();
                System.debug('RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody);
            } catch (Exception e) {
                // Debug error response
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'PROCESS PAYMENT EXCEPTION RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody + ' EXCEPTION:: ' + e.getMessage()));
            }
        } else {
            res.setStatus('CREATED');
            res.setStatusCode(201);
        }

        if (res.getStatus() != null && res.getStatus().trim().equalsIgnoreCase('CREATED')
                && res.getStatusCode() != null && res.getStatusCode() == 201) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'Created Successfully!'));
        } else {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'CSRF_Token : '+ csrfToken));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'JWT_Token : '+ jwtToken));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody));
        }
    }
}