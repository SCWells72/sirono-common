/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    doInit: function (component, event, helper) {
        helper.init(component);
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
    },
    showDetails: function (component, event, helper) {
        var tileId = event.getParam('tileId');
        var activeTile = component.get('v.activeTile');
        if (activeTile != tileId) {
            var listOfInvoices = component.get('v.listOfInvoices');
            $A.createComponent(
                    "c:InvoiceDetails",
                    {
                        "invoice": listOfInvoices[tileId]
                    },
                    function (newComponent, status, errorMessage) {
                        if (status === "SUCCESS") {
                            var invoiceDetails = component.find('invoice_details');
                            invoiceDetails.set("v.body", newComponent);
                        }
                        else if (status === "INCOMPLETE") {
                            console.log("No response from server or client is offline.");
                        }
                        else if (status === "ERROR") {
                            console.log("Error: " + errorMessage);
                        }
                    }
            );
            component.set('activeTile', tileId);
            console.log('finish show detail');
        }
    },
    closeAllLists: function (component, event, helper) {
        var blockSelect = component.find('patientList');
        $A.util.removeClass(blockSelect, 'slds-is-open');

        blockSelect = component.find('blockSelect');
        $A.util.removeClass(blockSelect, 'showSelect');
    },

    filterInvoices: function (component, event, helper) {
        if (component.get('v.groupFilter') != event.target.dataset.groupType) {
            component.set('v.groupFilter', event.target.dataset.groupType);
            helper.getAllInvoices(component);
        }

        var blockSelect = component.find('patientList');
        $A.util.removeClass(blockSelect, 'slds-is-open');

        blockSelect = component.find('blockSelect');
        $A.util.removeClass(blockSelect, 'showSelect');
    },

    activateSelect: function (component, event, helper) {
        var blockSelect = component.find('blockSelect');
        $A.util.toggleClass(blockSelect, 'showSelect');

        blockSelect = component.find('patientList');
        $A.util.removeClass(blockSelect, 'slds-is-open');
    },
    patientsVisibility: function (component, event, helper) {
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
            if (patientSetOld[i].id == patientId) {
                patientSetOld[i].isSelected = $A.util.hasClass(event.currentTarget, 'slds-is-selected');
            }
            if (patientSetOld[i].isSelected) {
                selectCounter += 1;
                patientLabel += patientSetOld[i].name + ", ";
            }
        }
        patientLabel = patientLabel.substring(0, patientLabel.length - 2);
        if (selectCounter != patientSetOld.length) {
            if (selectCounter == 0) {
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