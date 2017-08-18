/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class TransactionJSONParser extends AbstractSironoJSONParser {

    @TestVisible
    private class TransactionJSON {
        public String url;
        public Integer amount;
        public String post_date;
        public String fail_date;
        public String export_date;
        public String created_at;
        //noinspection ApexUnusedDeclaration
        public String modified_at;
        public String method;
        public String notes;
        public Boolean credit_balance;
        //noinspection ApexUnusedDeclaration
        public String payment;
        public String chargegroup;
    }

    private String jsonString;

    public TransactionJSONParser(String jsonString) {
        this.jsonString = jsonString;
        this.jsonString = this.jsonString.replace('_credit_balance', 'credit_balance');
        this.jsonString = ensureJsonList(this.jsonString);
        System.debug('TransactionJSON jsonString: ' + this.jsonString);
    }

    public List<Transaction__c> parse() {

        List<Transaction__c> txns = new List<Transaction__c>();

        List<TransactionJSON> txnJsons =
            (List<TransactionJSON>) System.JSON.deserialize(jsonString, List<TransactionJSON>.class);

        for (TransactionJSON txnJson : txnJsons) {
            Transaction__c txn = new Transaction__c();
            String txnSironoId = parseSironoId(txnJson.url, RestClientConstants.TRANSACTION_URL_RESOURCE_TYPE);

            txn.Sirono_Id__c = Decimal.valueOf(txnSironoId);
            txn.Transaction_Date__c = parseDate(txnJson.created_at);
            txn.Amount__c = convertToDollarsNegative(txnJson.amount);
            txn.Post_Date__c = parseDate(txnJson.post_date);

            if (txnJson.chargegroup != null) {
                String cgSironoId = parseSironoId(txnJson.chargegroup, RestClientConstants.CHARGE_GROUP_URL_RESOURCE_TYPE);
                txn.Charge_Group__r = new Charge_Group__c(Sirono_Id__c = Decimal.valueOf(cgSironoId));
            }

            txns.add(txn);
        }

        return txns;
    }
}