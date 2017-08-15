/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    doInit: function (component, event, helper) {
        console.log('payments comp');
        var appEvent = $A.get("e.c:payCall");
        appEvent.fire();
    },
    payCall: function (component, event, helper) {
        var invoiceId = event.getParam('invoiceId');
        var activeTab = event.getParam('activeTab');
        var isEstimate = event.getParam('isEstimateRecord');
        var filter = event.getParam('filter');
        console.log('groupFilter', filter);
        var hideCreatePaymentPlanTab = event.getParam('hideCreatePaymentPlanTab');
        activeTab = hideCreatePaymentPlanTab ? 'MakeAPayment' : activeTab;
        filter = filter == null ? 'Unpaid' : filter;
        $A.createComponent(
            "c:PatientInvoiceSelection",
            {
                "invoiceId": invoiceId,
                "isEstimateType": isEstimate,
                "groupFilter": filter,
                "selectedTab": activeTab
            },
            function (newComponent, status, errorMessage) {
                if (status === "SUCCESS") {
                    var patientInvoice = component.find('patientInvoiceSection');
                    patientInvoice.set("v.body", newComponent);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
        $A.createComponent(
            "c:PaymentTabs",
            {
                "invoiceId": invoiceId,
                "activeTab": activeTab,
                "hideCreatePaymentPlanTab": hideCreatePaymentPlanTab
            },
            function (newComponent, status, errorMessage) {
                if (status === "SUCCESS") {
                    var paymentTabs = component.find('paymentTabsSection');
                    paymentTabs.set("v.body", newComponent);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );

    },
    bodyStatus: function (component, event, helper) {
        var status = event.getParam("collapse");
        var alert = event.getParam("alert");
        var scroll = component.find('payment_scroll');
        if (status == "true") {
            $A.util.removeClass(scroll, "small");
        }
        if (status == "false") {
            $A.util.addClass(scroll, "small");
        }
        if (alert == "true") {
            $A.util.removeClass(scroll, "alert");
        }
    }
})