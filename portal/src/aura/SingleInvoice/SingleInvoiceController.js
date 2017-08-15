/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    doInit: function (component, event, helper) {
        // component.set("v.isVisibleModal", false);
        /*var allGroups = component.get('v.invoice').allGroups;
        console.log('allGroups', allGroups);
        var isPayment = true;
        if(allGroups != undefined && allGroups.length != 0){
            for(var i = 0; i < allGroups.length; i++){
            console.log('PP:', allGroups[i].cGroup.Payment_Plan__c);
                if((allGroups[i].cGroup.Payment_Plan__c != undefined && allGroups[i].cGroup.Payment_Plan__r.Active__c == false) || allGroups[i].cGroup.Payment_Plan__c == undefined){
                    isPayment = false;
                }
            }
        }
        component.set('v.isLock', isPayment);
        console.log('isLock', isPayment);*/
        var invoice = component.get('v.invoice');
        var selectedTab = component.get('v.selectedTab');
        if (invoice.singleInvoice.Status__c == 'On Payment Plan' && selectedTab == 'CreatePaymentPlan') {
            component.set('v.isLock', true);
        }
    },

    selectInvoice: function (component, event, helper) {
        console.log('Select Invoice');
        $A.util.toggleClass(component.find('selectIcon'), 'selected');
        var activated = component.get('v.activated');
        var invoice = component.get('v.invoice');
        console.log('Select Invoice', invoice);
        var balanceDue = invoice.balanceDue;
        if (!activated) {
            balanceDue = -balanceDue;
        }
        component.set('v.activated', !activated);
        var calculatePaymentBalance = $A.get("e.c:calculatePaymentBalanceEvent");
        calculatePaymentBalance.setParams({
            "changeSum": balanceDue,
            "invoices": [invoice],
            "add": !activated,
            "recordId": invoice.singleInvoice.Id
        });
        calculatePaymentBalance.fire();
    },

    toggleAllInvoices: function (component, event, helper) {
        console.log('Toggle All Invoices');
        console.log(component.get('v.invoice'));
        console.log(this);
        if (component.get('v.activated') === event.getParam('SelectAll')) {
            return;
        }
        var balanceDue;
        var activated = event.getParam('SelectAll');
        var invoice = component.get('v.invoice');
        if (activated) {
            $A.util.addClass(component.find('selectIcon'), 'selected');
            balanceDue = -invoice.balanceDue;
        } else {
            $A.util.removeClass(component.find('selectIcon'), 'selected');
            balanceDue = invoice.balanceDue;
        }
        component.set('v.activated', activated);
        var calculatePaymentBalance = $A.get("e.c:calculatePaymentBalanceEvent");
        calculatePaymentBalance.setParams({
            "changeSum": balanceDue,
            "invoices": [invoice],
            "add": activated,
            "recordId": invoice.singleInvoice.Id
        });
        calculatePaymentBalance.fire();
    },

    openInvoiceDetails: function (component, event, helper) {
        console.log('open invoice details');
        console.log(component.get("v.invoice"));
        $A.get("e.c:SingleInvoiceDetailsEvent").setParams({
            "invoice": component.get("v.invoice")
        }).fire();
    }


})