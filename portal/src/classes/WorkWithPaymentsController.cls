/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class WorkWithPaymentsController {

    /**
     * Get the list of PaymentWrapper objects for the current user.
     *
     * @return List<PaymentWrapper> - The wrapped payments for the current user.
     */
    @AuraEnabled
    public static List<PaymentsWrapper> getPaymentHistory() {
        UserWrapper userWrapper = UserService.getCurrentUser();


        List<Payment__c> payments = PaymentService.getPayments(userWrapper.contactId);
        List<PaymentsWrapper> wrappers = new List<PaymentsWrapper>();
        for (Payment__c payment: payments) {
            wrappers.add(new PaymentsWrapper(payment));
        }
        return wrappers;
    }

    public class PaymentsWrapper {
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String method { get; set; }
        @AuraEnabled public String deposit { get; set; }
        @AuraEnabled public Decimal amount { get; set; }
        @AuraEnabled public String paymentId { get; set; }
        @AuraEnabled public String description { get; set; }

        public PaymentsWrapper(Payment__c payment) {
            this.paymentId = payment.Payment_Id__c;
            this.name = payment.Name;
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