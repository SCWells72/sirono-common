/*
* @author: Cadalys
* @version 1.0.0
* @Date: 1-28-2017
* The calss has been copied from AddCreditCard to accomodate for usage with Lightning and exclude PageReferences and AddMessages from VF
*/

public with sharing class AddCreditCardLightning {
    public String username { get; set; }
    public String password { get; set; }
    public String guarantorId { get; set; }
    public String guarantorName { get; set; }
    public String chargeGroupId { get; set; }
    public String planType { get; set; }
    public String planValue { get; set; }
    public String amount { get; set; }
    public String promiseAmount { get; set; }
    public String executeOnDay { get; set; }
    public String cardHolderName { get; set; }
    public String expirationYear { get; set; }
    public String expirationMonth { get; set; }
    public String creditCardNumber { get; set; }
    public String cvv { get; set; }
    public String state { get; set; }
    public String zip { get; set; }
    public String address { get; set; }
    public String city { get; set; }
    public String guarantorRecordId { get; set; }
    public Boolean chargeGroupsSelected { get; set; }
    public List<ChargeGroupWrapper> chargeGroupList { get; set; }
    public String responseBody = '';
    public decimal dctotalAmount = 0;
    public Contact gc;
    public Sirono_Settings__c PaymentPlanSettings = new Sirono_Settings__c();
    public Boolean isActivePaymentPlan {get;set;}
    
    public List<ApexPages.Message> SironoLightningPageMessagesList {get;set;} //to store all messages from the page
    
    //Adding values to the picklist 
    public List<SelectOption> paymentPlanTypeOptions {
        get {
            if (paymentPlanTypeOptions == null) {
                paymentPlanTypeOptions = new List<SelectOption>();
                paymentPlanTypeOptions.add(new SelectOption('auto', 'Auto Draft'));
                paymentPlanTypeOptions.add(new SelectOption('promise', 'Promise To Pay'));
            }
            return paymentPlanTypeOptions;
        }
        protected set;
    }

    //Adding values to the picklist
    public List<SelectOption> expYearOptions {
        get {
            if (expYearOptions == null) {
                expYearOptions = PayStaffWSUtillLightning.expYearOptions;
            }
            return expYearOptions;
        }
        protected set;
    }

    //Adding values to the picklist
    public List<SelectOption> expMonthOptions {
        get {
            if (expMonthOptions == null) {
                expMonthOptions = PayStaffWSUtillLightning.expMonthOptions;
            }
            return expMonthOptions;
        }
        protected set;
    }

    //Constructor for initializing variables 
    public AddCreditCardLightning() {
        
        System.debug('AddCreditCardLightning constructor');
        dctotalAmount = 0;
        username = PayStaffWSUtillLightning.un;
        password = PayStaffWSUtillLightning.pw;
        guarantorRecordId = null;
        chargeGroupsSelected = false;
        chargeGroupList = new List<ChargeGroupWrapper>();
        guarantorName = '';
        planType = null;
        isActivePaymentPlan = false;
        SironoLightningPageMessagesList = new List<ApexPages.Message>();
        guarantorId = (Test.isRunningTest() && Apexpages.currentPage().getParameters().containsKey('guarantorId')) ? Apexpages.currentPage().getParameters().get('guarantorId') : guarantorId;
        if (String.IsNotBlank(guarantorId)) { // need to check if there is a difference between guarantorId and guarantorRecordId
            guarantorRecordId = guarantorId;
            gc = GuarantorService.getGuarantorWithActiveCG(guarantorId);
            guarantorName = GuarantorService.buildGuarantorDetailString(gc);
            guarantorId = PayStaffWSUtill.fetchGuarantorId(gc);
            //chargeGroupList = PayStaffWSUtillLightning.fetchChargeGroupList(gc);
            //date: 11/22/2016 tracker #134300243 fetching charge group list based on account sub status : Preinvoiced, Due, Overdue, Delinquent, or Bad Debt
            for (ChargeGroupWrapper cgw : PayStaffWSUtillLightning.fetchChargeGroupListByAccSubStatus(gc)) {
                if (cgw.cg.Active__c && cgw.cg.Balance__c != 0) {
                    chargeGroupList.add(cgw);
                }
            }
            chargeGroupId = '';
            
            //10-12-2016: Viraj Rana - Tracker #131459561: Prevent creation of multiple active payment plans to check Guarantor has Active payment plan or not.
            isActivePaymentPlan = checkPaymentPlanExist(guarantorRecordId);
        }
        planValue = '32772'; //AB TODO check what is this
    }

    //Controller Method invoked from Visualforce page
    public Pagereference doNext() {
        chargeGroupsSelected = false;
        chargeGroupId = PayStaffWSUtillLightning.fetchChargeGroupIds(chargeGroupList);
        if (!isEmpty(chargeGroupId)) {
            chargeGroupsSelected = true;
        }
        return null;
    }

    //Controller Method invoked from Visualforce page
    public Pagereference doNothing() {
        return null;
    }

    private Boolean isEmpty(String str) {
        return (str == null || str.trim().equals(''));
    }

    
    
    /*11-17-2016: Viraj Rana - Tracker #127404553
     *It is used to get Payment Plan Setting.
     *It is called in VF page,
     *becuase of whenever profile is "Operations Manager or System Administrator" at that we need to create new custom setting for it.
     *If we create using class than we can't send Web Request after insert so we use this method using VF page.
    */
    public void getPaymentPlanSettings(){
         PaymentPlanSettings = new Sirono_Settings__c();
         PaymentPlanSettings = SironoSettingsUtil.getPaymentPlanSettings();
    }
    
    //Controller Method invoked from Visualforce page
    public void CreatePaymentPlan() { //previously doSubmit on original class
        try {
            
            /*
            * 08-19-2016: Sirono - Tracker # 127324171
            * Method for check the amount validation.
            */

            boolean blnIsError = false;
            if (!planType.trim().equalsIgnoreCase('promise')) {
                blnIsError = checkCardValidation();
            }

            boolean blnIsAmountError = checkAmountValidation();

            if (blnIsError == false && !blnIsAmountError) {
                String jwtToken = PayStaffWSUtillLightning.getJWTToken(username, password);
                String csrfToken = PayStaffWSUtillLightning.getCSRFToken();
                if (csrfToken != null && jwtToken != null) {
                    doAddCreditCard(csrfToken, jwtToken);
                }
            } else {
                if (Test.IsRunningTest()) {
                    TestUtility.generateException();
                }
            }
        } catch (Exception e) {
            // Debug error response
            SironoLightningPageMessagesList.add(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'ERROR: ' + e.getMessage()));
        }
    }    
    //10-12-2016: Viraj Rana - Tracker #131459561: Prevent creation of multiple active payment plans to check Guarantor has Active payment plan or not.
    public boolean checkPaymentPlanExist(string guarantorRecordId) {
        boolean blnIsError = false;
        if (guarantorRecordId != null) {
            List<Payment_Plan__c> lstPaymentPlan = [SELECT Id FROM Payment_Plan__c where Guarantor__c =: guarantorRecordId and Active__c = true];
            if (lstPaymentPlan.size() > 0) {
                SironoLightningPageMessagesList.add(new ApexPages.Message(apexpages.severity.warning,
                    system.label.Payment_Plan_Error));
                blnIsError = true;
            }
        }
        return blnIsError;
    }
       
    /*
    * 08-19-2016: Sirono - Tracker # 127324171
    * Method for check the amount validation.
    * 09-30-2016: Viraj Rana - Tracker #127404553: Validate PaymentPlan against custom settings to check Monthly Installment Amount
    * based on Minimum Installment Amount and Maximum number of Installments.
    */ 
    Public boolean checkAmountValidation() {
        boolean blnIsError = false;
        if ((planType.trim().equalsIgnoreCase('promise') &&
                (isEmpty(promiseAmount) || (promiseAmount.isNumeric() && decimal.valueof(promiseAmount) == 0))) ||
                (!planType.trim().equalsIgnoreCase('promise') &&
                        (isEmpty(amount) || (amount.isNumeric() && decimal.valueof(amount) == 0))
                )) {
            SironoLightningPageMessagesList.add(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Amount must be greater than zero.'));
            blnIsError = true;
        } else {
            dctotalAmount = 0;
            for (ChargeGroupWrapper cgw : chargeGroupList) {
                if (cgw.cg.Balance__c != null && cgw.IsSelected == true) {
                    dctotalAmount += cgw.cg.Balance__c ;
                }
            }
            if ((planType.trim().equalsIgnoreCase('promise') && decimal.valueof(promiseAmount) < 0)
                    || (!planType.trim().equalsIgnoreCase('promise') && decimal.valueof(amount) < 0)
                    ) {
                SironoLightningPageMessagesList.add(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Amount must be greater than zero.'));
                blnIsError = true;
            }
            if ((planType.trim().equalsIgnoreCase('promise') && decimal.valueof(promiseAmount) > dctotalAmount)
                    || (!planType.trim().equalsIgnoreCase('promise') && decimal.valueof(amount) > dctotalAmount)
                    ) {
                SironoLightningPageMessagesList.add(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Amount cannot exceed balance.'));
                blnIsError = true;
            }
            
            decimal tempAmount = decimal.valueof(planType.trim().equalsIgnoreCase('promise') ? promiseAmount : amount);
            
            if(tempAmount < PaymentPlanSettings.Min_Installment_Amount__c){
                SironoLightningPageMessagesList.add(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'Monthly amount must be equal to or greater than $' + PaymentPlanSettings.Min_Installment_Amount__c + '.'));
                blnIsError = true;
            }
            
            if(tempAmount >= PaymentPlanSettings.Min_Installment_Amount__c) {
                integer totalInstallment = integer.valueof((dctotalAmount/tempAmount).round(System.RoundingMode.CEILING));
                integer minimumInstallmentAmount = 0;
                
                system.debug('Min Installment Amount : ' + PaymentPlanSettings.Min_Installment_Amount__c);
                system.debug('Max Installment : ' + PaymentPlanSettings.Max_Number_Plan_Installments__c);
                system.debug('dctotalAmount : ' + dctotalAmount);
                system.debug('tempAmount : ' + tempAmount);
                
                if (PaymentPlanSettings.Max_Number_Plan_Installments__c > 0) {
                    minimumInstallmentAmount = integer.valueof((dctotalAmount/PaymentPlanSettings.Max_Number_Plan_Installments__c).round(System.RoundingMode.CEILING));
                }
                
                if (totalInstallment > PaymentPlanSettings.Max_Number_Plan_Installments__c) {
                    SironoLightningPageMessagesList.add(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                        'This monthly amount would exceed ' + PaymentPlanSettings.Max_Number_Plan_Installments__c + ' installments.' +
                        ' The minimum allowed installment amount is $' + minimumInstallmentAmount + '.'));
                    blnIsError = true;                
                }
            }
        }
        return blnIsError;
    }
    
    /*
    * 08-19-2016: Sirono - Tracker # 127324171
    * Method for check the Card validation.
    * 09-13-2016: Viraj Rana - Tracker #130117819:   Credit Card Error Messaging Method to check the Card validation. 
    * 09-30-2016: Viraj Rana - Tracker #131322621: Date to Charge error to check the Date to Charge (each month) Enter only number between 1 to 31.
    */
    Public boolean checkCardValidation() {
        boolean blnIsError = false;
        if (creditCardNumber.length() < 12 || creditCardNumber.Length() > 19) {
            SironoLightningPageMessagesList.add(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'Credit card number must be 12-19 digits.'));
            blnIsError = true;
        }
        if (isEmpty(creditCardNumber)) {
            SironoLightningPageMessagesList.add(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'Card Number is a required field.'));
            blnIsError = true;
        }
        if (Integer.valueof(expirationYear) < system.today().year() ||
                (Integer.valueof(expirationYear) == system.today().year() &&
                        Integer.valueof(expirationMonth) < system.today().Month())) {
            SironoLightningPageMessagesList.add(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'Expiration date must be in the future.'));
            blnIsError = true;
        }
        if (!isEmpty(zip) && zip.length() != 5) {
            SironoLightningPageMessagesList.add(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'Zip code must be 5 digits.'));
            blnIsError = true;
        }
        if (!isEmpty(zip) && !zip.isNumeric()) {
            SironoLightningPageMessagesList.add(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'Zip code can only contain numeric values.'));
            blnIsError = true;
        }
        if (isEmpty(cardHolderName)) {
            SironoLightningPageMessagesList.add(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'Name is a required field.'));
            blnIsError = true;
        }

        if (!isEmpty(cvv) && (cvv.length() < 3 || cvv.length() > 4)) {
            SironoLightningPageMessagesList.add(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'CVV must be 4 digits for American Express and 3 digits for other card types.'));
            blnIsError = true;
        }

        if (isEmpty(cvv)) {
            SironoLightningPageMessagesList.add(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'CVV is a required field.'));
            blnIsError = true;
        }

        if (isEmpty(address)) {
            SironoLightningPageMessagesList.add(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'Billing Address is a required field.'));
            blnIsError = true;
        }

        if (isEmpty(zip)) {
            SironoLightningPageMessagesList.add(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'Zip Code is a required field.'));
            blnIsError = true;
        }

        if (isEmpty(chargeGroupId)) {
            SironoLightningPageMessagesList.add(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'Charge Group is a required field.'));
            blnIsError = true;
        }

        if (isEmpty(executeOnDay) || Integer.valueof(executeOnDay) < 1 || Integer.valueof(executeOnDay) > 31) {
            SironoLightningPageMessagesList.add(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'Date to Charge (each month) must be a number between 1 and 31.'));
            blnIsError = true;
        }
        return blnIsError;
    }

    // Method for add credit card.
    private void doAddCreditCard(String csrfToken, String jwtToken) {
        //doTesting(); return;

        String requestData = '{"csrfmiddlewaretoken":"' + csrfToken + '",';
        if (planType != null && planType.trim().equalsIgnoreCase('auto')) {
            planValue = '32772';
            requestData += '"plan_type":"' + planType + '",' +
                    '"plan_value":' + planValue + ',' +
                    '"installment_amount":' + PayStaffWSUtillLightning.convertToCents(amount) + ',' +
                    '"execute_on_day":' + executeOnDay + ',' +
                    '"chargegroups": ' + PayStaffWSUtillLightning.buildChargeGroupsURL(chargeGroupId) + ',' +
                    '"guarantor":"' + SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/guarantors/' + guarantorId + '/",' +
                    '"active":true,' +
                    '"credit_card":{' +
                    '"method":"credit",' +
                    '"cardholder_name":"' + cardholderName + '",' +
                    '"expiration_year":"' + expirationYear + '",' +
                    '"expiration_month":"' + expirationMonth + '",' +
                    '"number":"' + creditCardNumber + '",' +
                    '"cvv":"' + cvv + '",' +
                    '"state":"' + state + '",' +
                    '"zipcode":"' + zip + '",' +
                    '"address_1":"' + address + '",' +
                    '"city":"' + city + '"' +
                    '}' + '}';
        } else if (planType != null && planType.trim().equalsIgnoreCase('promise')) {
            planValue = '1700';
            requestData += '"plan_type":"' + planType + '",' +
                    '"plan_value":' + planValue + ',' +
                    '"installment_amount":' + PayStaffWSUtillLightning.convertToCents(promiseAmount) + ',' +
                    '"chargegroups": ' + PayStaffWSUtillLightning.buildChargeGroupsURL(chargeGroupId) + ',' +
                    '"guarantor":"' + SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/guarantors/' + guarantorId + '/",' +
                    '"active":true}';
        }

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setMethod('POST');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/paymentplan/');
        req.setBody(requestData);

        try {
            System.debug(req.getBody());
            res = http.send(req);
            responseBody = res.getBody();

            if (Test.IsRunningTest()) {
                TestUtility.generateException();
            }

        } catch (Exception e) {
            System.debug(e.getMessage());
            // Debug error response
            //SironoLightningPageMessagesList.add(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'PROCESS PAYMENT EXCEPTION RESPONSE : '+ res.toString() + '  RESPONSE BODY::' + responseBody + ' EXCEPTION:: ' + e.getMessage()));
        }

        if (res.getStatus() != null && res.getStatus().trim().equalsIgnoreCase('CREATED')
                && res.getStatusCode() != null && res.getStatusCode() == 201) {
            parseResponse(responseBody);
            SironoLightningPageMessagesList.add(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'Created Successfully!'));
        } else {
            if (test.isRunningTest()) {
                responseBody = TestUtility.Errorbody;
            }
            System.debug(responseBody);
            if (responseBody.Contains('non_field_errors') && responseBody.Contains('Validation exception')) {
                JSONParser parser = JSON.createParser(responseBody);
                WrapperErrorArray wrpPaymentPlanobj = (WrapperErrorArray) parser.readValueAs(WrapperErrorArray .class);
                if (wrpPaymentPlanobj != null && wrpPaymentPlanobj.errors.size() > 0) {
                    List<WrapperErrorArray.Errors> lstError = wrpPaymentPlanobj.errors;
                    for (WrapperErrorArray.Errors obj : lstError) {
                        SironoLightningPageMessagesList.add(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.valueof(obj.non_field_errors)));
                    }
                }
            } else if (responseBody.Contains('non_field_errors') && responseBody.Contains('Payments Exception')) {
                JSONParser parser = JSON.createParser(responseBody);
                WrapperError wrpPaymentPlanobj = (WrapperError) parser.readValueAs(WrapperError.class);
                if (wrpPaymentPlanobj != null && wrpPaymentPlanobj.errors.non_field_errors.size() > 0) {
                    for (String strMessage : wrpPaymentPlanobj.errors.non_field_errors) {
                        SironoLightningPageMessagesList.add(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.valueof(strMessage)));
                    }
                }
            } else if (responseBody.Contains('kind') && !responseBody.Contains('chargegroups')) {
                JSONParser parser = JSON.createParser(responseBody);
                WrapperListError wrpobj = (WrapperListError) parser.readValueAs(WrapperListError.class);
                if (wrpobj != null && wrpobj.errors.size() > 0) {
                    for (String strMessage : wrpobj.errors) {
                        SironoLightningPageMessagesList.add(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.valueof(strMessage)));
                    }
                }
            } else if (responseBody.Contains('kind') && responseBody.Contains('chargegroups')) {
                SironoLightningPageMessagesList.add(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                        'RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody));
            } else if(responseBody.Contains('non_field_errors')){
                JSONParser parser = JSON.createParser(responseBody);
                WrapperNonFieldErrorArray wrpPaymentPlanobj  = (WrapperNonFieldErrorArray)parser.readValueAs(WrapperNonFieldErrorArray.class);
                if(wrpPaymentPlanobj  != null && wrpPaymentPlanobj.non_field_errors.size() > 0){
                    for(String strMessage : wrpPaymentPlanobj.non_field_errors){
                        SironoLightningPageMessagesList.add(new ApexPages.Message(ApexPages.SEVERITY.ERROR,String.valueof(strMessage)));
                    }
                }
            } else {
                SironoLightningPageMessagesList.add(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                        'RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody));
            }
        }
    }
    
   /*
    * #130125231 : Enable "Fill Name and Address on File" functionality.
    * fill the address,city,state,zip variable with the guarantor information.
    */

    public void fillNameAndAddress() {
        cardHolderName = gc.name;
        address = gc.MailingStreet;
        city = gc.MailingCity;
        state = gc.MailingState;
        zip = gc.MailingPostalCode;
    }
    
    /*
    * 09-16-2016: Viraj Rana 
    *  Call this method to test
    */
    Public void doTesting() {
        responseBody = PaymentPlanJSONParsing.testResponse();
        parseResponse(responseBody);
    }
    
    /*
    * 08-17-2016: Sirono - Tracker # 127940071
    *  parse the Response and create a payment plan record.
    */
    Public void parseResponse(String jsonStr) {

        PaymentPlanJSONParsing.PaymentPlanWrapper objPaymentPlanWrapper;
        objPaymentPlanWrapper = PaymentPlanJSONParsing.createPaymentPlanRecord(jsonStr, guarantorRecordId,
                null, chargeGroupId);
        Payment_Plan__c paymentPlanObj = objPaymentPlanWrapper.paymentPlanRecord; 
        paymentPlanObj.Name = String.valueof(paymentPlanObj.Sirono_ID__c);
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