({
	showDetails : function (component, event, helper) {
		var tileId = event.getParam('tileId');
		if (component.get("v.activeEstimate") != tileId) {
			component.set("v.activeEstimate",tileId);
			component.set("v.estimate",component.get("v.listOfEstimates")[tileId]);
		}
	},

	sendEstimateNowToHeader: function(component, event, helper) {
        var appEvent = $A.get("e.c:payNowRequest");
        appEvent.setParams({ "invoiceId" : component.get('v.estimate.singleEncounter.Id'), 'type': 'MakeAPayment', 'isEstimate': true });
        appEvent.fire();
	},
})