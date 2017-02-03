({
	doInit: function (component, event, helper) {
		console.log('init payments');
		var appEvent = $A.get("e.c:payCall");
        appEvent.fire();
	},
    payCall: function(component, event, helper) {
		console.log("set params payments");
		var invoiceId = event.getParam('invoiceId');
		var activeTab = event.getParam('activeTab');
		var isEstimate = event.getParam('isEstimateRecord');
		console.log('active', activeTab);
		console.log('invoice', invoiceId);
		console.log('isEstimate', isEstimate);
		$A.createComponent(
			"c:PatientInvoiceSelection",
			{
				"invoiceId" : invoiceId,
				"isEstimateType": isEstimate
			},
			function(newComponent, status, errorMessage) {
				if (status === "SUCCESS") {
					var patientInvoice = component.find('patientInvoiceSection');
					patientInvoice.set("v.body",newComponent);
				}
				else if (status === "INCOMPLETE") {
					console.log("No response from server or client is offline.");
				}
				else if (status === "ERROR") {
					console.log("Error: " + errorMessage);
				}
			}
		);
		$A.createComponent(
			"c:PaymentTabs",
			{
				"activeTab" : activeTab
			},
			function(newComponent, status, errorMessage) {
				if (status === "SUCCESS") {
					var paymentTabs = component.find('paymentTabsSection');
					paymentTabs.set("v.body",newComponent);
				}
				else if (status === "INCOMPLETE") {
					console.log("No response from server or client is offline.");
				}
				else if (status === "ERROR") {
					console.log("Error: " + errorMessage);
				}
			}
		);

    },
	bodyStatus: function (component, event, helper) {
        var status = event.getParam("collapse");
        var alert = event.getParam("alert");
        var scroll = component.find('payment_scroll');
        if(status == "true"){
            $A.util.removeClass(scroll,"small");
        }
        if(status == "false"){
            $A.util.addClass(scroll,"small");
        }
        if(alert == "true"){
            $A.util.removeClass(scroll,"alert");
        }
	}
})