//Mohan Kumar 2016-08-12: Convert the amount in cents before sending it to Sirono
public with sharing class EditPaymentPlan {
    public String username {get; set;}
    public String password {get; set;}

    public String guarantorId {get; set;}
    public String paymentPlanId {get; set;}
    public String paymentPlanRecordId {get; set;}
    public String guarantorName {get; set;}
    public String chargegroupId {get; set;}

    public String planType {get; set;}
    public String planValue {get; set;}
    public String amount {get; set;}
    public String promiseAmount {get; set;}
    public String executeOnDay {get; set;}
    public String executeOnDayExisting {get; set;}
    public String cardHolderName {get; set;}
    public String expirationYear {get; set;}
    public String expirationMonth {get; set;}
    public String creditCardNumber {get; set;}
    public String CVV {get; set;}
    public String state {get; set;}
    public String zip {get; set;}
    public String address {get; set;}
    public String city {get; set;}

    public String numberInstallments {get; set;}
    public String payableAmount {get; set;}
    public String nextPaymentDate {get; set;}
    public String installmentsPaid {get; set;}
    public String installmentsTotal {get; set;}

    public String paymentPlanType {get; set;}

    public String guarantorRecordId {get; set;}
    public Boolean chargeGroupsSelected {get; set;}
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

    public EditPaymentPlan() {
        username = PayStaffWSUtill.un;
        password = PayStaffWSUtill.pw;
        guarantorRecordId = null;
        chargeGroupsSelected = false;
        paymentPlanId = null;
        paymentPlanRecordId = null;
        chrageGroupList = new List<ChargeGroupWrapper>();
        guarantorName = '';
        executeOnDayExisting = '';
        planType = 'auto';
        if (Apexpages.currentPage().getParameters().containsKey('paymentPlanId')) {
            paymentPlanRecordId = Apexpages.currentPage().getParameters().get('paymentPlanId');
            for (test__c p : [
                    Select Id, Name, Number_of_Installments__c, Payable_Amount__c, Next_Payment_Date__c,
                            Plan_Type__c, Remaining_Number_of_Installments__c, Execute_on_Day__c, Sirono_ID__c
                    FROM test__c
                    Where id = :paymentPlanRecordId
            ]) {
                paymentPlanId = String.valueOf(p.Sirono_ID__c);
                numberInstallments = String.valueOf(p.Number_of_Installments__c);
                if (p.Payable_Amount__c != null) {
                    payableAmount = String.valueOf(p.Payable_Amount__c);
                } else {
                    payableAmount = '0';
                }
                nextPaymentDate = String.valueOf(p.Next_Payment_Date__c);
                installmentsTotal = numberInstallments;
                if (p.Remaining_Number_of_Installments__c != null && installmentsTotal != null) {
                    installmentsPaid = String.valueOf(Integer.valueOf(installmentsTotal) - Integer.valueOf(p.Remaining_Number_of_Installments__c));
                } else {
                    installmentsPaid = '0';
                }
                if (p.Execute_on_Day__c != null) {
                    executeOnDayExisting = String.valueOf(p.Execute_on_Day__c);
                } else {
                    executeOnDayExisting = '1';
                }
                if (p.Plan_Type__c != null && p.Plan_Type__c.trim().equalsIgnoreCase('Manual')) {
                    planType = 'promise';
                }
            }
        }

        if (Apexpages.currentPage().getParameters().containsKey('guarantorId')) {
            guarantorRecordId = Apexpages.currentPage().getParameters().get('guarantorId');
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
        planValue = '32772';
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

    public Pagereference cancel() {
        Pagereference pg = null;
        if (!isEmpty(paymentPlanRecordId)) {
            pg = new Pagereference('/' + paymentPlanRecordId);
        } else if (!isEmpty(guarantorRecordId)) {
            pg = new Pagereference('/' + guarantorRecordId);
        } else {
            pg = new Pagereference('/home/home.jsp');
        }
        if (pg != null) {
            pg.setRedirect(true);
        }
        return pg;
    }

    public void doSubmit() {
        try {
            if (!isEmpty(guarantorId) && !isEmpty(chargegroupId) && !isEmpty(planType) && !isEmpty(planValue)
                    && ((planType.trim().equalsIgnoreCase('promise') && !isEmpty(promiseAmount))
                    || (!isEmpty(amount) && !isEmpty(executeOnDay)
                    && !isEmpty(cardHolderName) && !isEmpty(expirationYear) && !isEmpty(expirationMonth)
                    && !isEmpty(creditCardNumber) && !isEmpty(CVV) && !isEmpty(state)
                    && !isEmpty(zip) && !isEmpty(address) && !isEmpty(city)))) {
                String jwt_token = PayStaffWSUtill.getJWT_Token(username, password);
                String csrf_token = PayStaffWSUtill.getCSRF_Token();
                if (csrf_token != null && jwt_token != null) {
                    doEditPaymentPlan(csrf_token, jwt_token);
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Please provide all details.'));
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'ERROR: ' + e.getMessage()));
        }
    }

    private void doEditPaymentPlan(String csrfToken, String jwtToken) {
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        String request_data = '{"csrfmiddlewaretoken":"' + csrfToken + '",';
        if (planType != null && planType.trim().equalsIgnoreCase('auto')) {
            planValue = '32772';
            request_data += '"plan_type":"' + planType + '",' +
                    '"url": "' + (SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/paymentplan/' + paymentPlanId + '/') + '",' +
                    '"active":true,' +
                    '"installment_amount":' + PayStaffWSUtill.convertToCents(amount) + ',' +
                    '"number_installments":' + numberInstallments + ',' +
                    '"plan_value":' + planValue + ',' +
                    '"payable_amount":' + PayStaffWSUtill.convertToCents(payableAmount) + ',' +
                    '"execute_on_day":' + executeOnDay + ',' +
                    '"guarantor":"' + SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/guarantors/' + guarantorId + '/",' +
                    '"next_payment_date": "' + nextPaymentDate + '",' +
                    '"installments_paid": ' + installmentsPaid + ',' +
                    '"installments_total": ' + installmentsTotal + ',' +
                    '"chargegroups": ' + PayStaffWSUtill.buildChargeGroupsURL(chargegroupId) + ',' +
                    '"credit_card":{' +
                    '"method":"credit",' +
                    '"cardholder_name":"' + cardholderName + '",' +
                    '"expiration_year":"' + expirationYear + '",' +
                    '"expiration_month":"' + expirationMonth + '",' +
                    '"number":"' + creditCardNumber + '",' +
                    '"cvv":"' + CVV + '",' +
                    '"state":"' + state + '",' +
                    '"zipcode":"' + zip + '",' +
                    '"address_1":"' + address + '",' +
                    '"city":"' + city + '"' +
                    '}' + '}';
            req.setMethod('PUT');
        } else if (planType != null && planType.trim().equalsIgnoreCase('promise')) {
            planValue = '1700';
    		/*request_data += '"plan_type":"' + planType + '",' +
        	'"url": "' + (SironoSettingsUtil.getServerEndpoint()+'/paystaff/api/paymentplan/'+paymentPlanId+'/') + '",' +
        	'"active":true,' +
        	'"installment_amount":' + promiseAmount + ',' +
        	'"number_installments":' + numberInstallments + ',' +
        	'"plan_value":' + planValue + ',' +
        	'"payable_amount":' + payableAmount + ',' +
        	'"execute_on_day":' + executeOnDayExisting + ',' +
        	'"guarantor":"' + SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/guarantors/' + guarantorId + '/",' +
            '"next_payment_date": "'+nextPaymentDate+'",' +
			'"installments_paid": '+installmentsPaid+',' +
			'"installments_total": '+installmentsTotal+',' +
			'"has_error": false,'+
			'"charges_added_since_start": null,'+
			'"error_date": null,'+
            '"chargegroups": ' + PayStaffWSUtill.buildChargeGroupsURL(chargegroupId)+',' +
            '"delinquent": false,' +
			'"delinquent_date": null,' +
			'"encounters": [],' +
			'"authorized_amount": 0' +
            '}';*/
            request_data += '"installment_amount":' + PayStaffWSUtill.convertToCents(promiseAmount) + ',' +
                    '"guarantor":"' + SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/guarantors/' + guarantorId + '/"' +
                    '}';
            req.setMethod('POST');
            req.setHeader('X-HTTP-Method-Override', 'PATCH');
        }

        Http http = new Http();
        String responseBody;
        req.setEndpoint(SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/paymentplan/' + paymentPlanId + '/');
        //req.setMethod('PUT');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        System.debug('=================== PAYLOAD IS ' + request_data);
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
            res.setStatusCode(200);
        }

        if (res.getStatusCode() != null && res.getStatusCode() == 200) {
            System.debug('RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'Saved Successfully!'));
        } else {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'CSRF_Token : '+ csrfToken));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'JWT_Token : '+ jwtToken));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody));
        }
    }
}