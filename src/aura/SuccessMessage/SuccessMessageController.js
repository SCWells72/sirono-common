({
	makeAdditionalPayment: function (component, event, helper) {
		
	},

	makeAdditionalPayment: function (component, event, helper) {
		console.log('makeAdditionalPayment');

		var successMessageCmp = component.find('successMessage');
		var toggleEvent = $A.get("e.c:ToggleSuccessMessageEvent");
		toggleEvent.setParams({
			displaySironoHeader : false,
			displayMakePayment : true,
			displaySuccessMessage : false,
		})
		console.log('toggleEvent', toggleEvent);
	}
})