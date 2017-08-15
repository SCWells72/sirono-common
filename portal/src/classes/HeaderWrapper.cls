/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
* Wrapper class for the Header data.
*/
public virtual with sharing class HeaderWrapper {
    @AuraEnabled public Contact contact { get; set; }
    @AuraEnabled public Invoice__c invoiceOverdue { get; set; }
    @AuraEnabled public String messageInfo { get; set; }
    @AuraEnabled public String pastDueMessage { get; set; }
    @AuraEnabled public Payment_Plan__c paymentPlan { get; set; }
    @AuraEnabled public Integer newEstimatesCount { get; set; }
    @AuraEnabled public Boolean balanceNoPaymentPlan { get; set; }
    @AuraEnabled public Boolean balanceHasPaymentPlan { get; set; }
    @AuraEnabled public Boolean balanceDueOrError { get; set; }
    @AuraEnabled public Boolean isInstallAmountView { get; set; }

    public HeaderWrapper() {
    }
    public HeaderWrapper(Contact contact, Invoice__c invoice, Payment_Plan__c paymentPlan, Integer estimateCount) {
        this.messageInfo = '';

        this.invoiceOverdue = invoice;
        this.paymentPlan = paymentPlan;
        this.contact = contact;
        this.newEstimatesCount = estimateCount;
    }

    public virtual String getGuarantorStatus() {
        return this.contact.Guarantor_Status__c;
    }

    public virtual Boolean hasAddToPaymentPlan() {
        return this.contact.Add_To_Payment_Plan__c == true;
    }

    public virtual String getPaymentPlanStanding() {
        return this.paymentPlan.Payment_Plan_Standing__c;
    }

    public virtual Boolean getPaymentPlanActive() {
        return this.paymentPlan.Active__c == true;
    }

    public virtual String getPaymentPlanType() {
        return this.paymentPlan.Plan_Type__c;
    }

    public virtual Boolean hasPaymentPlan() {
        return this.paymentPlan != null;
    }
}