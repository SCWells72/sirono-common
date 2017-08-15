/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    getAllHeaderInfo: function (component) {
        var action = component.get("c.getAllHeaderInfo");
        var formatter = new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 0,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var guarantorWrapper = response.getReturnValue();
                if (typeof(guarantorWrapper.contact) != "undefined") {
                    component.set('v.guarantorWrapper', guarantorWrapper);
                    component.set('v.invoiceValue', formatter.format(Math.floor(guarantorWrapper.contact.Invoiced_Balance__c)));
                    component.set('v.invoiceValuePart', (guarantorWrapper.contact.Invoiced_Balance__c % 1).toFixed(2).toString().substring(2));
                }
            }
        });
        $A.enqueueAction(action);
    },

    goToPaymentsPage: function (component, tabType) {
        var isLanding = component.get('v.isLanding');
        if (!isLanding) {
            var appEvent = $A.get("e.c:payNowRequest");
            appEvent.setParams({"invoiceId": null, 'type': tabType});
            appEvent.fire();
        } else {
            $A.get("e.force:navigateToURL").setParams({
                'url': '/payments?tab=' + tabType
            }).fire();
        }
    },

    goToMainPage: function (component, tabType) {
        var isLanding = component.get('v.isLanding');
        if (!isLanding) {
            var headerEvent = $A.get("e.c:ToggleHeader");
            headerEvent.fire();
            var appEvent = $A.get("e.c:ActivateTab");
            appEvent.setParams({'activeTab': tabType});
            appEvent.fire();
        } else {
            $A.get("e.force:navigateToURL").setParams({
                'url': '/?activeTab=' + tabType
            }).fire();
        }
    }
})