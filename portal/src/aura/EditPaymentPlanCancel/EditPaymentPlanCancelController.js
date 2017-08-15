/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    showCancelPlanDialog: function (cmp, e, hlpr) {
        hlpr.showPopup(cmp, 'cancelDialog', 'slds-fade-in-');
        hlpr.showPopup(cmp, 'backdrop', 'slds-backdrop--');
        cmp.set('v.hasError', false);
    },
    closeModal: function (cmp, e, hlpr) {
        hlpr.hidePopup(cmp, 'cancelDialog', 'slds-fade-in-');
        hlpr.hidePopup(cmp, 'backdrop', 'slds-backdrop--');
        cmp.set('v.hasError', false);
    },

    /**
     * Make the call to cancel the current payment plan.
     */
    cancelPlan: function (component, evt, helper) {
        var cancelPlan = component.get("c.deletePaymentPlan");
        cancelPlan.setParams({
            paymentPlanId: component.get('v.PaymentInfo.paymentPlan.Id')
        });
        cancelPlan.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                helper.hidePopup(component, 'cancelDialog', 'slds-fade-in-');
                helper.hidePopup(component, 'backdrop', 'slds-backdrop--');
                $A.get("e.force:navigateToURL").setParams({
                    'url': '/',
                    'isredirect': true
                }).fire();
            } else {
                var errors = response.getError();
                if (errors) {
                    helper.showError(component, errors ? errors[0].message : 'Error has occurred');
                }
            }
        });
        $A.enqueueAction(cancelPlan);
    }
})