({
	returnToAccountSummary: function (component, event, helper) {
		$A.get("e.force:navigateToURL").setParams({
			'url' : '/',
			'isredirect' : true 
		}).fire();
	},

	makeAdditionalPayment: function (component, event, helper) {
		console.log('makeAdditionalPayment');
		component.set('v.isPaymentCompleted', false);
		var successMessageCmp = component.find('successMessage');
		var isEstimateType = component.get('v.isEstimatePayment');
		console.log('isEstimateType (successMessage)', isEstimateType);
		var toggleEvent = $A.get("e.c:ToggleSuccessMessageEvent");
		toggleEvent.setParams({
			displaySironoHeader : false,
			displayMakePayment : true,
			displaySuccessMessage : false,
		})
		console.log('toggleEvent', toggleEvent);
		var appEvent = $A.get("e.c:switchTab");
		appEvent.setParams({ 
			"tabName" : 'MakeAPayment',
			"isEstimateType" : component.get('v.isEstimatePayment')
		});
        appEvent.fire();
	}
})