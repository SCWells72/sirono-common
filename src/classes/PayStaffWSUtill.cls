/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * All common methods for PayStaff Web service
 */
public with sharing class PayStaffWSUtill {
    //Verify whether or not the Charge Group has an associated Payment Plan
    private static Boolean chargeGroupOnPPlan = false;

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

    //This wrapper class is used for Payment/Adjustment/Discount processing.
    public class RelatedObjectWrapper {
        Transaction__c objTransaction = new Transaction__c();
        Charge_Group__c objChargeGroup = new Charge_Group__c();
        Payment_Plan__c objPaymentPlan = new Payment_Plan__c();
    }

    public static void processDiscount(Contact gt, String jsonString) {

        Map<Decimal, Charge_Group__c> cgSironoIdMap = new Map<Decimal, Charge_Group__c>();
        for (Charge_Group__c cg : gt.Charge_Groups__r) {
            cgSironoIdMap.put(cg.Sirono_ID__c, cg);
        }

        AdjustmentJSONParser parser = new AdjustmentJSONParser(jsonString);
        List<AdjustmentJSONParser.AdjustmentWrapper> sironoWrappers = parser.parse();

        if (!sironoWrappers.isEmpty()) {
            List<Transaction__c> transactions = new List<Transaction__c>();
            List<Charge_Group__c> chargeGroups = new List<Charge_Group__c>();
            List<Payment_Plan__c> paymentPlans = new List<Payment_Plan__c>();

            Map<AdjustmentJSONParser.AdjustmentWrapper, RelatedObjectWrapper> wrapperMap = new Map<AdjustmentJSONParser.AdjustmentWrapper, PayStaffWSUtill.RelatedObjectWrapper>();

            for (AdjustmentJSONParser.AdjustmentWrapper sironoWrapper : sironoWrappers) {

                RelatedObjectWrapper relatedObjectWrapper = callTransactionRequest(null, sironoWrapper.sironoId.toPlainString(), false);
                sironoWrapper.adjustment.Guarantor__c = gt.Id;
                sironoWrapper.adjustment.External_Guarantor__c = cgSironoIdMap.get(sironoWrapper.cgSironoId).External_Guarantor_ID__c;
                wrapperMap.put(sironoWrapper, relatedObjectWrapper);
            }

            List<Adjustment__c> adjustments = new List<Adjustment__c>();
            for (AdjustmentJSONParser.AdjustmentWrapper sironoWrapper : sironoWrappers) {
                adjustments.add(sironoWrapper.adjustment);
            }
            AdjustmentDao.save(adjustments);

            for (AdjustmentJSONParser.AdjustmentWrapper sironoWrapper : sironoWrappers) {
                RelatedObjectWrapper row = wrapperMap.get(sironoWrapper);
                row.objTransaction.Adjustment2__c = sironoWrapper.adjustment.Id;
                transactions.add(row.objTransaction);

                chargeGroups.add(row.objChargeGroup);

                if (row.objPaymentPlan.Id != null) {
                    paymentPlans.add(row.objPaymentPlan);
                }
            }

            if (chargeGroups.size() > 0) {
                ChargeGroupService.updateChargeGroups(chargeGroups);
            }

            if (paymentPlans.size() > 0) {
                PaymentPlanDao.updateAll(paymentPlans);
            }

            if (transactions.size() > 0) {
                TransactionDao.save(transactions);
            }
        }
    }

    public static void processPayment(String jsonString) {
        PaymentJSONParsing parser = new PaymentJSONParsing(jsonString);
        Payment__c payment = parser.parse();
        callTransactionRequest(new List<Payment__c>{payment}, null, true);
    }

    /*
    * Call Transaction Request and get all Transactions based on Payment.
    */
    private static RelatedObjectWrapper callTransactionRequest(List<Payment__c> payments, String paymentAdjustmentSironoId, Boolean isPayment) {

        RelatedObjectWrapper adjWrapper = new RelatedObjectWrapper();

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        Http http = new Http();
        String responseBody;

        req.setMethod('GET');
        req.setHeader('Authorization', 'JWT ' + new SironoRestClient.AuthRestClient().getJwtToken());
        req.setHeader('Content-type', 'application/json');
        if (isPayment) {
            req.setEndpoint('callout:sirono_server/paystaff/api/payments/'
                        + String.valueOf(payments.get(0).Sirono_ID__c) +'/transactions/');
        } else {
            req.setEndpoint('callout:sirono_server/paystaff/api/adjustments/'
                        + paymentAdjustmentSironoId +'/transactions/');
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
                    'TRANSACTION EXCEPTION RESPONSE : '+ res.toString() +
                            '  RESPONSE BODY::' + responseBody + ' EXCEPTION:: ' + e.getMessage()));
        }

        if (res.getStatusCode() != null && res.getStatusCode() == 200) {
            adjWrapper = parseTransactionResponse(responseBody, payments, isPayment);
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                    'RESPONSE : '+ res.toString() +
                                    '  RESPONSE BODY::' + responseBody));
        }
        return adjWrapper;
    }

    /*
    * Parse Transaction response and based on Charge group call Charge group request.
    */
    private static RelatedObjectWrapper parseTransactionResponse(String jsonStr, List<Payment__c> payments, boolean isPayment) {

        TransactionJSONParsing parser = new TransactionJSONParsing(jsonStr);
        TransactionJSONParsing.TransactionWrapper txnWrapper = parser.parse();

        List<Transaction__c> transactions = new List<Transaction__c>();
        List<Charge_Group__c> chargeGroups = new List<Charge_Group__c>();
        List<Payment_Plan__c> paymentPlans = new List<Payment_Plan__c>();

        RelatedObjectWrapper adjWrapper = new RelatedObjectWrapper();

        if (txnWrapper != null) {
            if (txnWrapper.transactionRecords.size() > 0) {
                System.debug('Transaction record size : ' + txnWrapper.transactionRecords.size());
                System.debug('Transaction records : ' + txnWrapper.transactionRecords);
                transactions = txnWrapper.transactionRecords;
            }
            if (txnWrapper.chargeGroupRecords.size() > 0) {
                System.debug('Charge Group record size : ' + txnWrapper.chargeGroupRecords.size());
                System.debug('Charge Group records : ' + txnWrapper.chargeGroupRecords);
                chargeGroups = txnWrapper.chargeGroupRecords;

                for (Charge_Group__c cg : chargeGroups) {
                    //Boolean variable set to false for all Charge Groups whenever Request made.
                    chargeGroupOnPPlan = true;

                    Charge_Group__c chargeGroup = callChargeGroupRequest(cg.Sirono_ID__c);

                    if (cg.Account_Sub_Status__c == Constants.ACCT_SUBSTATUS_PAYMENT_PLAN) {
                        Payment_Plan__c paymentPlan = callPaymentPlanRequest(cg.Payment_Plan__r.Sirono_ID__c,
                                cg.Payment_Plan__r.Guarantor__c);
                        paymentPlans.add(paymentPlan);
                    }

                    //If Charge Group no longer has a Payment Plan, then set it null.
                    if (!chargeGroupOnPPlan) {
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
            Id paymentId = payments[0].Id;

            if (!transactions.isEmpty()) {
                for (Transaction__c objTran : transactions) {
                    objTran.Payment__c = paymentId;
                }
                TransactionDao.save(transactions);
            }

            if (!chargeGroups.isEmpty()) {
                ChargeGroupService.updateChargeGroups(chargeGroups);
            }

            if (!paymentPlans.isEmpty()) {
                PaymentPlanDao.updateAll(paymentPlans);
            }
        } else {
            //It is used for Adjustment/Discount.
            if (!transactions.isEmpty()) {
                adjWrapper.objTransaction = transactions[0];
            }
            if (!chargeGroups.isEmpty()) {
                adjWrapper.objChargeGroup = chargeGroups[0];
            }
            if (!paymentPlans.isEmpty()) {
                adjWrapper.objPaymentPlan = paymentPlans[0];
            }
        }
        return adjWrapper;
    }

    /**
    *
    * Retrieve the given chargegroup from Sirono
    */
    private static Charge_Group__c callChargeGroupRequest(Decimal chargeGroupId) {
        Charge_Group__c chargeGroup = new Charge_Group__c();

        ChargeGroupJSONParser.ChargeGroupJSON wrapper = ChargeGroupService.retrieveBySironoId(chargeGroupId.toPlainString());
        chargeGroup = parseChargeGroupResponse(wrapper);

        return chargeGroup;
    }

    /*
    * Update the Account_Sub_Status__c and Account_Status__c.
    * if Account_Sub_Status__c = On Payment Plan than call Payment Plan request.
    */
    private static Charge_Group__c parseChargeGroupResponse(ChargeGroupJSONParser.ChargeGroupJSON cgWrapper) {

        String gtId = AbstractSironoJSONParser.parseSironoId(cgWrapper.guarantor_data.url, RestClientConstants.GUARANTOR_URL_RESOURCE_TYPE);

        Contact gt = GuarantorDao.getGuarantorBySironoId(gtId);

        Charge_Group__c cg = new Charge_Group__c(Account_Sub_Status__c = cgWrapper.account_sub_status,
                Account_Status__c = cgWrapper.account_status, Guarantor__c = gt.Id);

        //Does the Charge Group have a Payment Plan?.
        if (cgWrapper.paymentplan == null) {
            chargeGroupOnPPlan = false;
        }

        return cg;
    }

    /*
    *  Call the paymentplan Web Service to get the paymentplan information.
    */
	//TODO replace with PaymentPlanService call
    private static Payment_Plan__c callPaymentPlanRequest(Decimal paymentPlanSironoId, String guarantorId) {
        Payment_Plan__c objPaymentPlan = new Payment_Plan__c();

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        Http http = new Http();
        String responseBody;

        req.setMethod('GET');
        req.setHeader('Authorization', 'JWT ' + new SironoRestClient.AuthRestClient().getJwtToken());
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint('callout:sirono_server/paystaff/api/paymentplan/'
                + paymentPlanSironoId.toPlainString() + '/');
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
                                    'RESPONSE : '+ res.toString() +
                                    '  RESPONSE BODY::' + responseBody));
        }
        return objPaymentPlan;
    }

    /*
    * parse the Payment Plan JSON.
    */
    private static Payment_Plan__c parsePaymentPlanResponse(String jsonStr, String guarantorId) {

        PaymentPlanJSONParsing.PaymentPlanWrapper objPaymentPlanWrapper = PaymentPlanJSONParsing.createPaymentPlanRecord(jsonStr, guarantorId, null);

        Payment_Plan__c paymentPlanObj = new Payment_Plan__c();
        paymentPlanObj = objPaymentPlanWrapper.paymentPlanRecord;

        return paymentPlanObj;
    }
}
