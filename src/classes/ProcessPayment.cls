/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class ProcessPayment {
    public String creditCardNumber { get; set; }
    public String cardHolderName { get; set; }
    public String expirationYear { get; set; }
    public String expirationMonth { get; set; }
    public String cvv { get; set; }
    public String amount { get; set; }
    public String address { get; set; }
    public String city { get; set; }
    public String state { get; set; }
    public String zip { get; set; }
    public String guarantorRecordId { get; set; }
    public Boolean chargeGroupsSelected { get; set; }
    public String guarantorId { get; set; }
    public String guarantorName { get; set; }
    public String chargeGroupId { get; set; }
    public List<ChargeGroupWrapper> chargeGroupList { get; set; }
    public Contact gc { get; set; }

    public List<SelectOption> expYearOptions {
        get {
            if (expYearOptions == null) {
                expYearOptions = UIUtils.expYearOptions;
            }
            return expYearOptions;
        }
        protected set;
    }

    public List<SelectOption> expMonthOptions {
        get {
            if (expMonthOptions == null) {
                expMonthOptions = UIUtils.expMonthOptions;
            }
            return expMonthOptions;
        }
        protected set;
    }

    public ProcessPayment(ApexPages.StandardController sc) {

        chargeGroupsSelected = false;
        guarantorName = '';
        /*
        guarantorId = '571';
        chargeGroupId = '1113837';
        creditCardNumber = '4012888888881881';
        expirationMonth = '12';
        expirationYear = '2018';
        cvv = '456';
        amount = '200';
        cardHolderName = 'Joe Schmoe';
        state = 'WI';
        address = '8131 W 48th';
        zip = '78737';
        city = 'Austin';*/

        chargeGroupList = new List<ChargeGroupWrapper>();
        guarantorRecordId = sc.getId();

        if (guarantorRecordId != null) {
            gc = GuarantorService.getGuarantorWithActiveCG(guarantorRecordId);
            guarantorName = GuarantorService.buildGuarantorDetailString(gc);
            guarantorId = PayStaffWSUtill.fetchGuarantorId(gc);
            //chargeGroupList = PayStaffWSUtill.fetchChargeGroupList(gc);
            //Collection of ChargeGroups that are active, balance not zero and who's account sub status is Preinvoiced, Due, Overdue, Delinquent, Bad Debt, or Payment Plan.
            for (ChargeGroupWrapper cgw : PayStaffWSUtill.fetchChargeGroupListByAccountSubStatus(gc)) {
                if (cgw.cg.Active__c && cgw.cg.Balance__c != 0) {
                    chargeGroupList.add(cgw);
                }
            }
            chargeGroupId = '';
        }
    }

    public PageReference doNext() {
        chargeGroupsSelected = false;
        chargeGroupId = PayStaffWSUtill.fetchChargeGroupIds(chargeGroupList);
        if (String.isNotBlank(chargeGroupId)) {
            chargeGroupsSelected = true;
        }/*else{
            chargeGroupsSelected = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                'Please select atleast one Charge Group'));
        }*/
        return null;
    }

    // Method used for call processPayment method
    public PageReference submit() {
        try {

            /*
             * 08-19-2016: Sirono - Tracker # 127324171
             * Method for check the validation.
             */

            Boolean blnIsError = false;
            blnIsError = checkCardValidation();

            Boolean blnIsAmountError = checkAmountValidation();

            if (blnIsError == false && !blnIsAmountError) {
                String jwtToken = new SironoRestClient.AuthRestClient().getJwtToken();
                String csrfToken = new SironoRestClient.AuthRestClient().getCsrfToken();
                if (csrfToken != null && jwtToken != null) {
                    processPayment(csrfToken, jwtToken);
                    return VisualforceControllerUtil.getRecordPageReference(guarantorRecordId);
                }
            } else {
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
     * 08-19-2016: Sirono - Tracker # 127324171
     * Method for check the validation.
     */
    public Boolean checkAmountValidation() {
        Boolean blnIsError = false;
        if (String.isBlank(amount) || (amount.isNumeric() && Decimal.valueOf(amount) == 0)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Amount must be greater than zero.'));
            blnIsError = true;
        } else {
            Decimal dctotalAmount = 0;
            for (ChargeGroupWrapper cgw : chargeGroupList) {
                if (cgw.cg.Balance__c != null && cgw.isSelected == true) {
                    dctotalAmount += cgw.cg.Balance__c;
                }
            }
            if (Decimal.valueOf(amount) < 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Amount must be greater than zero.'));
                blnIsError = true;
            }
            if (Decimal.valueOf(amount) > dctotalAmount) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Amount cannot exceed balance.'));
                blnIsError = true;
            }
        }
        return blnIsError;
    }

    /*
     * 08-19-2016: Sirono - Tracker #127324171
     * Method for check the validation.
     * 09-13-2016: Viraj Rana - Tracker #130117819:   Credit Card Error Messaging Method to check the Card validation. 
     */
    public Boolean checkCardValidation() {
        Boolean blnIsError = false;
        if (creditCardNumber.length() < 12 || creditCardNumber.length() > 19) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'Credit card number must be 12-19 digits.'));
            blnIsError = true;
        }
        if (String.isBlank(creditCardNumber)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'Card Number is a required field.'));
            blnIsError = true;
        }
        if (Integer.valueOf(expirationYear) < System.today().year() ||
            (Integer.valueOf(expirationYear) == System.today().year() &&
                Integer.valueOf(expirationMonth) < System.today().month())) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'Expiration date must be in the future.'));
            blnIsError = true;
        }
        if (String.isNotBlank(zip) && zip.length() != 5) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'Zip code must be 5 digits.'));
            blnIsError = true;
        }
        if (String.isNotBlank(zip) && !zip.isNumeric()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'Zip code can only contain numeric values.'));
            blnIsError = true;
        }
        if (String.isBlank(cardHolderName)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'Name is a required field.'));
            blnIsError = true;
        }

        if (String.isNotBlank(cvv) && (cvv.length() < 3 || cvv.length() > 4)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'CVV must be 4 digits for American Express and 3 digits for other card types.'));
            blnIsError = true;
        }

        if (String.isBlank(cvv)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'CVV is a required field.'));
            blnIsError = true;
        }

        if (String.isBlank(address)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'Billing Address is a required field.'));
            blnIsError = true;
        }

        if (String.isBlank(zip)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'Zip Code is a required field.'));
            blnIsError = true;
        }

        if (String.isBlank(chargeGroupId)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'Charge Group is a required field.'));
            blnIsError = true;
        }

        return blnIsError;
    }
    
    /*
    #130125231 : Enable "Fill Name and Address on File" functionality.
    fill the address,city,state,zip variable with the guarantor information.
    */

    public void fillNameAndAddress() {
        cardHolderName = gc.Name;
        address = gc.MailingStreet;
        city = gc.MailingCity;
        state = gc.MailingState;
        zip = gc.MailingPostalCode;
    }

    // Method used for payment process
    private void processPayment(String csrfToken, String jwtToken) {
        String requestData = '{"csrfmiddlewaretoken":"' + csrfToken + '",' +
            '"guarantor":"' + SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/guarantors/'
            + guarantorId + '/",' +
            '"number":"' + creditCardNumber + '",' +
            '"chargegroups": ' + PayStaffWSUtill.buildChargeGroupsURL(chargeGroupId) + ',' +
            '"expiration_year":"' + expirationYear + '",' +
            '"cvv":"' + cvv + '",' +
            '"amount":' + SironoRestClient.convertToCents(amount) + ',' +
            '"expiration_month":"' + expirationMonth + '",' +
            '"cardholder_name":"' + cardHolderName + '",' +
            '"state":"' + state + '",' +
            '"address_1":"' + address + '",' +
            '"zipcode":"' + zip + '",' +
            '"city":"' + city + '",' +
            '"total-amount":' + SironoRestClient.convertToCents(amount) + ',' +
            '"method":"credit"}';

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        Http http = new Http();
        String responseBody;

        req.setMethod('POST');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(RestClientConstants.SIRONO_BASE_URL + '/paystaff/api/paychargegroups/');

        req.setBody(requestData);
        System.debug('requestData : ' + requestData);

        try {
            res = http.send(req);
            responseBody = res.getBody();
            System.debug('responseBody : ' + responseBody);
            if (Test.isRunningTest()) {
                TestUtility.generateException();
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'PROCESS PAYMENT EXCEPTION RESPONSE : ' + res.toString() +
                    '  RESPONSE BODY::' + responseBody + ' EXCEPTION:: ' + e.getMessage()));
        }

        if (res.getStatus() != null && res.getStatus().trim().equalsIgnoreCase('CREATED')
            && res.getStatusCode() != null && res.getStatusCode() == 201) {
            System.debug('RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Created Successfully!'));

            //Call Payment, Transaction, ChargeGroups, Payment Plan Request.
            PayStaffWSUtill.processPayment(responseBody);
        } else {
            if (Test.isRunningTest()) {
                responseBody = TestUtility.errorbody;
            }
            if (responseBody.contains('non_field_errors') && responseBody.contains('Validation exception')) {
                JSONParser parser = JSON.createParser(responseBody);
                WrapperErrorArray wrpPaymentPlanobj = (WrapperErrorArray) parser.readValueAs(WrapperErrorArray .class);
                if (wrpPaymentPlanobj != null && wrpPaymentPlanobj.errors.size() > 0) {
                    List<WrapperErrorArray.Errors> lstError = wrpPaymentPlanobj.errors;
                    for (WrapperErrorArray.Errors obj : lstError) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, String.valueOf(obj.non_field_errors)));
                    }
                }
            } else if (responseBody.contains('non_field_errors') && responseBody.contains('Payments Exception')) {
                JSONParser parser = JSON.createParser(responseBody);
                WrapperError wrpPaymentPlanobj = (WrapperError) parser.readValueAs(WrapperError.class);
                if (wrpPaymentPlanobj != null && wrpPaymentPlanobj.errors.non_field_errors.size() > 0) {
                    for (String strMessage : wrpPaymentPlanobj.errors.non_field_errors) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, String.valueOf(strMessage)));
                    }
                }
            } else if (responseBody.contains('kind') && !responseBody.contains('chargegroups')) {
                JSONParser parser = JSON.createParser(responseBody);
                WrapperListError wrpobj = (WrapperListError) parser.readValueAs(WrapperListError.class);
                if (wrpobj != null && wrpobj.errors.size() > 0) {
                    for (String strMessage : wrpobj.errors) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, String.valueOf(strMessage)));
                    }
                }
            } else if (responseBody.contains('kind') && responseBody.contains('chargegroups')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                    'RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody));
            } else if (responseBody.contains('non_field_errors')) {
                JSONParser parser = JSON.createParser(responseBody);
                WrapperNonFieldErrorArray wrpPaymentPlanobj = (WrapperNonFieldErrorArray) parser.readValueAs(WrapperNonFieldErrorArray.class);
                if (wrpPaymentPlanobj != null && wrpPaymentPlanobj.non_field_errors.size() > 0) {
                    for (String strMessage : wrpPaymentPlanobj.non_field_errors) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, String.valueOf(strMessage)));
                    }
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                    'RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody));
            }
        }
    }
}