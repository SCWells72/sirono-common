/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class MakeAPaymentController {
    @AuraEnabled
    public static CardInformation getCardInformation() {
        return new CardInformation();
    }

    @AuraEnabled
    public static String makeNewPayment(String jsonPayment, String listIds) {
        System.debug('jsonPayment: ' + jsonPayment);
        System.debug('listIds: ' + listIds);
        CardInformation cInfo = (CardInformation) JSON.deserialize(jsonPayment, CardInformation.class);
        System.debug(cInfo);

        List<String> invoiceIds = (List<String>) JSON.deserialize(listIds, List<String>.class);
        System.debug(invoiceIds);

        Contact guarantor = sPRS.GuarantorService.getPortalGuarantor(UserInfo.getUserId());
        List<sPRS__Charge_Group__c> chargeGroups = sPRS.ChargeGroupService.getPayableByInvoiceId(invoiceIds);
        sPRS.PaymentRequest pmtRequest = buildPaymentRequest(guarantor, chargeGroups, cInfo);
        List<String> errors = pmtRequest.validate();

        if (errors.isEmpty()) {
            try {
                sPRS__Payment__c pmt = sPRS.PaymentService.makePayment(pmtRequest);

                return String.format('Success;{0};${1}', new String[]{ pmt.Name, String.valueOf(pmt.sPRS__Amount__c) });
            } catch (Exception ex) {
                System.debug(ex.getStackTraceString());
                return ex.getMessage();
            }
        } else {
            //TODO Does it make more sense to return JSON array?
            String errorMsg = String.join(errors, '\n ');
            return errorMsg;
        }
    }

    private static sPRS.PaymentRequest buildPaymentRequest(Contact guarantor, sPRS__Charge_Group__c[] chargeGroups, CardInformation cInfo) {
        sPRS.PaymentRequest pmtRequest = new sPRS.PaymentRequest(guarantor, chargeGroups);
        pmtRequest.chargeInfo.creditCardNumber = cInfo.creditCardNumber;
        pmtRequest.chargeInfo.cardHolderName = cInfo.cardHolderName;
        pmtRequest.chargeInfo.expirationYear = cInfo.expirationYear.substring(2);
        pmtRequest.chargeInfo.expirationMonth = cInfo.expirationMonth.substring(0, 2);
        pmtRequest.chargeInfo.cvv = cInfo.cvv;
        pmtRequest.chargeInfo.amount = cInfo.amount;
        pmtRequest.chargeInfo.address = cInfo.address;
        pmtRequest.chargeInfo.city = cInfo.city;
        pmtRequest.chargeInfo.state = cInfo.state;
        pmtRequest.chargeInfo.zip = cInfo.zip;
        return pmtRequest;
    }

    @AuraEnabled
    public static String makeNewEstimatePayment(String jsonPayment, String estimateId) {

        System.debug('Estimate jsonPayment: ' + jsonPayment);
        System.debug('EstimateId: ' + estimateId);

        CardInformation cInfo = (CardInformation) JSON.deserialize(jsonPayment, CardInformation.class);
        System.debug(cInfo);

        Contact guarantor = sPRS.GuarantorService.getPortalGuarantor(UserInfo.getUserId());

        ApexPages.StandardController sc = new ApexPages.StandardController(guarantor);
        PayEstimateLightningController onePayment = new PayEstimateLightningController(sc, estimateId);
        onePayment.creditCardNumber = cInfo.creditCardNumber;
        onePayment.cardHolderName = cInfo.cardHolderName;
        onePayment.expirationYear = cInfo.expirationYear;
        onePayment.expirationMonth = cInfo.expirationMonth;
        onePayment.cvv = cInfo.cvv;
        onePayment.amount = cInfo.amount;
        onePayment.address = cInfo.address;
        onePayment.city = cInfo.city;
        onePayment.state = cInfo.state;
        onePayment.zip = cInfo.zip;
        onePayment.doNext();
        return onePayment.submit();
    }

    @AuraEnabled
    public static Map<String, Map<String, String>> getCardSelectOptions() {
        Map<String, Map<String, String>> outputMap = new Map<String, Map<String, String>>();
        outputMap.put('YEARS', PortalUIConstants.getYears());
        outputMap.put('MONTHS', PortalUIConstants.getExpMonths());
        return outputMap;
    }

    @AuraEnabled
    public static List<String> getStates() {
        return PortalUIConstants.getStates();
    }
}