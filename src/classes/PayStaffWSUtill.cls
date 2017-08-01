/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * All common methods for PayStaff Web service
 */
public with sharing class PayStaffWSUtill {
    //11-23-2016: Viraj Rana - Tracker # 129073825: Take Payment in SF
    //It is used to verified that Charge Group have longer Payment Plan Look up or not.
    static Boolean hasChargeGroupPaymentPlan = false;

    //get the Guarantor Id from given contact.
    public static String fetchGuarantorId(Contact gc) {
        String sironoId = '';
        try {
            sironoId = GuarantorService.getGuarantorSironoId(gc);
        } catch (SironoServiceException ex) {
            if (ApexPages.currentPage() != null) {
                handleErrorMessages(ApexPages.Severity.ERROR, 'Guarantor Id does not exist!');
            }
        }
        return sironoId;
    }

    //get the Patient Id from passed contact.
    public static String fetchPatientId(Contact gc) {
        String sironoId = '';
        try {
            sironoId = PatientService.getPatientSironoId(gc);
        } catch (SironoServiceException ex) {
            if (ApexPages.currentPage() != null) {
                handleErrorMessages(ApexPages.Severity.ERROR, 'Patient Id does not exist!');
            }
        }
        return sironoId;
    }

    //get the charge group list based on the record type
    //TODO - make sure we always retrieve the recordTypeId with every Contact & then this can move into the
    //ChargeGroupWrapper.buildList method - without the recordType parameter
    public static List<ChargeGroupWrapper> fetchChargeGroupList(Contact gc, String recordType) {
        List<ChargeGroupWrapper> cgList = new List<ChargeGroupWrapper>();
        if (recordType == 'Guarantor') {
            return ChargeGroupWrapper.buildList(gc);
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
                    cgIds += glue + cg.cg.Sirono_ID__c;
                    glue = ',';
                }
            }
        }
        return cgIds;
    }

    public static String buildChargeGroupsURL(List<String> chargeGroupIds) {

        String cgUrl = '';
        if (chargeGroupIds != null) {
            List<String> urls = new List<String>();
            for (String cgId : chargeGroupIds) {
                urls.add(String.format('"{0}/paystaff/api/chargegroups/{1}/"',
                    new String[] { SironoSettingsUtil.getServerEndpoint(), cgId }));
            }
            cgUrl = String.join(urls, ',');
        }

        return '[' + cgUrl + ']';
    }

    /**
     * Build the charge group URL(s) for a single charge group id or a comma delimited list of
     * charge group ids.
     *
     * @param String chargeGroupIds - A single charge groupd id or a comma delimited list of charge group ids.
     * @return String - The stringify JSON charge group URL(s).
     **/
    public static String buildChargeGroupsURL(String chargeGroupIds) {
        if (chargeGroupIds != null) {
            // Handle the case where we have a single charge group id or a comma delimited list.
            return buildChargeGroupsURL(chargeGroupIds.split(','));
        }
        return '[]';
    }

    @Future(Callout=true)
    public static void addNoteFuture(List<String> chargeGroupIds, String noteText) {
        addNoteWSCallout(chargeGroupIds, noteText);
    }

    public static void addNoteWSCallout(List<String> chargeGroupIds, String noteText) {
        try {
            if (!chargeGroupIds.isEmpty() && !isEmpty(noteText)) {
                String jwtToken = new SironoRestClient.AuthRestClient().getJwtToken();
                String csrfToken = new SironoRestClient.AuthRestClient().getCsrfToken();
                if (csrfToken != null && jwtToken != null) {
                    String requestData = '{"csrfmiddlewaretoken":"' + csrfToken + '",' +
                        '"chargegroups": ' + buildChargeGroupsURL(chargeGroupIds) + ',' +
                        '"text":"' + noteText + '"' +
                        '}';

                    HttpRequest req = new HttpRequest();
                    HttpResponse res = new HttpResponse();
                    Http http = new Http();
                    String responseBody;
                    req.setMethod('POST');
                    req.setHeader('Authorization', 'JWT ' + jwtToken);
                    req.setHeader('Content-type', 'application/json');
                    req.setEndpoint('callout:sirono_server/paystaff/api/chargegroupnotes/');
                    req.setBody(requestData);
                    try {
                        res = http.send(req);
                        responseBody = res.getBody();
                        if (Test.isRunningTest()) {
                            TestUtility.generateException();
                        }
                    } catch (Exception e) {
                        // Debug error response
                        handleErrorMessages(ApexPages.Severity.ERROR, 'ADD NOTE EXCEPTION RESPONSE : ' +
                            res.toString() + '  RESPONSE BODY::' + responseBody + ' EXCEPTION:: ' + e.getMessage());
                    }

                    if (res.getStatus() != null && res.getStatus().trim().equalsIgnoreCase('CREATED')
                        && res.getStatusCode() != null && res.getStatusCode() == 201) {
                        System.debug('RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody);
                        handleErrorMessages(ApexPages.Severity.INFO, 'Created Successfully!');
                    } else {
                        handleErrorMessages(ApexPages.Severity.INFO, 'CSRF_Token : ' + csrfToken);
                        handleErrorMessages(ApexPages.Severity.INFO, 'JWT_Token : ' + jwtToken);
                        handleErrorMessages(ApexPages.Severity.ERROR, 'RESPONSE : ' + res.toString()
                            + '  RESPONSE BODY::' + responseBody);
                    }
                }
            } else {
                handleErrorMessages(ApexPages.Severity.ERROR, 'Please provide all details.');

            }
            if (Test.isRunningTest()) {
                TestUtility.generateException();
            }
        } catch (Exception e) {
            // Debug error response
            handleErrorMessages(ApexPages.Severity.ERROR, 'ERROR: ' + e.getMessage());
        }
    }

    public static Boolean isEmpty(String str) {
        return (str == null || str.trim().equals(''));
    }

    public static void handleErrorMessages(ApexPages.Severity messageSeverity, String messageText) {
        if (ApexPages.currentPage() != null) {
            ApexPages.addMessage(new ApexPages.Message(messageSeverity, messageText));
        } else {
            System.debug('[' + messageSeverity + '] ' + messageText);
        }
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
        Decimal dollarAmount = (amount != null ? (amount / -100) : amount);
        System.debug('converted cent amount with divided by -100: ' + dollarAmount);
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

    //fetch ChargeGroupList based on account sub status.
    public static List<ChargeGroupWrapper> fetchChargeGroupListByAccountSubStatus(Contact gc) {
        List<ChargeGroupWrapper> cgList = new List<ChargeGroupWrapper>();
        if (gc != null && gc.Charge_Groups__r != null && gc.Charge_Groups__r.size() > 0) {
            for (Charge_Group__c cg : gc.Charge_Groups__r) {
                if (cg.Account_Sub_Status__c == Constants.ACCT_SUBSTATUS_PREINVOICED ||
                    cg.Account_Sub_Status__c == Constants.ACCT_SUBSTATUS_DUE_BY ||
                    cg.Account_Sub_Status__c == Constants.ACCT_SUBSTATUS_OVERDUE ||
                    cg.Account_Sub_Status__c == Constants.ACCT_SUBSTATUS_DELINQUENT ||
                    cg.Account_Sub_Status__c == Constants.ACCT_SUBSTATUS_BAD_DEBT ||
                    cg.Account_Sub_Status__c == Constants.ACCT_SUBSTATUS_PAYMENT_PLAN) {

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
        Payment_Plan__c objPaymentPlan = new Payment_Plan__c();
    }

     /*
    * 10-18-2016: Viraj Rana - Tracker # 129073825: Take Payment in SF
    * 10-18-2016: Viraj Rana - Tracker # 129073861: Take Discount/Adjustment in SF
    * Parse Payment response and call Transaction Request.
    */
    public static void parsePaymentReponse(String jwtToken, String jsonStr, Boolean isPayment) {

        // We have change Payment__c object to List of Payment__c and this list pass in Methods as a parameter.
        // This changes do to resolve Security Scan related issue.
        List<Payment__c> payments = new List<Payment__c>();
        List<Payment_Adjustments__c> lstPaymentAdjustment = new List<Payment_Adjustments__c>();
        PaymentAdjustmentwrapper objPaymentAdjustmentwrapper = new PaymentAdjustmentwrapper();

        List<Transaction__c> lstTransaction = new List<Transaction__c>();
        List<Charge_Group__c> lstChargeGroup = new List<Charge_Group__c>();
        List<Payment_Plan__c> lstPaymentPlan = new List<Payment_Plan__c>();
        Map<Decimal, Decimal> mapTranPayAdjId = new Map<Decimal, Decimal>();

        if (isPayment) {
            Payment__c objPayment = new Payment__c();
            objPayment = PaymentJSONParsing.parse(jsonStr);
            payments.add(objPayment);
        } else {
            lstPaymentAdjustment = PaymentAdjustmentJSONParsing.parse(jsonStr);
        }

        if (payments.size() > 0) {
            callTransactionRequest(jwtToken, payments, null, isPayment);
        } else if (lstPaymentAdjustment.size() > 0) {
            for (Payment_Adjustments__c objPaymentAdjustment : lstPaymentAdjustment) {
                objPaymentAdjustmentwrapper = callTransactionRequest(jwtToken, null, String.valueOf(objPaymentAdjustment.Sirono_ID__c), isPayment);

                lstTransaction.add(objPaymentAdjustmentwrapper.objTransaction);
                mapTranPayAdjId.put(objPaymentAdjustment.Sirono_ID__c, objPaymentAdjustmentwrapper.objTransaction.Sirono_ID__c);

                lstChargeGroup.add(objPaymentAdjustmentwrapper.objChargeGroup);
                objPaymentAdjustment.Charge_Group__c = objPaymentAdjustmentwrapper.objChargeGroup.Id;

                if (objPaymentAdjustmentwrapper.objPaymentPlan.Id != null) {
                    lstPaymentPlan.add(objPaymentAdjustmentwrapper.objPaymentPlan);
                }
            }

            //Save all Records if it is Take Adjustment/Discount.
            if (lstChargeGroup.size() > 0) {
                ChargeGroupService.updateChargeGroupsWithStatus(lstChargeGroup);
            }

            if (lstPaymentPlan.size() > 0) {
                if (PaymentPlanSecurityContext.UPDATE_CONTEXT.actionAllowed()) {
                    update lstPaymentPlan;
                }
            }

            if (lstTransaction.size() > 0) {
                if (TransactionSecurityContext.CREATE_CONTEXT.actionAllowed()) {
                    insert lstTransaction;
                }

                if (TransactionSecurityContext.PSWSU_SELECT_CONTEXT.actionAllowed()) {
                    List<Transaction__c> lstTran = [
                        SELECT Id, Sirono_ID__c
                        FROM Transaction__c
                        WHERE Sirono_ID__c IN :mapTranPayAdjId.values()
                    ];

                    Map<Decimal, String> mapTran = new Map<Decimal, String>();
                    for (Transaction__c t : lstTran) {
                        mapTran.put(t.Sirono_ID__c, t.Id);
                    }

                    for (Payment_Adjustments__c pa : lstPaymentAdjustment) {
                        Decimal tranId = mapTranPayAdjId.get(pa.Sirono_ID__c);
                        pa.Transaction__c = mapTran.get(tranId);
                    }
                }

                if (PaymentAdjustmentsSecurityContext.CREATE_CONTEXT.actionAllowed()) {
                    insert lstPaymentAdjustment;
                }
            }
        }
    }

    /*
    * Call Transaction Request and get all Transactions based on Payment.
    */
    private static PaymentAdjustmentwrapper callTransactionRequest(String jwtToken, List<Payment__c> payments, String paymentAdjustmentSironoId, Boolean isPayment) {

        PaymentAdjustmentwrapper objPaymentAdjustmentwrapper = new PaymentAdjustmentwrapper();

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        Http http = new Http();
        String responseBody;

        req.setMethod('GET');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        if (isPayment) {
            req.setEndpoint('callout:sirono_server/paystaff/api/payments/'
                + String.valueOf(payments.get(0).Sirono_ID__c) + '/transactions/');
        } else {
            req.setEndpoint('callout:sirono_server/paystaff/api/adjustments/'
                + paymentAdjustmentSironoId + '/transactions/');
        }

        req.setTimeout(120000);
        try {
            res = http.send(req);
            responseBody = res.getBody();
            System.debug('StatusCode : ' + res.getStatusCode());
            System.debug('Transaction Response : ' + responseBody);

            if (Test.isRunningTest()) {
                res.setStatusCode(TestUtility.statusCode2);
                TestUtility.generateException();
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'TRANSACTION EXCEPTION RESPONSE : ' + res.toString() +
                    '  RESPONSE BODY::' + responseBody + ' EXCEPTION:: ' + e.getMessage()));
        }

        if (res.getStatusCode() != null && res.getStatusCode() == 200) {
            objPaymentAdjustmentwrapper = parseTransactionResponse(jwtToken, responseBody, payments, isPayment);
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'RESPONSE : ' + res.toString() +
                    '  RESPONSE BODY::' + responseBody));
        }
        return objPaymentAdjustmentwrapper;
    }

    /*
    * Parse Transaction response and based on Charge group call Charge group request.
    */
    private static PaymentAdjustmentwrapper parseTransactionResponse(String jwtToken, String jsonStr, List<Payment__c> payments, Boolean isPayment) {
        TransactionJSONParsing.TransactionWrapper objTransactionWrapper;
        objTransactionWrapper = TransactionJSONParsing.parse(jsonStr);

        List<Transaction__c> lstTransaction = new List<Transaction__c>();
        List<Charge_Group__c> lstChargeGroup = new List<Charge_Group__c>();
        List<Payment_Plan__c> lstPaymentPlan = new List<Payment_Plan__c>();

        PaymentAdjustmentwrapper objPaymentAdjustmentwrapper = new PaymentAdjustmentwrapper();

        if (objTransactionWrapper != null) {
            if (objTransactionWrapper.transactionRecords.size() > 0) {
                System.debug('Transaction record size : ' + objTransactionWrapper.transactionRecords.size());
                System.debug('Transaction records : ' + objTransactionWrapper.transactionRecords);
                lstTransaction = objTransactionWrapper.transactionRecords;
            }
            if (objTransactionWrapper.chargeGroupRecords.size() > 0) {
                System.debug('Charge Group record size : ' + objTransactionWrapper.chargeGroupRecords.size());
                System.debug('Charge Group records : ' + objTransactionWrapper.chargeGroupRecords);
                lstChargeGroup = objTransactionWrapper.chargeGroupRecords;

                for (Charge_Group__c cg : lstChargeGroup) {
                    //Boolean variable set to false for all Charge Group whenever Request made.
                    hasChargeGroupPaymentPlan = true;

                    Charge_Group__c chargeGroup = new Charge_Group__c();
                    chargeGroup = callChargeGroupRequest(String.valueOf(cg.Sirono_ID__c), jwtToken);

                    if (cg.Account_Sub_Status__c == Constants.ACCT_SUBSTATUS_PAYMENT_PLAN) {
                        Payment_Plan__c objPaymentPlan = new Payment_Plan__c();
                        objPaymentPlan = callPaymentPlanRequest(jwtToken, String.valueOf(cg.Payment_Plan__r.Sirono_ID__c),
                            cg.Payment_Plan__r.Guarantor__c);
                        lstPaymentPlan.add(objPaymentPlan);
                    }

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
            if (PaymentSecurityContext.PSWU_CREATE_CONTEXT.actionAllowed()) {
                insert payments;
            }
            Id paymentId = payments.get(0).Id;

            if (lstTransaction.size() > 0) {
                for (Transaction__c objTran : lstTransaction) {
                    objTran.Payment__c = paymentId;
                }

                if (TransactionSecurityContext.CREATE_WITH_PAYMENT_CONTEXT.actionAllowed()) {
                    insert lstTransaction;
                }
            }

            if (lstChargeGroup.size() > 0) {
                ChargeGroupService.updateChargeGroupsWithStatus(lstChargeGroup);
            }

            if (lstPaymentPlan.size() > 0) {
                if (PaymentPlanSecurityContext.UPDATE_CONTEXT.actionAllowed()) {
                    update lstPaymentPlan;
                }
            }
        } else {
            //It is used for Adjustment/Discount.
            if (lstTransaction.size() > 0) {
                objPaymentAdjustmentwrapper.objTransaction = lstTransaction[0];
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
    */
    private static Charge_Group__c callChargeGroupRequest(String chargeGroupId, String jwtToken) {
        Charge_Group__c chargeGroup = new Charge_Group__c();

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        Http http = new Http();
        String responseBody;

        req.setMethod('GET');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint('callout:sirono_server/paystaff/api/chargegroups/'
            + PayStaffWSUtill.trimCommas(chargeGroupId) + '/');

        req.setTimeout(120000);
        try {
            res = http.send(req);
            responseBody = res.getBody();

            if (Test.isRunningTest()) {
                res.setStatusCode(TestUtility.statusCode3);
                TestUtility.generateException();
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'ChargeGroup EXCEPTION RESPONSE : ' + res.toString() +
                    '  RESPONSE BODY::' + responseBody + ' EXCEPTION:: ' + e.getMessage()));
        }
        if (res.getStatusCode() != null && res.getStatusCode() == 200) {
            System.debug('Charge Group Response Body : ' + responseBody);
            chargeGroup = parseChargeGroupResponse(responseBody);
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'RESPONSE : ' + res.toString() +
                    '  RESPONSE BODY::' + responseBody));
        }
        return chargeGroup;
    }

    /*
    * Update the Account_Sub_Status__c and Account_Status__c.
    * if Account_Sub_Status__c = On Payment Plan than call Payment Plan request.
    */
    private static Charge_Group__c parseChargeGroupResponse(String responseBody) {

        ChargeGroupJSONParser objChargeGroup = ChargeGroupJSONParser.parse(responseBody);
        Charge_Group__c cg = new Charge_Group__c();

        cg.Account_Sub_Status__c = objChargeGroup.account_sub_status;
        cg.Account_Status__c = objChargeGroup.account_status;

        //It is used to verified that Charge Group have longer Payment Plan Look up or not.
        if (objChargeGroup.paymentplan == null) {
            hasChargeGroupPaymentPlan = false;
        }

        return cg;
    }

    /*
    *  Call the paymentplan Web Service to get the paymentplan information.
    */
    private static Payment_Plan__c callPaymentPlanRequest(String jwtToken, String paymentPlanExternalId, String guarantorId) {
        Payment_Plan__c objPaymentPlan = new Payment_Plan__c();

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        Http http = new Http();
        String responseBody;

        req.setMethod('GET');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint('callout:sirono_server/paystaff/api/paymentplan/'
            + PayStaffWSUtill.trimCommas(paymentPlanExternalId) + '/');
        req.setTimeout(120000);
        try {
            res = http.send(req);
            responseBody = res.getBody();

            if (Test.isRunningTest()) {
                res.setStatusCode(TestUtility.statusCode2);
                TestUtility.generateException();
            }
        } catch (Exception e) {

        }
        if (res.getStatusCode() != null && res.getStatusCode() == 200) {

            objPaymentPlan = parsePaymentPlanResponse(responseBody, guarantorId);

        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'RESPONSE : ' + res.toString() +
                    '  RESPONSE BODY::' + responseBody));
        }
        return objPaymentPlan;
    }

    /*
    * parse the Payment Plan JSON.
    */
    private static Payment_Plan__c parsePaymentPlanResponse(String jsonStr, String guarantorId) {

        PaymentPlanJSONParsing.PaymentPlanWrapper objPaymentPlanWrapper;
        objPaymentPlanWrapper = PaymentPlanJSONParsing.createPaymentPlanRecord(jsonStr, guarantorId, null);

        Payment_Plan__c paymentPlanObj = new Payment_Plan__c();
        paymentPlanObj = objPaymentPlanWrapper.paymentPlanRecord;

        return paymentPlanObj;
    }
}
