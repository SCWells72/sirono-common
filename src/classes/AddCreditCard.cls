//Mohan Kumar 2016-08-12: Convert the amount in cents before sending it to Sirono
public with sharing class AddCreditCard {
    public String username {get; set;}
    public String password {get; set;}
    
    public String guarantorId {get;set;}
    public String guarantorName {get;set;}
    public String chargegroupId {get;set;}
    
    public String planType {get;set;}
    public String planValue {get;set;}
    public String amount {get;set;}
    public String promiseAmount {get;set;}
    public String executeOnDay {get;set;}
    public String cardHolderName {get;set;}
    public String expirationYear {get;set;}
    public String expirationMonth {get;set;}
    public String creditCardNumber {get;set;}
    public String CVV {get;set;}
    public String state {get;set;}
    public String zip {get;set;}
    public String address {get;set;}
    public String city {get;set;}
    public String responseBody = '';
    public List<SelectOption> paymentPlanTypeOptions {
        get{
            if(paymentPlanTypeOptions == null){
                paymentPlanTypeOptions = new List<SelectOption>();
                paymentPlanTypeOptions.add(new SelectOption('auto','Auto Draft'));
                paymentPlanTypeOptions.add(new SelectOption('promise','Promise To Pay'));
            }
            return paymentPlanTypeOptions;
        }
        protected set;
    }
    
    public String guarantorRecordId {get; set;}
    public Boolean chargeGroupsSelected {get; set;} 
    public List<ChargeGroupWrapper> chrageGroupList {get; set;} 
    
    public List<SelectOption> expYearOptions {
        get{
            if(expYearOptions == null){
                expYearOptions = PayStaffWSUtill.expYearOptions;
            }
            return expYearOptions;
        }
        protected set;
    }
    
    public List<SelectOption> expMonthOptions {
        get{
            if(expMonthOptions == null){
                expMonthOptions = PayStaffWSUtill.expMonthOptions;
            }
            return expMonthOptions;
        }
        protected set;
    }
    
    public AddCreditCard(){
        username = PayStaffWSUtill.un;
        password = PayStaffWSUtill.pw;
        guarantorRecordId = null;
        chargeGroupsSelected = false;
        chrageGroupList = new List<ChargeGroupWrapper>();
        guarantorName = '';
        planType = null;
        if(Apexpages.currentPage().getParameters().containsKey('guarantorId')){
            guarantorRecordId = Apexpages.currentPage().getParameters().get('guarantorId');
            Contact gc = PayStaffWSUtill.fetchGuarantorContact(guarantorRecordId);
            guarantorName = PayStaffWSUtill.fetchGuarantorName(gc);
            guarantorId = PayStaffWSUtill.fetchGuarantorId(gc);
            //chrageGroupList = PayStaffWSUtill.fetchChargeGroupList(gc);
            for(ChargeGroupWrapper cgw : PayStaffWSUtill.fetchChargeGroupList(gc)){
                if(cgw.cg.Active__c && cgw.cg.Reported_Selfpay_Balance__c != 0){
                    chrageGroupList.add(cgw);
                }
            }
            chargegroupId = '';
        }
        planValue = '32772';
        /*guarantorId = '141623';
        chargegroupId = '1072113, 1064709, 1054046';
        planType = 'auto';
        planValue = '32772';
        amount = '500';
        executeOnDay = '13';
        cardHolderName = 'Joe Schmoe';
        expirationYear = '2016';
        expirationMonth = '09';
        creditCardNumber = '4012888888881881';
        CVV = '345';
        state = 'TX';
        zip = '78701';
        address = '1100 E 6th';
        city = 'Austin';
        */  
    }
    
    public Pagereference doNext(){
        chargeGroupsSelected = false;
        chargegroupId = PayStaffWSUtill.fetchChargeGroupIds(chrageGroupList);
        if(!isEmpty(chargegroupId)){
            chargeGroupsSelected = true;
        }/*else{
            chargeGroupsSelected = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Please select atleast one Charge Group'));
        }*/
        return null;
    }
    
    public Pagereference doNothing(){
        return null;
    }
    
    private Boolean isEmpty(String str){
        return (str == null || str.trim().equals(''));
    }
    
    public Pagereference doCancel(){
        Pagereference pg = null;
        if(!isEmpty(guarantorRecordId)){
            pg = new Pagereference('/'+guarantorRecordId);
        }else{
            pg = new Pagereference('/home/home.jsp');
        }
        if(pg!=null){
            pg.setRedirect(true);
        }
        return pg;
    }
    
    public void doSubmit(){ 
        try {
            if(!isEmpty(guarantorId) && !isEmpty(chargegroupId) && !isEmpty(planType) && !isEmpty(planValue) 
                && ((planType.trim().equalsIgnoreCase('promise') && !isEmpty(promiseAmount)) 
                    || (!isEmpty(amount) && !isEmpty(executeOnDay)
                        && !isEmpty(cardHolderName) && !isEmpty(expirationYear) && !isEmpty(expirationMonth)
                        && !isEmpty(creditCardNumber) && !isEmpty(CVV) && !isEmpty(state)
                        && !isEmpty(zip) && !isEmpty(address) && !isEmpty(city)))){
                String jwt_token = PayStaffWSUtill.getJWT_Token(username, password);
                String csrf_token = PayStaffWSUtill.getCSRF_Token();
                if(csrf_token != null && jwt_token != null){
                    doAddCreditCard(csrf_token, jwt_token);
                }
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Please provide all details.'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'guarantorId: '+guarantorId
                    +' chargegroupId: '+chargegroupId +' planType: '+planType
                    +' planValue: '+planValue +' amount: '+amount
                    +' executeOnDay: '+executeOnDay +' cardHolderName: '+cardHolderName
                    +' expirationYear: '+expirationYear +' expirationMonth: '+expirationMonth
                    +' creditCardNumber: '+creditCardNumber +' CVV: '+CVV
                    +' state: '+state +' zip: '+zip
                    +' address: '+address +' city: '+city
                    ));
            }
        } catch(Exception e) { 
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'ERROR: ' + e.getMessage()));
        }
    }
    
    private void doAddCreditCard(String csrfToken, String jwtToken) {
        String request_data = '{"csrfmiddlewaretoken":"' + csrfToken + '",';
        if(planType != null && planType.trim().equalsIgnoreCase('auto')){
            planValue = '32772';
            request_data += '"plan_type":"' + planType + '",' +
            '"plan_value":' + planValue + ',' +
            '"installment_amount":' + PayStaffWSUtill.convertToCents(amount) + ',' +
            '"execute_on_day":' + executeOnDay + ',' +
            '"chargegroups": ' + PayStaffWSUtill.buildChargeGroupsURL(chargegroupId) + ',' +
            '"guarantor":"' + SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/guarantors/' + guarantorId + '/",' +
            '"active":true,' +
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
        }else if(planType != null && planType.trim().equalsIgnoreCase('promise')){
            planValue = '1700';
            request_data += '"plan_type":"' + planType + '",' +
            '"plan_value":' + planValue + ',' +
            '"installment_amount":' + PayStaffWSUtill.convertToCents(promiseAmount) + ',' +
            '"chargegroups": ' + PayStaffWSUtill.buildChargeGroupsURL(chargegroupId) + ',' +
            '"guarantor":"' + SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/guarantors/' + guarantorId + '/",' +
            '"active":true}';
        }    
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
    
        Http http = new Http();
             
        req.setMethod('POST');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(SironoSettingsUtil.getServerEndpoint()+'/paystaff/api/paymentplan/');
        req.setBody(request_data);
        
        
        //For APEX Test
        if (!Test.isRunningTest()){
            try {
                res = http.send(req);
                responseBody = res.getBody();
                //TestResponse();
                System.debug('responseBody' + responseBody);
                ParseResponse(responseBody);
            } catch(Exception e) {
                // Debug error response
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'PROCESS PAYMENT EXCEPTION RESPONSE : '+ res.toString() + '  RESPONSE BODY::' + responseBody + ' EXCEPTION:: ' + e.getMessage()));
            }
        }else{
            res.setStatus('CREATED');
            res.setStatusCode(201);
        }
        
        /*if(res.getStatus() != null && res.getStatus().trim().equalsIgnoreCase('CREATED')
            && res.getStatusCode() != null && res.getStatusCode() == 201){
            System.debug('RESPONSE : '+ res.toString() + '  RESPONSE BODY::' + responseBody);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'Created Successfully!'));
        }else{
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'CSRF_Token : '+ csrfToken));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'JWT_Token : '+ jwtToken));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'RESPONSE : '+ res.toString() + '  RESPONSE BODY::' + responseBody));
        }*/
    }
    
    
    Public void ParseResponse(String jsonStr){
        JSONParser parser = JSON.createParser(jsonStr);
        wrapperPaymentPlan  wrpPaymentPlanobj  = (wrapperPaymentPlan)parser.readValueAs(wrapperPaymentPlan.class);
        System.debug('url: '+wrpPaymentPlanobj.url);
        String planId;
        Integer SironoId;
        List<String> splitURL = wrpPaymentPlanobj.url.split('paymentplan');
        if(splitURL.size() == 2) planId = splitURL[1];
        if(planId != null) {
        	planId = planId.replaceAll('/', '');
        	planId = PayStaffWSUtill.trimCommas(planId);
        	SironoId = Integer.valueOf(planId);
        }
        System.debug(':planId: '+planId);
        test__c PaymentPlanObj = new test__c();
        PaymentPlanObj.Name = planId;
        PaymentPlanObj.Sirono_ID__c = SironoId;
        PaymentPlanObj.Active__c = wrpPaymentPlanobj.active;
        PaymentPlanObj.Installment_Amount__c = PayStaffWSUtill.convertToDollars(wrpPaymentPlanobj.installment_amount);
        PaymentPlanObj.Number_of_Installments__c = wrpPaymentPlanobj.number_installments;
        PaymentPlanObj.Plan_Value__c = PayStaffWSUtill.convertToDollars(wrpPaymentPlanobj.plan_value);
        PaymentPlanObj.Plan_Type__c = (wrpPaymentPlanobj.plan_type == 'auto') ? 'Automatic' : wrpPaymentPlanobj.plan_type;
        PaymentPlanObj.Payable_Amount__c = PayStaffWSUtill.convertToDollars(wrpPaymentPlanobj.payable_amount);
        PaymentPlanObj.Execute_on_Day__c = wrpPaymentPlanobj.execute_on_day;
        if(!String.Isblank(wrpPaymentPlanobj.next_payment_date)){
            PaymentPlanObj.NextPaymentDate__c = Date.valueof(wrpPaymentPlanobj.next_payment_date);
        }
        PaymentPlanObj.Has_Error__c = wrpPaymentPlanobj.has_error;
        if(!String.Isblank(wrpPaymentPlanobj.error_date)){
            PaymentPlanObj.Error_Date__c = Date.valueof(wrpPaymentPlanobj.error_date);
        }
        PaymentPlanObj.Delinquent__c = wrpPaymentPlanobj.delinquent;
        if(wrpPaymentPlanobj.delinquent_date != null){
            PaymentPlanObj.Delinquent_Date__c = wrpPaymentPlanobj.delinquent_date;
        }
        PaymentPlanObj.Guarantor_Name__c = guarantorRecordId;
        System.debug('PaymentPlanObj: '+PaymentPlanObj);
        insert PaymentPlanObj;
        
        List<Charge_Group__c> lstCG  = new List<Charge_Group__c>();
        
        for(ChargeGroupWrapper cgw : chrageGroupList){
            if(cgw.isSelected){
                cgw.cg.Account_Sub_Status__c = 'Payment Plan'; 
                lstCG.add(cgw.cg);  
            }
        }
        
        Update lstCG;
    }
    
    Public void TestResponse(){
        responseBody =        '{'+
        '   "url": "http://127.0.0.1:8000/paystaff/api/paymentplan/2876/",'+
        '   "active": true,'+
        '   "installment_amount": 5000,'+
        '   "number_installments": 7,'+
        '   "plan_value": 32772,'+
        '   "plan_type": "auto",'+
        '   "payable_amount": 32772,'+
        '   "execute_on_day": 13,'+
        '   "guarantor": "http://127.0.0.1:8000/paystaff/api/guarantors/141623/",'+
        '   "next_payment_date": "2016-05-13",'+
        '   "installments_paid": 0,'+
        '   "installments_total": 7,'+
        '   "credit_card": {'+
        '       "card_type": "Visa",'+
        '       "last_4": "1881"'+
        '   },'+
        '   "has_error": false,'+
        '   "charges_added_since_start": null,'+
        '   "error_date": null,'+
        '   "chargegroups": ["http://127.0.0.1:8000/paystaff/api/chargegroups/1072113/", "http://127.0.0.1:8000/paystaff/api/chargegroups/1064709/", "http://127.0.0.1:8000/paystaff/api/chargegroups/1054046/"],'+
        '   "delinquent": false,'+
        '   "delinquent_date": null,'+
        '   "encounters": [],'+
        '   "authorized_amount": 0'+
        '}';
    
    }
    
    
    //Create a wrapperclass to parse a response    
    Public class wrapperPaymentPlan{        
        public String url;  //http://127.0.0.1:8000/paystaff/api/paymentplan/2876/
        public boolean active;
        public Decimal installment_amount;  //5000
        public Integer number_installments; //7
        public Decimal plan_value;  //32772
        public String plan_type;    //auto
        public Decimal payable_amount;  //32772
        public Integer execute_on_day;  //13
        public String guarantor;    //http://127.0.0.1:8000/paystaff/api/guarantors/141623/
        public String next_payment_date;    //2016-05-13
        public Integer installments_paid;   //0
        public Integer installments_total;  //7
        public boolean has_error;
        public String charges_added_since_start;
        public String error_date;
        public boolean delinquent;
        public date delinquent_date ;
        public Integer authorized_amount;   //0
    }
    
    
}