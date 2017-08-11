/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    /**
     * Initialization function.
     *
     * @param component
     * @param event
     * @param helper
     */
    doInit: function(component, event, helper) {
        var settingsService = component.find('settingsService');
        settingsService.getSettings(function(err, settings) {
            if (err) {
                //TODO: we need to figure out a general error handler
                console.log(err);
                return;
            }

            if (settings.hasFinancialAidPDF) {
                component.set('v.showFinancialAid', true);
                component.set('v.financialAidPdfUrl', $A.get('$Resource.' + settings.financialAidName));
            } else {
                component.set('v.showFinancialAid', false);
            }
        });
    },
    changePage: function (component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({
            'url': '/payments'
        }).fire();
    },
    sendPageMakeToHeader: function (component, event, helper) {
        var appEvent = $A.get("e.c:payNowRequest");
        appEvent.setParams({'type': 'MakeAPayment'});
        appEvent.fire();
    },
    sendPageCreateToHeader: function (component, event, helper) {
        var appEvent = $A.get("e.c:payNowRequest");
        appEvent.setParams({'type': 'CreatePaymentPlan'});
        appEvent.fire();
    },
    sendUnpaidFilterToHeader: function (component, Event, helper) {
        var appEvent = $A.get("e.c:payNowRequest");
        appEvent.setParams({'type': 'MakeAPayment', 'filter': 'Unpaid'});
        appEvent.fire();
    },
    sendDelinquentFilterToHeader: function (component, Event, helper) {
        var appEvent = $A.get("e.c:payNowRequest");
        appEvent.setParams({'type': 'MakeAPayment', 'filter': 'Delinquent'});
        appEvent.fire();
    },
    sendOverdueFilterToHeader: function (component, Event, helper) {
        var appEvent = $A.get("e.c:payNowRequest");
        appEvent.setParams({'type': 'MakeAPayment', 'filter': 'Overdue'});
        appEvent.fire();
    },
})