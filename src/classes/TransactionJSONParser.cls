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
        //noinspection ApexUnusedDeclaration
        public String created_at;
        //noinspection ApexUnusedDeclaration
        public String modified_at;
        public String method;
        public String notes;
        public Boolean credit_balance;
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

    private Datetime parseDatetime(String str) {

        if (!String.isBlank(str)) {
            String[] parts = str.split('T');
            String[] timeParts = parts[1].replace('.', ':').split(':');

            return Datetime.newInstance(
                    Date.valueOf(parts[0]),
                    Time.newInstance(
                            Integer.valueOf(timeParts[0]),
                            Integer.valueOf(timeParts[1]),
                            Integer.valueOf(timeParts[2]),
							//There are no milliseconds when the time is 00:00:00
                            timeParts.size() == 4 ? Integer.valueOf(timeParts[3]) : 0));
        }
        return null;
    }

    public List<Transaction__c> parse() {

        List<Transaction__c> txns = new List<Transaction__c>();

        List<TransactionJSON> txnJsons =
                (List<TransactionJSON>) System.JSON.deserialize(jsonString, List<TransactionJSON>.class);

        for (TransactionJSON txnJson : txnJsons) {
            Transaction__c txn = new Transaction__c();
            String txnSironoId = parseSironoId(txnJson.url, RestClientConstants.TRANSACTION_URL_RESOURCE_TYPE);

            txn.Sirono_ID__c = Decimal.valueOf(txnSironoId);
            txn.Name = txnJson.method + '-' + txnSironoId;
            txn.Amount__c = convertToDollarsNegative(txnJson.amount);
            txn.Post_Date__c = parseDatetime(txnJson.post_date);
            txn.Fail_Date__c = parseDatetime(txnJson.fail_date);
            txn.Export_Date__c = parseDatetime(txnJson.export_date);
            txn.Credit_Balance__c = txnJson.credit_balance;

            if (txnJson.chargegroup != null) {
                String cgSironoId = parseSironoId(txnJson.chargegroup, RestClientConstants.CHARGE_GROUP_URL_RESOURCE_TYPE);
                txn.Charge_Group__r = new Charge_Group__c(Sirono_ID__c = Decimal.valueOf(cgSironoId));
            }

            txns.add(txn);
        }

        return txns;
    }
}