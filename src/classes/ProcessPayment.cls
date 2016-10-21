/*
* @author Sirono
* @version 1.0.1
* @Date: 04-19-2016
* @ProcessPayment Class for the payment process.
*
* Mohan Kumar 08-12-2016: Convert the amount in cents before sending it to Sirono
* 
* 08-19-2016: Sirono - Tracker # 127324171
* Method for check the validation.
* Date: 21/09/2016 Sirono - tracker # 130677929 ChargeGroupList based on Account sub status 
*/

public with sharing class ProcessPayment {
    public String username { get; set; }
    public String password { get; set; }
    public string creditCardNumber { get; set; }
    public string cardHolderName { get; set; }
    public string expirationYear { get; set; }
    public string expirationMonth { get; set; }
    public string cvv { get; set; }
    public string amount { get; set; }
    public string address { get; set; }
    public string city { get; set; }
    public string state { get; set; }
    public string zip { get; set; }
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
            gc = PayStaffWSUtill.fetchGuarantorContact(guarantorRecordId);
            guarantorName = PayStaffWSUtill.fetchGuarantorName(gc);
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

    public Pagereference doNext() {
        chargeGroupsSelected = false;
        chargeGroupId = PayStaffWSUtill.fetchChargeGroupIds(chargeGroupList);
        if (!isEmpty(chargeGroupId)) {
            chargeGroupsSelected = true;
        }/*else{
            chargeGroupsSelected = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                'Please select atleast one Charge Group'));
        }*/
        return null;
    }

    private Boolean isEmpty(String str) {
        return (str == null || str.trim().equals(''));
    }

    // Method used for call processPayment method
    public void submit() {
        try {

            /*
             * 08-19-2016: Sirono - Tracker # 127324171
             * Method for check the validation.
             */

            boolean blnIsError = false;
            blnIsError = checkCardValidation();

            boolean blnIsAmountError = checkAmountValidation();

            if (blnIsError == false && !blnIsAmountError) {
                String jwtToken = PayStaffWSUtill.getJWTToken(username, password);
                String csrfToken = PayStaffWSUtill.getCSRFToken();
                if (csrfToken != null && jwtToken != null) {
                    processPayment(csrfToken, jwtToken);
                }
            } else {
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
     * 08-19-2016: Sirono - Tracker # 127324171
     * Method for check the validation.
     */
    Public boolean checkAmountValidation() {
        boolean blnIsError = false;
        if (isEmpty(amount) || (amount.isNumeric() && decimal.valueof(amount) == 0)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Amount must be greater than zero.'));
            blnIsError = true;
        } else {
            decimal dctotalAmount = 0;
            for (ChargeGroupWrapper cgw : chargeGroupList) {
                if (cgw.cg.Balance__c != null && cgw.IsSelected == true) {
                    dctotalAmount += cgw.cg.Balance__c;
                }
            }
            if (decimal.valueof(amount) < 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                        'Amount must be greater than zero.'));
                blnIsError = true;
            }
            if (decimal.valueof(amount) > dctotalAmount) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
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
    Public boolean checkCardValidation() {
        boolean blnIsError = false;
        if (creditCardNumber.length() < 12 || creditCardNumber.Length() > 19) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'Credit card number must be 12-19 digits.'));
            blnIsError = true;
        }
        if (isEmpty(creditCardNumber)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'Card Number is a required field.'));
            blnIsError = true;
        }
        if (Integer.valueof(expirationYear) < system.today().year() ||
                (Integer.valueof(expirationYear) == system.today().year() &&
                        Integer.valueof(expirationMonth) < system.today().Month())) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'Expiration date must be in the future.'));
            blnIsError = true;
        }
        if (!isEmpty(zip) && zip.length() != 5) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'Zip code must be 5 digits.'));
            blnIsError = true;
        }
        if (!isEmpty(zip) && !zip.isNumeric()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'Zip code can only contain numeric values.'));
            blnIsError = true;
        }
        if (isEmpty(cardHolderName)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'Name is a required field.'));
            blnIsError = true;
        }

        if (!isEmpty(cvv) && (cvv.length() < 3 || cvv.length() > 4)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'CVV must be 4 digits for American Express and 3 digits for other card types.'));
            blnIsError = true;
        }

        if (isEmpty(cvv)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'CVV is a required field.'));
            blnIsError = true;
        }

        if (isEmpty(address)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'Billing Address is a required field.'));
            blnIsError = true;
        }

        if (isEmpty(zip)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'Zip Code is a required field.'));
            blnIsError = true;
        }

        if (isEmpty(chargeGroupId)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
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
        cardHolderName = gc.name;
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
                '"amount":' + PayStaffWSUtill.convertToCents(amount) + ',' +
                '"expiration_month":"' + expirationMonth + '",' +
                '"cardholder_name":"' + cardHolderName + '",' +
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

        req.setBody(requestData);

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

        if (res.getStatus() != null && res.getStatus().trim().equalsIgnoreCase('CREATED')
                && res.getStatusCode() != null && res.getStatusCode() == 201) {
            System.debug('RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'Created Successfully!'));
        } else {
            if (test.isRunningTest()) {
                responseBody = TestUtility.errorBody;
            }
            if (responseBody.Contains('non_field_errors') && responseBody.Contains('Validation exception')) {
                JSONParser parser = JSON.createParser(responseBody);
                WrapperErrorArray wrpPaymentPlanobj = (WrapperErrorArray) parser.readValueAs(WrapperErrorArray .class);
                if (wrpPaymentPlanobj != null && wrpPaymentPlanobj.errors.size() > 0) {
                    List<WrapperErrorArray.Errors> lstError = wrpPaymentPlanobj.errors;
                    for (WrapperErrorArray.Errors obj : lstError) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.valueof(obj.non_field_errors)));
                    }
                }
            } else if (responseBody.Contains('non_field_errors') && responseBody.Contains('Payments Exception')) {
                JSONParser parser = JSON.createParser(responseBody);
                WrapperError wrpPaymentPlanobj = (WrapperError) parser.readValueAs(WrapperError.class);
                if (wrpPaymentPlanobj != null && wrpPaymentPlanobj.errors.non_field_errors.size() > 0) {
                    for (String strMessage : wrpPaymentPlanobj.errors.non_field_errors) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.valueof(strMessage)));
                    }
                }
            } else if (responseBody.Contains('kind') && !responseBody.Contains('chargegroups')) {
                JSONParser parser = JSON.createParser(responseBody);
                WrapperListError wrpobj = (WrapperListError) parser.readValueAs(WrapperListError.class);
                if (wrpobj != null && wrpobj.errors.size() > 0) {
                    for (String strMessage : wrpobj.errors) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.valueof(strMessage)));
                    }
                }
            } else if (responseBody.Contains('kind') && responseBody.Contains('chargegroups')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                        'RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody));
            } else if(responseBody.Contains('non_field_errors')){
                JSONParser parser = JSON.createParser(responseBody);
                WrapperNonFieldErrorArray wrpPaymentPlanobj  = (WrapperNonFieldErrorArray)parser.readValueAs(WrapperNonFieldErrorArray.class);
                if(wrpPaymentPlanobj  != null && wrpPaymentPlanobj.non_field_errors.size() > 0){
                    for(String strMessage : wrpPaymentPlanobj.non_field_errors){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,String.valueof(strMessage)));
                    }
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                        'RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody));
            }
        }
    }
}