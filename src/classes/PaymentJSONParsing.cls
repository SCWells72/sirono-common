/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Parse the JSON response from a server Payment request.
 */
public class PaymentJSONParsing extends AbstractSironoJSONParser {
    private String jsonString;

    public class PaymentJSONWrapper {
        public String url;
        public String guarantor;
        public Integer amount;
        //noinspection ApexUnusedDeclaration
        public String transaction_number;
        public String payment_date;
        public String method;
        public String last_4;
        public String processor_transaction_id;
        //noinspection ApexUnusedDeclaration
        public String receipt_link;
        //noinspection ApexUnusedDeclaration
        public String payment_info;
        //noinspection ApexUnusedDeclaration
        public String payment_type;
        //noinspection ApexUnusedDeclaration
        public String account_number;
        //noinspection ApexUnusedDeclaration
        public String routing_number;
        //noinspection ApexUnusedDeclaration
        public String bank_account_type;
        //noinspection ApexUnusedDeclaration
        public String is_voidable;
        //noinspection ApexUnusedDeclaration
        public String post_date;
    }

    public PaymentJSONParsing(String jsonString) {
        this.jsonString = jsonString;
    }

    public Payment__c parse() {
        if(jsonString.contains('[')){
            jsonString = jsonString.replace('[','');
            jsonString = jsonString.replace(']','');
        }

        PaymentJSONWrapper objJson = (PaymentJSONWrapper) System.JSON.deserialize(jsonString, PaymentJSONWrapper.class);

        Payment__c objPayment = new Payment__c();

        String guarantorSironoId = parseSironoId(objJson.guarantor, 'guarantors');

        Contact guarantorContact = GuarantorService.getGuarantorBySironoId(guarantorSironoId);
        objPayment.Guarantor__c = guarantorContact.Id;

        objPayment.Charge_Date__c = parseDate(objJson.payment_date);
        objPayment.Deposit_Date__c = parseDate(objJson.payment_date);

        objPayment.Method__c = objJson.method;
        objPayment.Last_4__c = objJson.last_4;
        objPayment.Processor_Transaction_ID__c = objJson.processor_transaction_id;

        objPayment.Amount__c = convertToDollars(objJson.amount);
        String sironoId = parseSironoId(objJson.url,'payments');
        objPayment.Sirono_ID__c = Decimal.valueOf(sironoId);
        objPayment.Name = sironoId;

        return objPayment;
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