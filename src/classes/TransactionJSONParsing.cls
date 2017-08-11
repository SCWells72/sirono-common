/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * JSON Parsing Class for the response which comes from Transaction Request. Takes the response and turns it into
 * a list of Transaction__c & Charge_Group__c objects with the Charge_Group__c properly populated in the transactions.
 */
public class TransactionJSONParsing extends AbstractSironoJSONParser{

    String jsonString;

    public TransactionJSONParsing(String jsonString) {
        this.jsonString = jsonString.replace('_credit_balance', 'credit_balance');
        this.jsonString = ensureJsonList(this.jsonString);
    }

    @TestVisible
    private class TransactionJSON {
        public String url;
        public Integer amount;
        public String post_date;
        public String fail_date;
        public String export_date;
        public String created_at;
        public String modified_at;
        public String method;
        public String notes;
        public Boolean credit_balance;
        //noinspection ApexUnusedDeclaration2
        public String payment;
        public String chargegroup;
    }

    public class TransactionWrapper {
        public List<Transaction__c> transactionRecords { get; set; }
        public List<Charge_Group__c> chargeGroupRecords { get; set; }

        public TransactionWrapper() {
            transactionRecords = new List<Transaction__c>();
            chargeGroupRecords = new List<Charge_Group__c>();
        }
    }


    public TransactionWrapper parse() {
        TransactionWrapper objTransactionWrapper = new TransactionWrapper();
        List<Transaction__c> lstTransaction = new List<Transaction__c>();
        List<Charge_Group__c> lstChargeGroup = new List<Charge_Group__c>();

        List<TransactionJSON> lstTransactionJson =
            (List<TransactionJSON>) System.JSON.deserialize(jsonString.replace('_credit_balance', 'credit_balance'), List<TransactionJSON>.class);

        if (lstTransactionJson.size() > 0) {

            Map<Decimal, Decimal> mapTransactionChargeGroup = new Map<Decimal, Decimal>();

            for (TransactionJSON objJson : lstTransactionJson) {
                Transaction__c objTransaction = new Transaction__c();
                String transactionExternalId = parseSironoId(objJson.url, RestClientConstants.TRANSACTION_URL_RESOURCE_TYPE);

                objTransaction.Sirono_ID__c = Decimal.valueOf(transactionExternalId);
                //TODO remove when TXN refactored
                objTransaction.Name = objJson.method + '-' + transactionExternalId;
                objTransaction.Amount__c = PayStaffWSUtill.convertToDollarsWithNegative(objJson.amount);
                objTransaction.Transaction_Date__c = parseDate(objJson.created_at);
                objTransaction.Post_Date__c = parseDate(objJson.post_date);
                objTransaction.Fail_Date__c = parseDate(objJson.fail_date);
                objTransaction.Export_Date__c = parseDate(objJson.export_date);
                objTransaction.Credit_Balance__c = objJson.credit_balance;

                if (objJson.chargegroup != null) {
                    Decimal chargegroup = Decimal.valueOf(parseSironoId(objJson.chargegroup, RestClientConstants.CHARGE_GROUP_URL_RESOURCE_TYPE));
                    mapTransactionChargeGroup.put(objTransaction.Sirono_ID__c, chargegroup);
                }

                lstTransaction.add(objTransaction);
            }

            if (mapTransactionChargeGroup.size() > 0) {

                lstChargeGroup = ChargeGroupService.getBySironoIds(mapTransactionChargeGroup.values());

                Map<Decimal, String> mapChargeGroup = new Map<Decimal, String>();
                for (Charge_Group__c cg : lstChargeGroup) {
                    mapChargeGroup.put(cg.Sirono_ID__c, cg.Id);
                }

                for (Transaction__c txn : lstTransaction) {
                    if (txn.Charge_Group__c == null) {
                        Decimal cId = mapTransactionChargeGroup.get(txn.Sirono_ID__c);
                        txn.Charge_Group__c = mapChargeGroup.get(cId);
                    }
                }
            }

            objTransactionWrapper.transactionRecords = lstTransaction;
            objTransactionWrapper.chargeGroupRecords = lstChargeGroup;
        }
        return objTransactionWrapper;
    }


    public static String testResponse() {

        String responseBody = '{' +
            '   "url":"https://toledo.stage.sirono.com/paystaff/api/transaction/22923843/", ' +
            '   "amount":100,' +
            '   "post_date":"2016-10-17T00:00:00",' +
            '   "fail_date":"2016-10-17T00:00:00",' +
            '   "export_date":"2016-10-17T00:00:00",' +
            '   "created_at":"2016-10-17T12:41:22.562824",' +
            '   "modified_at":"2016-10-17T12:41:22.562843",' +
            '   "method":"adjustment",' +
            '   "notes":null,' +
            '   "credit_balance":false,' +
            '   "payment":null,' +
            '   "chargegroup":"https://toledo.stage.sirono.com/paystaff/api/chargegroups/124/" ' +
            '}';

        return responseBody;
    }
}