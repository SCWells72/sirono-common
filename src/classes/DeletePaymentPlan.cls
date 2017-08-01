/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class DeletePaymentPlan {

    public String guarantorId { get; set; }
    public String paymentPlanId { get; set; }

    // Constructor of a class and initialize the variables.
    public DeletePaymentPlan() {

        guarantorId = null;
        paymentPlanId = null;

        if (ApexPages.currentPage().getParameters().containsKey('guarantorId')) {
            guarantorId = ApexPages.currentPage().getParameters().get('guarantorId');
        }
        if (ApexPages.currentPage().getParameters().containsKey('paymentPlanId')) {
            paymentPlanId = ApexPages.currentPage().getParameters().get('paymentPlanId');
        }
    }

    public PageReference cancel() {
        PageReference pg = null;
        if (String.isNotBlank(paymentPlanId)) {
            pg = new PageReference('/' + paymentPlanId);
        } else if (String.isNotBlank(guarantorId)) {
            pg = new PageReference('/' + guarantorId);
        } else {
            pg = new PageReference('/home/home.jsp');
        }
        pg.setRedirect(true);
        return pg;
    }

    //call doDeletePaymentPlan and send the request to end point.
    public void doSubmit() {
        try {
            if (String.isNotBlank(paymentPlanId)) {
                PaymentPlanService.removePaymentPlan(paymentPlanId);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Payment plan was successfully cancelled.'));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,  'Payment Plan Id is missing.'));
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: ' + e.getMessage()));

        }
    }
}