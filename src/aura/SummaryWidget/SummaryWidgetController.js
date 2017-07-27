/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    doInit: function (component, event, helper) {
        var src = event.getSource();
        helper.getAllHeaderInfo(component);
    },

    goToPayment: function (component, event, helper) {
        helper.goToPaymentsPage(component, 'MakeAPayment');
    },

    goToPaymentPlan: function (component, event, helper) {
        helper.goToPaymentsPage(component, 'CreatePaymentPlan');
    },

    goToMainPage: function (component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({
            'url': '/'
        }).fire();
    },

    goToInvoices: function (component, event, helper) {
        helper.goToMainPage(component, 'Invoices');
    },

    goToEstimates: function (component, event, helper) {
        helper.goToMainPage(component, 'Estimates');
    },

    showTooltip: function (component, event, helper) {
        var tooltip = component.find('popover-tooltip');
        var tooltipCopy = component.find('popover-tooltip-copy');
        $A.util.toggleClass(tooltip, "slds-hide");
        $A.util.toggleClass(tooltipCopy, "slds-hide");
    },
})