//Mohan Kumar 2016-08-12: Convert the amount in cents before sending it to Sirono
public with sharing class ProcessPayment {
    public String username {get; set;}
    public String password {get; set;}
    public string creditCardNumber {get; set;}
    public string cardholderName {get; set;}
    public string expirationYear {get; set;}
    public string expirationMonth {get; set;}
    public string CVV {get; set;}
    public string amount {get; set;}
    public string address {get; set;}
    public string city {get; set;}
    public string state {get; set;}
    public string zip {get; set;}

    public String guarantorRecordId {get; set;}
    public Boolean chargeGroupsSelected {get; set;}

    public String guarantorId {get; set;}
    public String guarantorName {get; set;}
    public String chargegroupId {get; set;}
    public List<ChargeGroupWrapper> chrageGroupList {get; set;}

    public List<SelectOption> expYearOptions {
        get {
            if (expYearOptions == null) {
                expYearOptions = PayStaffWSUtill.expYearOptions;
            }
            return expYearOptions;
        }
        protected set;
    }

    public List<SelectOption> expMonthOptions {
        get {
            if (expMonthOptions == null) {
                expMonthOptions = PayStaffWSUtill.expMonthOptions;
            }
            return expMonthOptions;
        }
        protected set;
    }

    public ProcessPayment(ApexPages.StandardController sc) {
        username = PayStaffWSUtill.un;
        password = PayStaffWSUtill.pw;
        chargeGroupsSelected = false;
        guarantorName = '';
	    /*
	    guarantorId = '571';
	    chargegroupId = '1113837';
	    creditCardNumber = '4012888888881881';
	    expirationMonth = '12';
	    expirationYear = '2018';
	    CVV = '456';
	    amount = '200';
	    cardholderName = 'Joe Schmoe';
	    state = 'WI';
	    address = '8131 W 48th';
	    zip = '78737';
	    city = 'Austin';*/

        chrageGroupList = new List<ChargeGroupWrapper>();
        String guarantorRecordId = sc.getId();
        if (guarantorRecordId != null) {
            Contact gc = PayStaffWSUtill.fetchGuarantorContact(guarantorRecordId);
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
            if (!isEmpty(creditCardNumber) && !isEmpty(cardholderName) && !isEmpty(expirationYear)
                    && !isEmpty(expirationMonth) && !isEmpty(CVV) && !isEmpty(amount)
                    && !isEmpty(address) && !isEmpty(city) && !isEmpty(state)
                    && !isEmpty(zip) && !isEmpty(guarantorId) && !isEmpty(chargegroupId)) {
                String jwt_token = PayStaffWSUtill.getJWT_Token(username, password);
                String csrf_token = PayStaffWSUtill.getCSRF_Token();
                if (csrf_token != null && jwt_token != null) {
                    processPayment(csrf_token, jwt_token);
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Please provide all details.'));
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'ERROR: ' + e.getMessage()));
        }
    }

    private void processPayment(String csrfToken, String jwtToken) {
        String request_data = '{"csrfmiddlewaretoken":"' + csrfToken + '",' +
                '"guarantor":"' + SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/guarantors/' + guarantorId + '/",' +
                '"number":"' + creditCardNumber + '",' +
                '"chargegroups": ' + PayStaffWSUtill.buildChargeGroupsURL(chargegroupId) + ',' +
                '"expiration_year":"' + expirationYear + '",' +
                '"cvv":"' + CVV + '",' +
                '"amount":' + PayStaffWSUtill.convertToCents(amount) + ',' +
                '"expiration_month":"' + expirationMonth + '",' +
                '"cardholder_name":"' + cardholderName + '",' +
                '"state":"' + state + '",' +
                '"address_1":"' + address + '",' +
                '"zipcode":"' + zip + '",' +
                '"city":"' + city + '",' +
                '"total-amount":' + PayStaffWSUtill.convertToCents(amount) + ',' +
                '"method":"credit"}';

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        Http http = new Http();
        String responseBody;

        req.setMethod('POST');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/paychargegroups/');

        req.setBody(request_data);
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
            res.setStatusCode(201);
        }

        if (res.getStatus() != null && res.getStatus().trim().equalsIgnoreCase('CREATED')
                && res.getStatusCode() != null && res.getStatusCode() == 201) {
            System.debug('RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'Created Successfully!'));
        } else {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'CSRF_Token : '+ csrfToken));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'JWT_Token : '+ jwtToken));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody));
        }
    }
}