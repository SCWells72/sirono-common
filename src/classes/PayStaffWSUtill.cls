/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 05-02-2016
 * @ PayStaffWSUtill class to contain all common methods for PayStaff Web service
 * @ Date: 21/09/2016 tracker # 130677929 method to filter Charge Groups based on Account sub status 
 */

public with sharing class PayStaffWSUtill {
    //TODO replace use of endpoint with SironoSettingsUtil.getServerEndpoint()
    // @deprecated
    public static final String ENDPOINT = Label.PayStaffEndPointURL;
    public static final String STMTURL = '{0}/paystaff/api/guarantors/{1}/statements/';
    public static final String UN = 'sgullapali';
    public static final String PW = 'p@ssw0rd';

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
    */
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
    */
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

    //Convert the amount from cents to dollars
    public static String convertToDollars(String cents) {
        String dollarAmount = String.isBlank(cents) ? cents : String.valueOf(Decimal.valueOf(cents).divide(100, 2));
        System.debug('converted: ' + cents + ' cents to dollar amount: ' + dollarAmount);
        return dollarAmount;
    }
    /*Mohan Kumar 07-28-2016: Convert the amount in cents before sending it to Sirono on Take Payment, 
    *Add Adjustment, Add Discount actions
    */
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
}