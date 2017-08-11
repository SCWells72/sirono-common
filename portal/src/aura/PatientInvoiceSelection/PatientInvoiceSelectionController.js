/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    doInit: function (component, event, helper) {
        var invoiceId = component.get('v.invoiceId');
        var isEstimate = component.get('v.isEstimateType');
        if (!invoiceId) {
            helper.init(component);
        } else if (!isEstimate) {
            var filters = component.find('filters');
            $A.util.toggleClass(filters, 'slds-hide');
            helper.getInvoice(component, invoiceId);
        } else {
            var sort = component.find('sort');
            $A.util.toggleClass(sort, 'slds-hide');
            helper.getEstimate(component, invoiceId);
        }
    },
    selectAllInvoices: function (component, event, helper) {
        $A.util.removeClass(component.find('filters'), 'slds-hide');
        $A.util.removeClass(component.find('invoicesNotOnPaymentPlanSection'), 'slds-hide');

        var areAllInvoicesSelected = component.get('v.AreAllInvoicesSelected');
        $A.get("e.c:SelectInvoicesEvent").setParams({"SelectAll": !areAllInvoicesSelected}).fire();
        component.set('v.AreAllInvoicesSelected', !areAllInvoicesSelected);
    },

    refreshAllInvoicesSelected: function (component, event, helper) {

        var areAllinvoicesSelected = true;
        component.get('v.invoices').forEach(function (item, i, arr) {
            areAllinvoicesSelected = areAllinvoicesSelected && item.get('v.activated');
        });
        component.set('v.AreAllInvoicesSelected', areAllinvoicesSelected);
    },

    filterInvoices: function (component, event, helper) {
        $A.util.removeClass(component.find('filters'), 'slds-hide');
        $A.util.removeClass(component.find('invoicesNotOnPaymentPlanSection'), 'slds-hide');
        if (event.target.id) {
            component.set('v.groupFilter', event.target.id);
            helper.getAllInvoices(component);
        }

    },

    hideSections: function (component, event, helper) {
        $A.util.toggleClass(component.find('filters'), 'slds-hide');
        $A.util.toggleClass(component.find('invoicesNotOnPaymentPlanSection'), 'slds-hide');
        var calculatePaymentBalance = $A.get("e.c:calculatePaymentBalanceEvent");
        var selectedBalance = 0;
        var blockInvoices = component.get('v.blockInvoices');
        for (var i = 0; i < blockInvoices.length; i++) {
            selectedBalance += blockInvoices[i].get('v.invoice').balanceDue;
        }
        calculatePaymentBalance.setParams({
            "paymentBalance": selectedBalance
        });
        calculatePaymentBalance.fire();
    },

    reInitData: function (component, event, helper) {
        $A.util.removeClass(component.find('filters'), 'slds-hide');
        $A.util.removeClass(component.find('invoicesNotOnPaymentPlanSection'), 'slds-hide');
        var activeTab = event.getParam('tabName');
        component.set('v.selectedTab', activeTab);
        var invoiceId = component.get('v.invoiceId');
        var isEstimate = event.getParam('isEstimateType');
        component.set('v.isEstimateType', isEstimate);
        if (!invoiceId || activeTab === 'CreatePaymentPlan') {
            helper.getAllInvoices(component);
        } else if (!isEstimate) {
            var filters = component.find('filters');
            $A.util.addClass(filters, 'slds-hide');
            helper.getInvoice(component, invoiceId);
        } else {
            var sort = component.find('sort');
            $A.util.addClass(sort, 'slds-hide');
            helper.getEstimate(component, invoiceId);
        }
    },
    patientsVisibility: function (component, Event, helper) {
        var blockSelect = component.find('patientList');
        $A.util.toggleClass(blockSelect, 'slds-is-open');
    },
    patientSelect: function (component, event, helper) {
        $A.util.toggleClass(event.currentTarget, 'slds-is-selected');
        var patientId = event.currentTarget.dataset.patientId;
        var patientSetOld = component.get('v.patientSet');
        var patientLabel = '';
        var selectCounter = 0;
        for (var i = 0; i < patientSetOld.length; i++) {
            if (patientSetOld[i].id === patientId) {
                patientSetOld[i].isSelected = $A.util.hasClass(event.currentTarget, 'slds-is-selected');
            }
            if (patientSetOld[i].isSelected) {
                selectCounter += 1;
                patientLabel += patientSetOld[i].name + ", ";
            }
        }
        patientLabel = patientLabel.substring(0, patientLabel.length - 2);
        if (selectCounter !== patientSetOld.length) {
            if (selectCounter === 0) {
                component.set('v.patientLabel', 'Not Selected');
            } else {
                component.set('v.patientLabel', patientLabel);
            }
        } else {
            component.set('v.patientLabel', 'All Patients');
        }

        helper.getAllInvoices(component);
    }

})