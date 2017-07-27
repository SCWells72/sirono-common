/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class EditPaymentPlan {
    public String username { get; set; }
    public String password { get; set; }
    public String guarantorId { get; set; }
    public String paymentPlanId { get; set; }
    public String paymentPlanRecordId { get; set; }
    public String guarantorName { get; set; }
    public String chargeGroupId { get; set; }
    public String planType { get; set; }
    public String planValue { get; set; }
    public String amount { get; set; }
    public String promiseAmount { get; set; }
    public String executeOnDay { get; set; }
    public String executeOnDayExisting { get; set; }
    public String cardHolderName { get; set; }
    public String expirationYear { get; set; }
    public String expirationMonth { get; set; }
    public String creditCardNumber { get; set; }
    public String cvv { get; set; }
    public String state { get; set; }
    public String zip { get; set; }
    public String address { get; set; }
    public String city { get; set; }
    public String numberInstallments { get; set; }
    public String payableAmount { get; set; }
    public String nextPaymentDate { get; set; }
    public String installmentsPaid { get; set; }
    public String installmentsTotal { get; set; }
    public String paymentPlanType { get; set; }
    public String guarantorRecordId { get; set; }
    public Boolean chargeGroupsSelected { get; set; }
    public List<ChargeGroupWrapper> chargeGroupList { get; set; }
    public Decimal totalAmount { get; set; }
    public String responseBody = '';
    public Contact gc;

    //adding values to picklist
    public List<SelectOption> expYearOptions {
        get {
            if (expYearOptions == null) {
                expYearOptions = UIUtils.expYearOptions;
            }
            return expYearOptions;
        }
        protected set;
    }

    //adding values to picklist
    public List<SelectOption> expMonthOptions {
        get {
            if (expMonthOptions == null) {
                expMonthOptions = UIUtils.expMonthOptions;
            }
            return expMonthOptions;
        }
        protected set;
    }

    //Constructor initializing variables
    public EditPaymentPlan() {

        guarantorRecordId = null;
        chargeGroupsSelected = false;
        paymentPlanId = null;
        paymentPlanRecordId = null;
        chargeGroupList = new List<ChargeGroupWrapper>();
        guarantorName = '';
        executeOnDayExisting = '';
        planType = 'auto';
        totalAmount = 0;
        if (ApexPages.currentPage().getParameters().containsKey('paymentPlanId')) {
            paymentPlanRecordId = ApexPages.currentPage().getParameters().get('paymentPlanId');
            if (PaymentPlanSecurityContext.EPP_SELECT_CONTEXT.actionAllowed()) {
                for (Payment_Plan__c p : [
                    SELECT Id, Name, Original_Installment_Count__c, Remaining_Balance__c, NextPaymentDate__c,
                        Plan_Type__c, Remaining_Installment_Count__c, Execute_on_Day__c, Sirono_ID__c
                    FROM Payment_Plan__c
                    WHERE Id = :paymentPlanRecordId
                ]) {
                    System.debug('23' + p);
                    paymentPlanId = String.valueOf(p.Sirono_ID__c);
                    numberInstallments = String.valueOf(p.Original_Installment_Count__c);
                    if (p.Remaining_Balance__c != null) {
                        payableAmount = String.valueOf(p.Remaining_Balance__c);
                    } else {
                        payableAmount = '0';
                    }
                    nextPaymentDate = String.valueOf(p.NextPaymentDate__c);
                    installmentsTotal = numberInstallments;
                    if (p.Remaining_Installment_Count__c != null && installmentsTotal != null) {
                        installmentsPaid = String.valueOf(
                            Integer.valueOf(installmentsTotal) - Integer.valueOf(p.Remaining_Installment_Count__c)
                        );
                    } else {
                        installmentsPaid = '0';
                    }
                    if (p.Execute_on_Day__c != null && p.Execute_on_Day__c != 0) {
                        executeOnDayExisting = String.valueOf(p.Execute_on_Day__c);
                    } else {
                        executeOnDayExisting = '1';
                    }
                    if (p.Plan_Type__c != null && p.Plan_Type__c.trim().equalsIgnoreCase('Manual')) {
                        planType = 'promise';
                    }
                }
            }
        }

        if (ApexPages.currentPage().getParameters().containsKey('guarantorId')) {
            guarantorRecordId = ApexPages.currentPage().getParameters().get('guarantorId');
            gc = GuarantorService.getGuarantorWithActiveCG(guarantorRecordId);
            guarantorName = GuarantorService.buildGuarantorDetailString(gc);
            guarantorId = PayStaffWSUtill.fetchGuarantorId(gc);

            for (ChargeGroupWrapper cgw : ChargeGroupWrapper.buildList(gc)) {
                if (cgw.cg.Active__c && cgw.cg.Balance__c != 0 && cgw.cg.Account_Sub_Status__c == Constants.ACCT_SUBSTATUS_PAYMENT_PLAN) {
                    cgw.isSelected = true;
                    chargeGroupList.add(cgw);
                    totalAmount += cgw.cg.Balance__c;
                }
            }
            chargeGroupId = PayStaffWSUtill.fetchChargeGroupIds(chargeGroupList);

        }
        planValue = '32772';
    }

    /*//Controller Methods invoked from VisualForce
    public Pagereference doNext() {
        chargeGroupsSelected = false;
        chargeGroupId = PayStaffWSUtill.fetchChargeGroupIds(chargeGroupList);
        if (!isEmpty(chargeGroupId)) {
            chargeGroupsSelected = true;
        }/*else{
            chargeGroupsSelected = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 
                                    'Please select atleast one Charge Group'));
        }
        return null;
    }*/

    private Boolean isEmpty(String str) {
        return (str == null || str.trim().equals(''));
    }

    //Controller Methods invoked from VisualForce
    public PageReference cancel() {
        PageReference pg = null;
        if (!isEmpty(paymentPlanRecordId)) {
            pg = new PageReference('/' + paymentPlanRecordId);
        } else if (!isEmpty(guarantorRecordId)) {
            pg = new PageReference('/' + guarantorRecordId);
        } else {
            pg = new PageReference('/home/home.jsp');
        }
        if (pg != null) {
            pg.setRedirect(true);
        }
        return pg;
    }
    
    /*
     * 08-19-2016: Sirono - Tracker # 127324171
     * Method for check the validation.
     */
    public void doSubmit() {
        try {
            //doEditPaymentPlan('', '');
            Boolean blnIsError = false;
            if (!planType.trim().equalsIgnoreCase('promise')) {
                blnIsError = checkCardValidation();
            }

            Boolean blnIsAmountError = checkAmountValidation();

            if (blnIsError == false && !blnIsAmountError) {
                String jwtToken = new SironoRestClient.AuthRestClient().getJwtToken();
                String csrfToken = new SironoRestClient.AuthRestClient().getCsrfToken();
                if (csrfToken != null && jwtToken != null) {
                    doEditPaymentPlan(csrfToken, jwtToken);
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
    }

    /*
     * 08-19-2016: Sirono - Tracker # 127324171
     * Method for check the amount validation.
     * 09-30-2016: Viraj Rana - Tracker #127404553: Validate PaymentPlan against custom settings to check Monthly Installment Amount
     * based on Minimum Installment Amount and Maximum number of Installments.
     */
    public Boolean checkAmountValidation() {
        Boolean blnIsError = false;

        if ((planType.trim().equalsIgnoreCase('promise') &&
            (isEmpty(promiseAmount) || (promiseAmount.isNumeric() && Decimal.valueOf(promiseAmount) == 0))) ||
            (!planType.trim().equalsIgnoreCase('promise') &&
                (isEmpty(amount) || (amount.isNumeric() && Decimal.valueOf(amount) == 0))
            )) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Amount must be greater than zero.'));
            blnIsError = true;
        } else {
            Sirono_Settings__c planLimits = SironoSettingsUtil.getPaymentPlanSettings();
            if ((planType.trim().equalsIgnoreCase('promise') && Decimal.valueOf(promiseAmount) < 0)
                || (!planType.trim().equalsIgnoreCase('promise') && Decimal.valueOf(amount) < 0)
                ) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Amount must be greater than zero.'));
                blnIsError = true;
            }

            if ((planType.trim().equalsIgnoreCase('promise') && Decimal.valueOf(promiseAmount) > Decimal.valueOf(payableAmount))
                || (!planType.trim().equalsIgnoreCase('promise') && Decimal.valueOf(amount) > Decimal.valueOf(payableAmount))
                ) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Amount cannot exceed balance.'));
                blnIsError = true;
            }

            Decimal tempAmount = Decimal.valueOf(planType.trim().equalsIgnoreCase('promise') ? promiseAmount : amount);

            if (tempAmount < planLimits.Min_Installment_Amount__c) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Monthly amount must be equal to or greater than $' + planLimits.Min_Installment_Amount__c + '.'));
                blnIsError = true;
            }

            if (tempAmount >= planLimits.Min_Installment_Amount__c) {
                Integer totalInstallment = Integer.valueOf((Decimal.valueOf(payableAmount) / tempAmount).round(System.RoundingMode.CEILING));
                Integer minimumInstallmentAmount = 0;

                if (planLimits.Max_Number_Plan_Installments__c > 0) {
                    minimumInstallmentAmount = Integer.valueOf((Decimal.valueOf(payableAmount) / planLimits.Max_Number_Plan_Installments__c).round(System.RoundingMode.CEILING));
                }

                if (totalInstallment > planLimits.Max_Number_Plan_Installments__c) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                        'This monthly amount would exceed ' + planLimits.Max_Number_Plan_Installments__c + ' installments.' +
                            ' The minimum allowed installment amount is $' + minimumInstallmentAmount + '.'));
                    blnIsError = true;
                }
            }
        }
        return blnIsError;
    }

    /* 09-13-2016: Viraj Rana - Tracker #130117819: Credit Card Error Messaging Method to check the Card validation.
     * 09-30-2016: Viraj Rana - Tracker #131322621: Date to Charge error to check the Date to Charge (each month) Enter only number between 1 to 31.
     */
    public Boolean checkCardValidation() {
        Boolean blnIsError = false;
        if (creditCardNumber.length() < 12 || creditCardNumber.length() > 19) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'Credit card number must be 12-19 digits.'));
            blnIsError = true;
        }
        if (isEmpty(creditCardNumber)) {
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
        if (!isEmpty(zip) && zip.length() != 5) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'Zip code must be 5 digits.'));
            blnIsError = true;
        }
        if (!isEmpty(zip) && !zip.isNumeric()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'Zip code can only contain numeric values.'));
            blnIsError = true;
        }
        if (isEmpty(cardHolderName)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'Name is a required field.'));
            blnIsError = true;
        }

        if (isEmpty(cvv)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'CVV is a required field.'));
            blnIsError = true;
        }

        if (isEmpty(address)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'Billing Address is a required field.'));
            blnIsError = true;
        }

        if (!isEmpty(cvv) && (cvv.length() < 3 || cvv.length() > 4)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'CVV must be 4 digits for American Express and 3 digits for other card types.'));
            blnIsError = true;
        }

        if (isEmpty(zip)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'Zip Code is a required field.'));
            blnIsError = true;
        }

        if (isEmpty(chargeGroupId)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'Charge Group is a required field.'));
            blnIsError = true;
        }

        if (isEmpty(executeOnDay) || Integer.valueOf(executeOnDay) < 1 || Integer.valueOf(executeOnDay) > 31) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'Date to Charge (each month) must be a number between 1 and 31.'));
            blnIsError = true;
        }
        return blnIsError;
    }


    //Send an request to end point 
    private void doEditPaymentPlan(String csrfToken, String jwtToken) {
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        String requestData = '{"csrfmiddlewaretoken":"' + csrfToken + '",';
        if (planType != null && planType.trim().equalsIgnoreCase('auto')) {
            planValue = '32772';
            requestData += '"plan_type":"' + planType + '",' +
                '"url": "' + (SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/paymentplan/' + paymentPlanId + '/') + '",' +
                '"active":true,' +
                '"installment_amount":' + SironoRestClient.convertToCents(amount) + ',' +
                '"number_installments":' + numberInstallments + ',' +
                '"plan_value":' + planValue + ',' +
                '"payable_amount":' + SironoRestClient.convertToCents(payableAmount) + ',' +
                '"execute_on_day":' + executeOnDay + ',' +
                '"guarantor":"' + SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/guarantors/' + guarantorId + '/",' +
                '"next_payment_date": "' + nextPaymentDate + '",' +
                '"installments_paid": ' + installmentsPaid + ',' +
                '"installments_total": ' + installmentsTotal + ',' +
                '"chargegroups": ' + PayStaffWSUtill.buildChargeGroupsURL(chargeGroupId) + ',' +
                '"credit_card":{' +
                '"method":"credit",' +
                '"cardholder_name":"' + cardHolderName + '",' +
                '"expiration_year":"' + expirationYear + '",' +
                '"expiration_month":"' + expirationMonth + '",' +
                '"number":"' + creditCardNumber + '",' +
                '"cvv":"' + cvv + '",' +
                '"state":"' + state + '",' +
                '"zipcode":"' + zip + '",' +
                '"address_1":"' + address + '",' +
                '"city":"' + city + '"' +
                '}' + '}';
            req.setMethod('PUT');
        } else if (planType != null && planType.trim().equalsIgnoreCase('promise')) {
            planValue = '1700';
            /*requestData += '"plan_type":"' + planType + '",' +
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
            '"chargegroups": ' + PayStaffWSUtill.buildChargeGroupsURL(chargeGroupId)+',' +
            '"delinquent": false,' +
            '"delinquent_date": null,' +
            '"encounters": [],' +
            '"authorized_amount": 0' +
            '}';*/
            requestData += '"installment_amount":' + SironoRestClient.convertToCents(promiseAmount) + ',' +
                '"guarantor":"' + SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/guarantors/' + guarantorId + '/"' +
                '}';
            req.setMethod('POST');
            req.setHeader('X-HTTP-Method-Override', 'PATCH');
        }
        Http http = new Http();
        String responseBody;
        req.setEndpoint(RestClientConstants.SIRONO_BASE_URL + '/paystaff/api/paymentplan/' + paymentPlanId + '/');
        //req.setMethod('PUT');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        System.debug('=================== PAYLOAD IS ' + requestData);
        req.setBody(requestData);

        try {
            res = http.send(req);
            responseBody = res.getBody();
            if (Test.isRunningTest()) {
                TestUtility.generateException();
            }
            //responseBody  = testResponse();
            //System.debug('responseBody' + responseBody);

        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'PROCESS PAYMENT EXCEPTION RESPONSE : ' + res.toString() +
                    '  RESPONSE BODY::' + responseBody +
                    ' EXCEPTION:: ' + e.getMessage()));
        }

        if (res.getStatusCode() != null && res.getStatusCode() == 200) {
            System.debug('RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody);
            parseResponse(responseBody);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Saved Successfully!'));
        } else {
            if (Test.isRunningTest()) {
                responseBody = TestUtility.errorbody;
            }
            System.debug('responseBody : ' + responseBody);
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
    
    /*
    * #130125231 : Enable "Fill Name and Address on File" functionality.
    * fill the address,city,state,zip variable with the guarantor information.
    */

    public void fillNameAndAddress() {
        cardHolderName = gc.Name;
        address = gc.MailingStreet;
        city = gc.MailingCity;
        state = gc.MailingState;
        zip = gc.MailingPostalCode;
    }
    
    /*
    * 09-16-2016: Viraj Rana 
    *  Call this method to test
    */
    public void doTesting() {
        String str = PaymentPlanJSONParsing.testResponse();
        parseResponse(str);
    }
    
    /*
    * 08-17-2016: Sirono - Tracker # 127940071
    *  parse the Response and create a payment plan record.
    */
    public void parseResponse(String jsonStr) {

        PaymentPlanJSONParsing.PaymentPlanWrapper objPaymentPlanWrapper;
        objPaymentPlanWrapper = PaymentPlanJSONParsing.createPaymentPlanRecord(jsonStr, guarantorRecordId,
            null, chargeGroupId);
        Payment_Plan__c paymentPlanObj = objPaymentPlanWrapper.paymentPlanRecord;

        if (PaymentPlanSecurityContext.UPSERT_CONTEXT.actionAllowed()) {
            upsert paymentPlanObj;
        }
    }
}