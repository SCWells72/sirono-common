/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 05-02-2016
 * @ PayStaffWSUtill class to contain all common methods for PayStaff Web service
 * @ Date: 21/09/2016 tracker # 130677929 method to filter Charge Groups based on Account sub status 
 * 10-18-2016: Viraj Rana - Tracker # 129073825: Take Payment in SF
 * 10-18-2016: Viraj Rana - Tracker # 129073861: Take Discount/Adjustment in SF 
 */

public with sharing class PayStaffWSUtill {
	
	public PayStaffWSUtill() {
    
    }
    /*
    //TODO replace use of endpoint with SironoSettingsUtil.getServerEndpoint()
    // @deprecated
    public static final String ENDPOINT = Label.PayStaffEndPointURL;
    public static final String STMTURL = '{0}/paystaff/api/guarantors/{1}/statements/';
    public static final String UN = 'sgullapali';
    public static final String PW = 'p@ssw0rd';
    
    //11-23-2016: Viraj Rana - Tracker # 129073825: Take Payment in SF
    //It is used to verified that Charge Group have longer Payment Plan Look up or not.
    static boolean hasChargeGroupPaymentPlan = false;

    //get the current + 10 Years list
    public static List<SelectOption> expYearOptions {
        get {
            if (expYearOptions == null) {
                expYearOptions = new List<SelectOption>();
                Integer currentYear = System.today().year();
                for (Integer i = 0; i <= 10; i++) {
                    String value = String.valueOf(currentYear++);
                    expYearOptions.add(new SelectOption(value, value));
                }
            }
            return expYearOptions;
        }
        protected set;
    }

    //get the All month list
    public static List<SelectOption> expMonthOptions {
        get {
            if (expMonthOptions == null) {
                expMonthOptions = new List<SelectOption>();
                expMonthOptions.add(new SelectOption('01', '01 (January)'));
                expMonthOptions.add(new SelectOption('02', '02 (February)'));
                expMonthOptions.add(new SelectOption('03', '03 (March)'));
                expMonthOptions.add(new SelectOption('04', '04 (April)'));
                expMonthOptions.add(new SelectOption('05', '05 (May)'));
                expMonthOptions.add(new SelectOption('06', '06 (June)'));
                expMonthOptions.add(new SelectOption('07', '07 (July)'));
                expMonthOptions.add(new SelectOption('08', '08 (August)'));
                expMonthOptions.add(new SelectOption('09', '09 (September)'));
                expMonthOptions.add(new SelectOption('10', '10 (October)'));
                expMonthOptions.add(new SelectOption('11', '11 (November)'));
                expMonthOptions.add(new SelectOption('12', '12 (December)'));
            }
            return expMonthOptions;
        }
        protected set;
    }
    //get the Guarantor contact with charge groups
    public static Contact fetchGuarantorContact(String contactId) {
        Contact ob = null;
        for (Contact c : [
                Select Id, FirstName, MiddleName, LastName, Suffix, Birthdate,
                        Medical_Record_Number__c, Name,
                        Profile_Pointer_Id__c, MailingStreet,
                        MailingCity, MailingState, MailingPostalCode, (
                        Select Id, Name, Charge_Group_ID__c, Guarantor_Name__c, Guarantor_Name__r.Name,
                                Account_Number__c, Active__c, Reported_Insurance_Balance__c, Reported_Prebill_Balance__c,
                                Reported_Selfpay_Balance__c, Patient_Name__c, Patient_Name__r.Name,
                                Account_Type__c, Date_Of_Service_Start_Date__c, Date_Of_Service_End_Date__c,
                                Balance__c, Invoice__c, Invoice__r.Name, Invoice__r.Invoice_Date__c, Account_Status__c,
                                Provider__c, Provider__r.Name, Location__c, Location__r.Name, Account_Sub_Status__c
                        From Charge_Groups__r
                        Where Charge_Group_ID__c != null AND Active__c = true
                )
                From Contact
                Where Id = :contactId
        ]) {
            ob = c;
        }
        return ob;
    }

    //Fetch the contact record
    public static Contact fetchContact(String contactId) {
        Contact ob = null;
        for (Contact c : [
                Select Id, FirstName, MiddleName, LastName, Name, Suffix, Birthdate, Social_Security_Number__c,
                        Medical_Record_Number__c, RecordType.DeveloperName, HomePhone, MobilePhone, OtherPhone, Salutation,
                        MailingCity, MailingCountry, MailingPostalCode, MailingState, MailingStreet,
                        Profile_Pointer_Id__c
                From Contact
                Where Id = :contactId
        ]) {
            ob = c;
        }
        return ob;
    }

    /*Mohan Kumar 07-28-2016: This is method is used in AddToPaymentPlan to filter the Charge Group based
    *on the Status and Sub-Status rather than pulling all active ones
    *
    public static Contact fetchGuarantorContactWithCGConstraints(String contactId) {
        Contact ob = null;
        for (Contact c : [
                Select Id, Name, FirstName, MiddleName, LastName, Suffix, Birthdate, Salutation,
                        Medical_Record_Number__c, RecordType.DeveloperName, Social_Security_Number__c,
                        Profile_Pointer_Id__c, Patient_Id__c, HomePhone, MobilePhone, OtherPhone,
                        MailingCity, MailingCountry, MailingPostalCode, MailingState, MailingStreet, (
                        Select Id, Name, Charge_Group_ID__c, Guarantor_Name__c, Guarantor_Name__r.Name,
                                Account_Number__c, Active__c, Reported_Insurance_Balance__c, Reported_Prebill_Balance__c,
                                Reported_Selfpay_Balance__c, Patient_Name__c, Patient_Name__r.Name,
                                Account_Type__c, Date_Of_Service_Start_Date__c, Date_Of_Service_End_Date__c,
                                Balance__c, Invoice__c, Invoice__r.Name, Invoice__r.Invoice_Date__c, Account_Status__c,
                                Account_Sub_Status__c, Provider__c, Provider__r.Name, Location__c, Location__r.Name
                        From Charge_Groups__r
                        Where Charge_Group_ID__c != null AND Active__c = true AND Account_Status__c = 'Billed'
                        AND Account_Sub_Status__c IN ('Preinvoiced', 'Due', 'Overdue', 'Delinquent', 'Bad Debt')
                )
                From Contact
                Where Id = :contactId
        ]) {
            ob = c;
        }
        return ob;
    }

    public static Contact fetchGuarantorContactWithCGConstraintsForCase(String contactId) {
        Contact ob = null;
        for (Contact c : [
                Select Id, Name, FirstName, MiddleName, LastName, Suffix, Birthdate, Salutation,
                        Medical_Record_Number__c, RecordType.DeveloperName, Social_Security_Number__c,
                        Profile_Pointer_Id__c, Patient_Id__c, HomePhone, MobilePhone, OtherPhone,
                        MailingCity, MailingCountry, MailingPostalCode, MailingState, MailingStreet, (
                        Select Id, Name, Charge_Group_ID__c, Guarantor_Name__c, Guarantor_Name__r.Name,
                                Account_Number__c, Active__c, Reported_Insurance_Balance__c, Reported_Prebill_Balance__c,
                                Reported_Selfpay_Balance__c, Patient_Name__c, Patient_Name__r.Name,
                                Account_Type__c, Date_Of_Service_Start_Date__c, Date_Of_Service_End_Date__c,
                                Balance__c, Invoice__c, Invoice__r.Name, Invoice__r.Invoice_Date__c, Account_Status__c,
                                Account_Sub_Status__c, Provider__c, Provider__r.Name, Location__c, Location__r.Name
                        From Charge_Groups__r
                        Where Charge_Group_ID__c != null AND Active__c = true AND Account_Status__c = 'Billed'
                        AND Account_Sub_Status__c IN ('Preinvoiced', 'Due', 'Overdue', 'Delinquent', 'Payment Plan', 'Bad Debt')
                )
                From Contact
                Where Id = :contactId
        ]) {
            ob = c;
        }
        return ob;
    }

    //08-09-2016: This is method is used to get the CG records of Patient Contact type
    public static Contact fetchPatientContactWithCGConstraints(String contactId) {
        Contact ob = null;
        for (Contact c : [
                Select Id, FirstName, MiddleName, LastName, Suffix, Birthdate,
                        Medical_Record_Number__c, RecordType.DeveloperName,
                        Profile_Pointer_Id__c, Patient_Id__c, (
                        Select Id, Name, Charge_Group_ID__c, Guarantor_Name__c, Guarantor_Name__r.Name,
                                Account_Number__c, Active__c, Reported_Insurance_Balance__c, Reported_Prebill_Balance__c,
                                Reported_Selfpay_Balance__c, Patient_Name__c, Patient_Name__r.Name,
                                Account_Type__c, Date_Of_Service_Start_Date__c, Date_Of_Service_End_Date__c,
                                Balance__c, Invoice__c, Invoice__r.Name, Invoice__r.Invoice_Date__c, Account_Status__c,
                                Account_Sub_Status__c, Provider__c, Provider__r.Name, Location__c, Location__r.Name
                        From Charge_Groups_Patient__r
                        Where Charge_Group_ID__c != null AND Active__c = true AND Account_Status__c = 'Billed'
                        AND Account_Sub_Status__c IN ('Preinvoiced', 'Due', 'Overdue', 'Delinquent', 'Bad Debt')
                )
                From Contact
                Where Id = :contactId
        ]) {
            ob = c;
        }
        return ob;
    }

    //08-09-2016: This is method is used to get the CG records of Patient Contact type
    public static Contact fetchPatientContactWithCGConstraintsForCase(String contactId) {
        Contact ob = null;
        for (Contact c : [
                Select Id, FirstName, MiddleName, LastName, Suffix, Birthdate,
                        Medical_Record_Number__c, RecordType.DeveloperName,
                        Profile_Pointer_Id__c, Patient_Id__c, (
                        Select Id, Name, Charge_Group_ID__c, Guarantor_Name__c, Guarantor_Name__r.Name,
                                Account_Number__c, Active__c, Reported_Insurance_Balance__c, Reported_Prebill_Balance__c,
                                Reported_Selfpay_Balance__c, Patient_Name__c, Patient_Name__r.Name,
                                Account_Type__c, Date_Of_Service_Start_Date__c, Date_Of_Service_End_Date__c,
                                Balance__c, Invoice__c, Invoice__r.Name, Invoice__r.Invoice_Date__c, Account_Status__c,
                                Account_Sub_Status__c, Provider__c, Provider__r.Name, Location__c, Location__r.Name
                        From Charge_Groups_Patient__r
                        Where Charge_Group_ID__c != null AND Active__c = true AND Account_Status__c = 'Billed'
                        AND Account_Sub_Status__c IN ('Preinvoiced', 'Due', 'Overdue', 'Delinquent', 'Payment Plan', 'Bad Debt')
                )
                From Contact
                Where Id = :contactId
        ]) {
            ob = c;
        }
        return ob;
    }

    //get the Guarantor Id from pass contact.
    public static String fetchGuarantorId(Contact gc) {
        String guarantorId = '';
        if (gc != null && gc.Profile_Pointer_Id__c != null) {
            guarantorId = String.valueOf(gc.Profile_Pointer_Id__c);
        } else if (Apexpages.currentPage() != null) {
            handleErrorMessages(ApexPages.SEVERITY.ERROR, 'Guarantor Id does not exist!');
        }
        return guarantorId;
    }

    //get the Patient Id from passed contact.
    public static String fetchPatientId(Contact gc) {
        String patientId = '';
        if (gc != null && gc.Patient_Id__c != null) {
            patientId = String.valueOf(gc.Patient_Id__c);
        } else if (Apexpages.currentPage() != null) {
            handleErrorMessages(ApexPages.SEVERITY.ERROR, 'Patient Id does not exist!');
        }
        return patientId;
    }

    //get the Guarantor Name from passed contact.
    public static String fetchGuarantorName(Contact gc) {
        String guarantorName = '';
        guarantorName = gc.FirstName + (gc.MiddleName != null ? ' ' + gc.MiddleName : '')
                + (gc.LastName != null ? ' ' + gc.LastName : '')
                + (gc.Suffix != null ? ' ' + gc.Suffix : '')
                + ' (DOB: ' + (gc.Birthdate != null ? gc.Birthdate.format() : '')
                + ', MRN: ' + (gc.Medical_Record_Number__c != null ? gc.Medical_Record_Number__c : '')
                + ')';
        return guarantorName;
    }

    //get the charge group list
    public static List<ChargeGroupWrapper> fetchChargeGroupList(Contact gc) {
        List<ChargeGroupWrapper> cgList = new List<ChargeGroupWrapper>();
        if (gc != null && gc.Charge_Groups__r != null && gc.Charge_Groups__r.size() > 0) {
            for (Charge_Group__c cg : gc.Charge_Groups__r) {
                cgList.add(new ChargeGroupWrapper(cg, false));
            }
        }
        return cgList;
    }

    //get the charge group list based on the record type
    public static List<ChargeGroupWrapper> fetchChargeGroupList(Contact gc, String recordType) {
        List<ChargeGroupWrapper> cgList = new List<ChargeGroupWrapper>();
        if (gc != null && gc.Charge_Groups__r != null && gc.Charge_Groups__r.size() > 0 && recordType == 'Guarantor') {
            for (Charge_Group__c cg : gc.Charge_Groups__r) {
                cgList.add(new ChargeGroupWrapper(cg, false));
            }
        } else if (gc != null && gc.Charge_Groups_Patient__r != null
                && gc.Charge_Groups_Patient__r.size() > 0 && recordType == 'Patient') {
            for (Charge_Group__c cg : gc.Charge_Groups_Patient__r) {
                cgList.add(new ChargeGroupWrapper(cg, false));
            }
        }
        return cgList;
    }

    //get the all charge group ids with commas separted
    public static String fetchChargeGroupIds(List<ChargeGroupWrapper> cgList) {
        String cgIds = '', glue = '';
        if (cgList != null && cgList.size() > 0) {
            for (ChargeGroupWrapper cg : cgList) {
                if (cg.isSelected) {
                    cgIds += glue + cg.cg.Charge_Group_ID__c;
                    glue = ',';
                }
            }
        }
        return cgIds;
    }

    public static String getJWTToken(String username, String password) {
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        String jwtToken;
        String responseBody;
        req.setMethod('POST');
        req.setEndpoint(SironoSettingsUtil.getServerEndpoint() + '/paystaff/token-auth/');
        req.setBody('username=' + username + '&password=' + password);

        try {
            res = http.send(req);
            responseBody = res.getBody();
            TokenAuthResponse tokenRes = (TokenAuthResponse) JSON.deserializeStrict(responseBody, TokenAuthResponse.class);
            jwtToken = tokenRes.token;
        } catch (Exception e) {
            // Debug error response
            handleErrorMessages(ApexPages.SEVERITY.ERROR, 'JWT EXCEPTION RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody + ' EXCEPTION:: ' + e.getMessage());
        }

        return jwtToken;
    }

    public static String getCSRFToken() {
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        String csrfToken = '';
        String responseBody;
        req.setMethod('GET');
        req.setEndpoint(SironoSettingsUtil.getServerEndpoint() + '/portal/account/forgot-password/');

        try {
            res = http.send(req);
            responseBody = res.getBody();
            String strToCheck = '<input type=\'hidden\' name=\'csrfmiddlewaretoken\' value=\'';
            if (responseBody.indexOf(strToCheck) > 0) {
                Integer startIndex = responseBody.indexOf(strToCheck) + strToCheck.length();
                csrfToken = responseBody.substring(startIndex, responseBody.indexOf('\'', startIndex));
            }
        } catch (Exception ex) {
            // Debug error response
            handleErrorMessages(ApexPages.SEVERITY.ERROR, 'CSRF TOKEN EXCEPTION RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody + ' EXCEPTION:: ' + ex.getMessage());
        }
        return csrfToken;
    }

    public static String buildChargeGroupsURL(List<String> chargeGroupIds) {
        String urlToReturn = '[';
        String glue = '';
        if (chargeGroupIds != null) {
            for (String cgId : chargeGroupIds) {
                cgId = cgId.trim();
                urlToReturn += glue + '"' + SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/chargegroups/' + cgId + '/"';
                glue = ',';
            }
        }
        return urlToReturn += ']';
    }


    public static String buildChargeGroupsURL(String chargeGroupIds) {
        String urlToReturn = '[';
        String glue = '';
        if (chargeGroupIds != null) {
            for (String cgId : chargeGroupIds.split(',')) {
                cgId = cgId.trim();
                urlToReturn += glue + '"' + SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/chargegroups/' + cgId + '/"';
                glue = ',';
            }
        }
        return urlToReturn += ']';
    }

    @Future(callout=true)
    public static void addNoteFuture(List<String> chargeGroupIds, String noteText) {
        addNoteWSCallout(chargeGroupIds, noteText);
    }

    public static void addNoteWSCallout(List<String> chargeGroupIds, String noteText) {
        try {
            if (!chargegroupIds.isEmpty() && !isEmpty(noteText)) {
                String jwtToken = getJWTToken(UN, PW);
                String csrfToken = getCSRFToken();
                if (csrfToken != null && jwtToken != null) {
                    String requestData = '{"csrfmiddlewaretoken":"' + csrfToken + '",' +
                            '"chargegroups": ' + buildChargeGroupsURL(chargegroupIds) + ',' +
                            '"text":"' + noteText + '"' +
                            '}';

                    HttpRequest req = new HttpRequest();
                    HttpResponse res = new HttpResponse();
                    Http http = new Http();
                    String responseBody;
                    req.setMethod('POST');
                    req.setHeader('Authorization', 'JWT ' + jwtToken);
                    req.setHeader('Content-type', 'application/json');
                    req.setEndpoint(SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/chargegroupnotes/');
                    req.setBody(requestData);
                    try {
                        res = http.send(req);
                        responseBody = res.getBody();
                        if (test.isRunningTest()) {
                            TestUtility.generateException();
                        }
                    } catch (Exception e) {
                        // Debug error response
                        handleErrorMessages(ApexPages.SEVERITY.ERROR, 'PROCESS PAYMENT EXCEPTION RESPONSE : ' +
                                res.toString() + '  RESPONSE BODY::' + responseBody + ' EXCEPTION:: ' + e.getMessage());
                    }

                    if (res.getStatus() != null && res.getStatus().trim().equalsIgnoreCase('CREATED')
                            && res.getStatusCode() != null && res.getStatusCode() == 201) {
                        System.debug('RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody);
                        handleErrorMessages(ApexPages.SEVERITY.INFO, 'Created Successfully!');
                    } else {
                        handleErrorMessages(ApexPages.SEVERITY.INFO, 'CSRF_Token : ' + csrfToken);
                        handleErrorMessages(ApexPages.SEVERITY.INFO, 'JWT_Token : ' + jwtToken);
                        handleErrorMessages(ApexPages.SEVERITY.ERROR, 'RESPONSE : ' + res.toString()
                                + '  RESPONSE BODY::' + responseBody);
                    }
                }
            } else {
                handleErrorMessages(ApexPages.SEVERITY.ERROR, 'Please provide all details.');

            }
            if (test.isRunningTest()) {
                TestUtility.generateException();
            }
        } catch (Exception e) {
            // Debug error response
            handleErrorMessages(ApexPages.SEVERITY.ERROR, 'ERROR: ' + e.getMessage());
        }
    }

    public static String getPaystaffUserName() {
        //placeholder - should get the creds from the current user
        return UN;
    }

    public static String getPaystaffPassword() {
        //placeholder - should get the creds from the current user
        return PW;
    }

    public static HttpResponse getStatementUrls(String guarantorId) {
        //Make sure there aren't any commas in the guarantor id
        String fullUrl = String.format(STMTURL,
                new String[]{
                        SironoSettingsUtil.getServerEndpoint(),
                        guarantorId.replace(',', '')
                });

        String jwtToken = getJWTToken(getPaystaffUserName(), getPaystaffPassword());
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(fullUrl);
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');

        Http http = new Http();
        return http.send(req);
    }

    public static Boolean isEmpty(String str) {
        return (str == null || str.trim().equals(''));
    }

    public static void handleErrorMessages(ApexPages.severity messageSeverity, String messageText) {
        if (Apexpages.currentPage() != null) {
            ApexPages.addMessage(new ApexPages.Message(messageSeverity, messageText));
        } else {
            System.debug('[' + messageSeverity + '] ' + messageText);
        }
    }

    /*Mohan Kumar 07-28-2016: Convert the amount in cents before sending it to Sirono on Take Payment, 
    *Add Adjustment, Add Discount actions
    *
    public static String convertToCents(String amount) {
        String centAmount = (String.isNotBlank(amount) ? String.valueOf(Decimal.valueOf(amount) * 100) : amount);
        System.debug('converted cent amount: ' + centAmount);
        return centAmount;
    }

    //Mohan Kumar 08-18-2016: Convert the amount in dollars
    public static Decimal convertToDollars(Decimal amount) {
        Decimal dollarAmount = (amount != null ? (amount / 100) : amount);
        System.debug('converted cent amount: ' + dollarAmount);
        return dollarAmount;
    }
    
    //Viraj Rana 11-15-2016: Convert the amount in dollars with divided by -100.
    //It is used for covert Transaction Amount.
    public static Decimal convertToDollarsWithNegative(Decimal amount) {
        Decimal dollarAmount = (amount != null ? (amount/-100) : amount);
        System.debug('converted cent amount with divided by -100: '+ dollarAmount);
        return dollarAmount;
    }

    //Convert the amount from cents to dollars
    public static String convertToDollars(String cents) {
        String dollarAmount = String.isBlank(cents) ? cents : String.valueOf(Decimal.valueOf(cents).divide(100, 2));
        System.debug('converted: ' + cents + ' cents to dollar amount: ' + dollarAmount);
        return dollarAmount;
    }
    /*Mohan Kumar 07-28-2016: Convert the amount in cents before sending it to Sirono on Take Payment, 
    *Add Adjustment, Add Discount actions
    *
    public static String trimCommas(String val) {
        return (String.isNotBlank(val) ? val.replaceAll(',', '') : val);
    }

    public class TokenAuthResponse {
        public String token { get; set; }
    }

    //fetch ChargeGroupList based on account sub status.
    public static List<ChargeGroupWrapper> fetchChargeGroupListByAccountSubStatus(Contact gc) {
        List<ChargeGroupWrapper> cgList = new List<ChargeGroupWrapper>();
        if (gc != null && gc.Charge_Groups__r != null && gc.Charge_Groups__r.size() > 0) {
            for (Charge_Group__c cg : gc.Charge_Groups__r) {
                if (cg.Account_Sub_Status__c == 'Preinvoiced' || cg.Account_Sub_Status__c == 'Due' || cg.Account_Sub_Status__c == 'Overdue'
                        || cg.Account_Sub_Status__c == 'Delinquent' || cg.Account_Sub_Status__c == 'Bad Debt' || cg.Account_Sub_Status__c == 'Payment Plan') {

                    cgList.add(new ChargeGroupWrapper(cg, false));
                }
            }
        }
        return cgList;
    }
    
    //11-15-2016: Viraj Rana - Tracker # 129073861: Take Discount/Adjustment in SF.
    //This wrapper class is used whenever Adjustment/Discount occures.
    public class PaymentAdjustmentwrapper {
        Transaction__c objTransaction = new Transaction__c();
        Charge_Group__c objChargeGroup = new Charge_Group__c();
        test__c objPaymentPlan = new test__c();
    }
    
     /*
    * 10-18-2016: Viraj Rana - Tracker # 129073825: Take Payment in SF
    * 10-18-2016: Viraj Rana - Tracker # 129073861: Take Discount/Adjustment in SF
    * Parse Payment response and call Transaction Request.
    *
    public static void parsePaymentReponse(String csrfToken, String jwtToken, string jsonStr, boolean isPayment){
        
        Payment__c objPayment;
        List<Payment_Adjustments__c> lstPaymentAdjustment = new List<Payment_Adjustments__c>();
        PaymentAdjustmentwrapper objPaymentAdjustmentwrapper = new PaymentAdjustmentwrapper();
        
        List<Transaction__c> lstTransaction = new List<Transaction__c>();
        List<Charge_Group__c> lstChargeGroup = new List<Charge_Group__c>();
        List<test__c> lstPaymentPlan = new List<test__c>();
        Map<Decimal,Decimal> mapTranPayAdjId = new Map<Decimal,Decimal>();
        
        if (isPayment) {
            objPayment = new Payment__c();
            objPayment = PaymentJSONParsing.parse(jsonStr);
        } else {
            lstPaymentAdjustment = PaymentAdjustmentJSONParsing.parse(jsonStr);
        }

        if (objPayment != null) {
            callTransactionRequest(csrfToken, jwtToken, objPayment, null, isPayment);
        } else if (lstPaymentAdjustment.size() > 0) {
            for (Payment_Adjustments__c objPaymentAdjustment : lstPaymentAdjustment) {
                objPaymentAdjustmentwrapper = callTransactionRequest(csrfToken, jwtToken, null, objPaymentAdjustment, isPayment);
                
                lstTransaction.add(objPaymentAdjustmentwrapper.objTransaction);
                mapTranPayAdjId.put(objPaymentAdjustment.ID__c, objPaymentAdjustmentwrapper.objTransaction.ID__c);
                
                lstChargeGroup.add(objPaymentAdjustmentwrapper.objChargeGroup);
                objPaymentAdjustment.Charge_Group_Name__c = objPaymentAdjustmentwrapper.objChargeGroup.Id;
                
                if (objPaymentAdjustmentwrapper.objPaymentPlan.id != null) {
                    lstPaymentPlan.add(objPaymentAdjustmentwrapper.objPaymentPlan);
                }
            }
            
            //Save all Records if it is Take Adjustment/Discount. 
            if (lstChargeGroup.size() > 0) {
                update lstChargeGroup;
            }
            
            if (lstPaymentPlan.size() > 0) {
                update lstPaymentPlan;
            }
            
            if (lstTransaction.size() > 0) {
                insert lstTransaction;
                
                List<Transaction__c> lstTran = [SELECT Id, ID__c FROM Transaction__c
                                            where ID__c in : mapTranPayAdjId.values()];
                                            
                map<Decimal, string> mapTran = new map<Decimal, string>();
                for(Transaction__c t : lstTran){
                    mapTran.put(t.ID__c, t.Id);
                }
    
                for(Payment_Adjustments__c pa : lstPaymentAdjustment) {
                    decimal tranId = mapTranPayAdjId.get(pa.ID__c);
                    pa.Transaction__c = mapTran.get(tranId);
                }
                
                insert lstPaymentAdjustment;
            }
        }
    }

    /*
    * 10-18-2016: Viraj Rana - Tracker # 129073825: Take Payment in SF
    * 10-18-2016: Viraj Rana - Tracker # 129073861: Take Discount/Adjustment in SF
    * call Transaction Request and get all Transactions based on Payment.
    *
    private static PaymentAdjustmentwrapper callTransactionRequest(String csrfToken, String jwtToken, Payment__c objPayment, Payment_Adjustments__c objPaymentAdjustment, boolean isPayment){
        
        PaymentAdjustmentwrapper objPaymentAdjustmentwrapper = new PaymentAdjustmentwrapper();
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        Http http = new Http();
        String responseBody;

        req.setMethod('GET');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        if (isPayment) {
            req.setEndpoint(SironoSettingsUtil.getServerEndpoint()+'/paystaff/api/payments/'
                        + string.valueof(objPayment.ID__c) +'/transactions/');
        } else {
            req.setEndpoint(SironoSettingsUtil.getServerEndpoint()+'/paystaff/api/adjustments/'
                        + string.valueof(objPaymentAdjustment.ID__c) +'/transactions/');
        }
        
        req.setTimeout(120000);
        try {
            res = http.send(req);
            responseBody = res.getBody();
            system.debug('StatusCode : ' + res.getStatusCode());
            system.debug('Transaction Response : ' + responseBody);

            if(Test.isRunningTest()){
                res.setStatusCode(TestUtility.statusCode2);
                TestUtility.generateException();
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'TRANSACTION EXCEPTION RESPONSE : '+ res.toString() +
                    '  RESPONSE BODY::' + responseBody + ' EXCEPTION:: ' + e.getMessage()));
        }

        if (res.getStatusCode() != null && res.getStatusCode() == 200) {
            objPaymentAdjustmentwrapper = parseTransactionResponse(csrfToken, jwtToken, responseBody, objPayment, objPaymentAdjustment, isPayment);
        }else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                                    'RESPONSE : '+ res.toString() +
                                    '  RESPONSE BODY::' + responseBody));
        }
        return objPaymentAdjustmentwrapper;
    }

    /*
    * 10-18-2016: Viraj Rana - Tracker # 129073825: Take Payment in SF
    * 10-18-2016: Viraj Rana - Tracker # 129073861: Take Discount/Adjustment in SF
    * Parse Transaction response and based on Charge group call Charge group request.
    *
    private static PaymentAdjustmentwrapper parseTransactionResponse(String csrfToken, String jwtToken, string jsonStr, Payment__c objPayment, Payment_Adjustments__c objPaymentAdjustment, boolean isPayment){
        TransactionJSONParsing.TransactionWrapper objTransactionWrapper;
        objTransactionWrapper = TransactionJSONParsing.parse(jsonStr);
                
        List<Transaction__c> lstTransaction = new List<Transaction__c>();
        List<Charge_Group__c> lstChargeGroup = new List<Charge_Group__c>();
        List<test__c> lstPaymentPlan = new List<test__c>();
        
        PaymentAdjustmentwrapper objPaymentAdjustmentwrapper = new PaymentAdjustmentwrapper();
        
        if (objTransactionWrapper != null) {
            if (objTransactionWrapper.transactionRecords.size() > 0) {
                system.debug('Transaction record size : ' + objTransactionWrapper.transactionRecords.size());
                system.debug('Transaction records : ' + objTransactionWrapper.transactionRecords);
                lstTransaction = objTransactionWrapper.transactionRecords;
            }
            if (objTransactionWrapper.chargeGroupRecords.size() > 0) {
                system.debug('Charge Group record size : ' + objTransactionWrapper.chargeGroupRecords.size());
                system.debug('Charge Group records : ' + objTransactionWrapper.chargeGroupRecords);
                lstChargeGroup = objTransactionWrapper.chargeGroupRecords;

                for (Charge_Group__c cg : lstChargeGroup) {
                    //11-23-2016: Viraj Rana - Tracker # 129073825: Take Payment in SF
                    //Boolean variable set to false for all Charge Group whenever Request made.
                    hasChargeGroupPaymentPlan = true;
                    
                    Charge_Group__c chargeGroup = new Charge_Group__c();
                    chargeGroup = callChargeGroupRequest(String.valueof(cg.Charge_Group_ID__c),jwtToken);
                    
                    if (cg.Account_Sub_Status__c == 'Payment Plan') {
                        test__c objPaymentPlan = new test__c();
                        objPaymentPlan = callPaymentPlanRequest(jwtToken, string.valueof(cg.Payment_Plan__r.Sirono_ID__c),
                           cg.Payment_Plan__r.Guarantor_Name__c);
                        
                        lstPaymentPlan.add(objPaymentPlan);
                    }
                    
                    //11-23-2016: Viraj Rana - Tracker # 129073825: Take Payment in SF
                    //If Charge Group have no longer Payment Plan than set it null.
                    if (!hasChargeGroupPaymentPlan) {
                        cg.Payment_Plan__c = null;
                    }
                    
                    cg.Account_Sub_Status__c = chargeGroup.Account_Sub_Status__c;
                    cg.Account_Status__c = chargeGroup.Account_Status__c;
                }
            }
        }
        //Save all Records if it is Take Payment.
        if (isPayment) {
            insert objPayment;
            id paymentId = objPayment.Id;
    
            if (lsttransaction.size() > 0) {
                for (Transaction__c objTran : lsttransaction) {
                    objTran.Payment_ID__c = paymentId;
                }
                insert lsttransaction;
            }
            
            if (lstChargeGroup.size() > 0) {
                update lstChargeGroup;
            }
    
            if (lstPaymentPlan.size() > 0) {
                update lstPaymentPlan;
            }
        } else {
            //It is used for Adjustment/Discount.
            if (lsttransaction.size() > 0) {
                objPaymentAdjustmentwrapper.objTransaction = lsttransaction[0];
            }
            if (lstChargeGroup.size() > 0) {
                objPaymentAdjustmentwrapper.objChargeGroup = lstChargeGroup[0];
            }
            if (lstPaymentPlan.size() > 0) {
                objPaymentAdjustmentwrapper.objPaymentPlan = lstPaymentPlan[0];
            }
        }
        return objPaymentAdjustmentwrapper;
    }

     /*
    * 10-18-2016: Viraj Rana - Tracker # 129073825: Take Payment in SF
    * 10-18-2016: Viraj Rana - Tracker # 129073861: Take Discount/Adjustment in SF
    * make a Charge group Reqeuest to get the chargeGroupInformation
    *
    private static Charge_Group__c callChargeGroupRequest(String chargeGroupId,String jwtToken) {
        Charge_Group__c chargeGroup = new Charge_Group__c();
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        Http http = new Http();
        String responseBody;

        req.setMethod('GET');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(SironoSettingsUtil.getServerEndpoint()+'/paystaff/api/chargegroups/'
                        +PayStaffWSUtill.trimCommas(chargeGroupId)+'/');

        req.setTimeout(120000);
        try {
            res = http.send(req);
            responseBody = res.getBody();

            if(Test.isRunningTest()){
                res.setStatusCode(TestUtility.statusCode3);
                TestUtility.generateException();
            }
        } catch(Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'ChargeGroup EXCEPTION RESPONSE : '+ res.toString() +
                    '  RESPONSE BODY::' + responseBody + ' EXCEPTION:: ' + e.getMessage()));
        }
        if (res.getStatusCode() != null && res.getStatusCode() == 200) {
            system.debug('Charge Group Response Body : ' + responseBody);
            chargeGroup = parseChargeGroupResponse(responseBody, jwtToken);
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                                    'RESPONSE : '+ res.toString() +
                                    '  RESPONSE BODY::' + responseBody));
        }
        return chargeGroup;
    }

    /*
    * 10-18-2016: Viraj Rana - Tracker # 129073825: Take Payment in SF
    * 10-18-2016: Viraj Rana - Tracker # 129073861: Take Discount/Adjustment in SF
    * Update the Account_Sub_Status__c and Account_Status__c.
    * if Account_Sub_Status__c = Payment Plan than call Payment Plan request.
    *
    private static Charge_Group__c parseChargeGroupResponse(String responseBody, String jwtToken){
        ChargeGroupJSONParsing objChargeGroup = ChargeGroupJSONParsing.parse(responseBody);
        Charge_Group__c cg = new Charge_Group__c();        
        
        cg.Account_Sub_Status__c = objChargeGroup.account_sub_status;
        cg.Account_Status__c = objChargeGroup.account_status;
        
        //11-24-2016: Viraj Rana - Tracker # 129073825: Take Payment in SF
        //It is used to verified that Charge Group have longer Payment Plan Look up or not.
        if (objChargeGroup.paymentplan == null) {
            hasChargeGroupPaymentPlan = false;
        }
        
        return cg;

        /*if(objChargeGroup.account_sub_status == 'Payment Plan'){
            Charge_Group__c objcg = new Charge_Group__c();
            objcg = [select Payment_Plan__c, Payment_Plan__r.Sirono_ID__c, Payment_Plan__r.Guarantor_Name__c
                    from Charge_Group__c where id =: cg.Id limit 1];

            if(objcg != null){
                callPaymentPlanRequest(jwtToken, objcg);
            }
        }*
    }

     /*
    * 10-18-2016: Viraj Rana - Tracker # 129073825: Take Payment in SF
    * 10-18-2016: Viraj Rana - Tracker # 129073861: Take Discount/Adjustment in SF
    *  Call the paymentplan Web Service to get the paymentplan information.
    *
    private static test__c callPaymentPlanRequest(String jwtToken, string paymentPlanExternalId, string guarantorId){
        test__c objPaymentPlan = new test__c();
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        Http http = new Http();
        String responseBody;

        req.setMethod('GET');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(SironoSettingsUtil.getServerEndpoint()+'/paystaff/api/paymentplan/'
                        +PayStaffWSUtill.trimCommas(paymentPlanExternalId)+'/');
        req.setTimeout(120000);
        try {
            res = http.send(req);
            responseBody = res.getBody();

            if(Test.isRunningTest()){
                res.setStatusCode(TestUtility.statusCode2);
                TestUtility.generateException();
            }
        } catch(Exception e) {

        }
        if (res.getStatusCode() != null && res.getStatusCode() == 200) {

            objPaymentPlan = parsePaymentPlanResponse(responseBody, guarantorId);

        }else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                                    'RESPONSE : '+ res.toString() +
                                    '  RESPONSE BODY::' + responseBody));
        }
        return objPaymentPlan;
    }

    /*
    * 10-18-2016: Viraj Rana - Tracker # 129073825: Take Payment in SF
    * 10-18-2016: Viraj Rana - Tracker # 129073861: Take Discount/Adjustment in SF
    * parse the Payment Plan JSON.
    *
    private static test__c parsePaymentPlanResponse(String jsonStr, string guarantorId) {

        PaymentPlanJSONParsing.PaymentPlanWrapper objPaymentPlanWrapper;
        objPaymentPlanWrapper = PaymentPlanJSONParsing.createPaymentPlanRecord(jsonStr,guarantorId,null,null);

        test__c paymentPlanObj = new test__c();
        paymentPlanObj = objPaymentPlanWrapper.paymentPlanRecord;
        
        return paymentPlanObj;
    }*/
}