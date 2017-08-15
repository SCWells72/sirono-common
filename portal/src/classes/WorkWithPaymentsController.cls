/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class WorkWithPaymentsController {

    @AuraEnabled
    public static List<PaymentsWrapper> getPaymentHistory() {
        User currentUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];


        List<Payment__c> result = [
            SELECT
                Id,
                Method__c,
                Deposit_Date__c,
                Payment_Id__c,
                Payment_Method__r.Last_4__c,
                Payment_Method__r.Card_Type__c,
                Processor_Transaction_Id__c,
                Amount__c
            FROM Payment__c
            WHERE Guarantor__c = :currentUser.ContactId
            LIMIT 50000
        ];
        List<PaymentsWrapper> wrappers = new List<PaymentsWrapper>();
        for (Integer i = 0; i < result.size(); i++) {
            wrappers.add(new PaymentsWrapper(result[i]));
        }
        return wrappers;
    }

    public class PaymentsWrapper {
        @AuraEnabled public String method { get; set; }
        @AuraEnabled public String deposit { get; set; }
        @AuraEnabled public Decimal amount { get; set; }
        @AuraEnabled public String paymentId { get; set; }
        @AuraEnabled public String description { get; set; }

        public PaymentsWrapper(Payment__c payment) {
            this.paymentId = payment.Payment_Id__c;
            this.deposit = payment.Deposit_Date__c != null ? payment.Deposit_Date__c.date().format() : '';
            this.method = payment.Method__c;
            this.description = '';
            this.amount = payment.Amount__c;
            if (payment.Method__c == 'credit' || payment.Method__c == 'Credit') {
                this.description += payment.Payment_Method__r.Card_Type__c + ' ' + payment.Payment_Method__r.Last_4__c;
            } else if (payment.Method__c == 'check' || payment.Method__c == 'Check') {
                this.description += payment.Processor_Transaction_Id__c;
            }
            this.description = this.description.replaceAll('null', '');
        }
    }
}