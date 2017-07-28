/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Parse the JSON response from a server Payment request.
 */
public class PaymentJSONParsing {

    public String url;
    public String guarantor;
    public Integer amount;
    public String transaction_number;
    public String payment_date;
    public String method;
    public String last_4;
    public String processor_transaction_id;
    public String receipt_link;
    public String payment_info;
    public String payment_type;
    public String account_number;
    public String routing_number;
    public String bank_account_type;
    public String is_voidable;
    public String post_date;

    public static Payment__c parse(String json) {
        if (json.contains('[')) {
            json = json.replace('[', '');
            json = json.replace(']', '');
        }
        PaymentJSONParsing objJson = (PaymentJSONParsing) System.JSON.deserialize(json, PaymentJSONParsing.class);

        Payment__c objPayment = new Payment__c();

        String guarantorSironoId = getExternalID(objJson.guarantor, 'guarantors');

        Contact guarantorContact = GuarantorService.getGuarantorBySironoId(guarantorSironoId);
        objPayment.Guarantor__c = guarantorContact.Id;

        if (!String.isBlank(objJson.payment_date)) {
            objPayment.Charge_Date__c = Date.valueOf(objJson.payment_date);
            objPayment.Deposit_Date__c = Date.valueOf(objJson.payment_date);
        }
        objPayment.Method__c = objJson.method;
        objPayment.Last_4__c = objJson.last_4;
        objPayment.Processor_Transaction_ID__c = objJson.processor_transaction_id;

        objPayment.Amount__c = PayStaffWSUtill.convertToDollars(objJson.amount);
        objPayment.Sirono_ID__c = Integer.valueOf(getExternalID(objJson.url, 'payments'));
        objPayment.Name = getExternalID(objJson.url, 'payments');

        return objPayment;
    }

    public static String getExternalID(String url, String splitWith) {
        String[] externalID = url.split(splitWith);
        return externalID[externalID.size() - 1].replaceAll('/', '');
    }

    public static String testResponse() {

        String responseBody = '[{' +
            '   "url": "https://toledo.stage.sirono.com/paystaff/api/payments/20690/", ' +
            '   "guarantor":"https://toledo.stage.sirono.com/paystaff/api/guarantors/123/",' +
            '   "amount":100,' +
            '   "transaction_number":"TD-0000020690",' +
            '   "payment_date":"2016-10-13",' +
            '   "method":"credit",' +
            '   "last_4":"0005",' +
            '   "processor_transaction_id":"3f8ex1ft",' +
            '   "receipt_link":"https://toledo.stage.sirono.com/portal/staff/guarantor-mask/72407/?next=/portal/receipt/20690/",' +
            '   "payment_info":"Credit Card | Last Digits: 0005",' +
            '   "payment_type":"Online",' +
            '   "account_number":null,' +
            '   "routing_number":null,' +
            '   "bank_account_type":null,' +
            '   "is_voidable":null' +
            '}]';

        return responseBody;
    }
}