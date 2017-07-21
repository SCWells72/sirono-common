/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
	changePage : function(component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({
			'url' : '/payments' 
		}).fire();
	},
	sendPageMakeToHeader: function(component, event, helper) {
        var appEvent = $A.get("e.c:payNowRequest");
        appEvent.setParams({ 'type': 'MakeAPayment' });
        appEvent.fire();
	},
	sendPageCreateToHeader: function(component, event, helper) {
        var appEvent = $A.get("e.c:payNowRequest");
        appEvent.setParams({ 'type': 'CreatePaymentPlan' });
        appEvent.fire();
	},
	sendUnpaidFilterToHeader: function(component, Event, helper) {
		var appEvent = $A.get("e.c:payNowRequest");
		appEvent.setParams({ 'type': 'MakeAPayment', 'filter': 'Unpaid' });
		appEvent.fire();
	},
	sendDelinquentFilterToHeader: function(component, Event, helper) {
		var appEvent = $A.get("e.c:payNowRequest");
		appEvent.setParams({ 'type': 'MakeAPayment', 'filter': 'Delinquent' });
		appEvent.fire();
	},
	sendOverdueFilterToHeader: function(component, Event, helper) {
		var appEvent = $A.get("e.c:payNowRequest");
		appEvent.setParams({ 'type': 'MakeAPayment', 'filter': 'Overdue' });
		appEvent.fire();
	},
})