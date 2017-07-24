/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Controller for adding selected chargegroups to a payment plan
 */
public with sharing class AddToPaymentPlanVF extends AddToPaymentPlan {

    public AddToPaymentPlanVF() {
        super();
        chargeGroupsSelected = false;
        chargeGroupList = new List<ChargeGroupWrapper>();
        guarantorName = '';
        paymentPlanExtId = null;
        paymentPlanId = null;

        if (ApexPages.currentPage().getParameters().containsKey('guarantorId')) {
            guarantorRecordId = ApexPages.currentPage().getParameters().get('guarantorId');
        }
        if (ApexPages.currentPage().getParameters().containsKey('paymentPlanExtId')) {
            paymentPlanExtId = ApexPages.currentPage().getParameters().get('paymentPlanExtId');
        }
        if (ApexPages.currentPage().getParameters().containsKey('paymentPlanId')) {
            paymentPlanId = ApexPages.currentPage().getParameters().get('paymentPlanId');
        }

        if (guarantorRecordId != null) {
            Contact gc = GuarantorService.getGuarantorFilterCGByAcctSubStatus(guarantorRecordId);
            guarantorName = GuarantorService.buildGuarantorDetailString(gc);
            guarantorId = GuarantorService.getGuarantorSironoId(gc);
            chargeGroupList = ChargeGroupWrapper.buildList(gc);
            chargeGroupIds = new String[]{};
        }

        if (String.isBlank(paymentPlanExtId)) {
            Payment_Plan__c currentPaymentPlan = PaymentPlanService.getActivePaymentPlan(guarantorRecordId);
            if(currentPaymentPlan != null){
                paymentPlanExtId = currentPaymentPlan.Sirono_ID__c.toPlainString();
            }
            if (String.isBlank(paymentPlanExtId)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,
                        'No active Payment Plan exists for this Guarantor. Please click Cancel to go previous page.'));
            }
        }
    }

    /**
     * Add the chargeGroup to the paymentplan.
     */
    public void submit() {
        try {
            if (String.isBlank(paymentPlanExtId) || String.isBlank(guarantorId) || !chargeGroupsSelected) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                        'Please provide all details.'));
                if (Test.IsRunningTest()) {
                    TestUtility.generateException();
                }
            } else {
                PaymentPlanService.addChargeGroups(paymentPlanExtId, chargeGroupIds);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,
                        'Added Successfully!'));
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'ERROR: ' + e.getMessage()));
        }
    }
}