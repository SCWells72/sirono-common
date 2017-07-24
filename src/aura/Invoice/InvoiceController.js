/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
	activateTile : function (component, event, helper) {
		console.log(component.get("v.tileId"));
		$A.get("e.c:activateTileRequest").setParams({
			"tileId" : component.get("v.tileId")
		}).fire();
	},

	activateTileHandler : function (component, event, helper) {
		var tileId = component.get("v.tileId");
		if (event.getParam('tileId') == tileId) {
			$A.util.addClass(component.find('tile'), 'active');
		} else {
			$A.util.removeClass(component.find('tile'), 'active');
		}
	},
	changePage : function(component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({
			'url' : '/payments' 
		}).fire();
	},
	sendInvoiceNowToHeader: function(component, event, helper) {
        var appEvent = $A.get("e.c:payNowRequest");
        appEvent.setParams({ "invoiceId" : component.get('v.invoice.singleInvoice.Id'), 'type': 'MakeAPayment' });
        appEvent.fire();
	},
	sendInvoiceCreateToHeader: function(component, event, helper) {
        var appEvent = $A.get("e.c:payNowRequest");
        appEvent.setParams({ 'type': 'CreatePaymentPlan' });
        appEvent.fire();
	}
})