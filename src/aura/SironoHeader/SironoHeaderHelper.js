/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    getAllHeaderInfo: function (component) {
        var action = component.get("c.getAllHeaderInfo");
        var formatter = new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 0
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var guarantorWrapper = response.getReturnValue();
                component.set('v.guarantorWrapper', guarantorWrapper);
                // Only update the paymentPlan specific attributes if a payment plan exists.
                if (guarantorWrapper.paymentPlan) {
                    component.set('v.invoiceValue', formatter.format(Math.floor(guarantorWrapper.paymentPlan.Installment_Amount__c)));
                    component.set('v.invoiceValuePart', (guarantorWrapper.paymentPlan.Installment_Amount__c % 1).toFixed(2).toString().substring(2));
                }
                if (guarantorWrapper.contact) {
                    component.set('v.warningMessage', guarantorWrapper.contact.Guarantor_Status__c == 'Overdue');
                    component.set('v.errorMessage', guarantorWrapper.contact.Guarantor_Status__c == 'Delinquent');
                }


            }
        });
        $A.enqueueAction(action);
    }
})