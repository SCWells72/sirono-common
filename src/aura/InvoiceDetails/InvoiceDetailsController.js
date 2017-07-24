/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
	showDetails : function (component, event, helper) {
		var tileId = event.getParam('tileId');
		if (component.get("v.activeInvoice") != tileId) {
			component.set("v.activeInvoice", tileId);
			var invoice = component.get("v.listOfInvoices")[tileId];
			component.set("v.invoice", invoice);
			if (invoice != null) { 
				console.log('showDetails');
				var totalCharges = 0;
				var totalCredits = 0;
				for (var i = 0; i < invoice.allGroups.length; i++) {
					totalCharges += invoice.allGroups[i].totalCharges;
					totalCredits += invoice.allGroups[i].totalCredits;
				}
				component.set("v.invoice.invoiceTotalCharges", totalCharges);
				component.set("v.invoice.invoiceTotalCredits", totalCredits);
			} 
		} 
	},	
	sendInvoiceNowToHeader: function(component, event, helper) {
        var appEvent = $A.get("e.c:payNowRequest");
        appEvent.setParams({ "invoiceId" : component.get('v.invoice.singleInvoice.Id'), 'type': 'MakeAPayment' });
        appEvent.fire();
	},
	sendInvoiceCreateToHeader: function(component, event, helper) {
        var appEvent = $A.get("e.c:payNowRequest");
        appEvent.setParams({ "invoiceId" : component.get('v.invoice.singleInvoice.Id'), 'type': 'CreatePaymentPlan' });
        appEvent.fire();
	}
})