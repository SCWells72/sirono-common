/**
 * Wrapper class for the Guarantor.
 */

public with sharing class GuarantorWrapper {
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

  public GuarantorWrapper(Contact contact, Invoice__c invoice, Payment_Plan__c paymentPlan, Integer estimateCount) {
    this.messageInfo = '';

    this.invoiceOverdue = invoice;
    this.paymentPlan = paymentPlan;
    this.contact = contact;
    this.newEstimatesCount = estimateCount;

  }
}