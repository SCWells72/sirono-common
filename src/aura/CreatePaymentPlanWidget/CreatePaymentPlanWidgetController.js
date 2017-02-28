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
	showTooltip: function(component, event, helper) {
		var tooltip = component.find('popover-tooltip-payment');
		$A.util.toggleClass(tooltip,"slds-hide");
	}
})