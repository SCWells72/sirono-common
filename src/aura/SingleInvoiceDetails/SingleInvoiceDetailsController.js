/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    closeModal: function (component, event, helper) {
        var modal = component.find('slds-modal');
        var backdrop = component.find('slds-backdrop');
        $A.util.removeClass(modal, 'slds-fade-in-open');
        $A.util.removeClass(backdrop, 'slds-backdrop--open');
    },

    displayInvoiceDetails: function (component, event, helper) {
        var invoice = event.getParam('invoice');
        if (invoice != null) {
            var totalCharges = 0;
            var totalCredits = 0;
            for (var i = 0; i < invoice.allGroups.length; i++) {
                totalCharges += invoice.allGroups[i].totalCharges;
                totalCredits += invoice.allGroups[i].totalCredits;
            }
            component.set("v.invoice", invoice);
            component.set("v.invoice.invoiceTotalCharges", totalCharges);
            component.set("v.invoice.invoiceTotalCredits", totalCredits);
        }
        console.log('::::invoice:::' + invoice);

        var modal = component.find('slds-modal');
        var backdrop = component.find('slds-backdrop');
        $A.util.addClass(modal, 'slds-fade-in-open');
        $A.util.addClass(backdrop, 'slds-backdrop--open');
    }
})