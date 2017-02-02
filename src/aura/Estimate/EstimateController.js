({
	activateTile : function (component, event, helper) {
		console.log(component.get("v.tileId"));
		$A.get("e.c:activateEstimateTileRequest").setParams({
			"tileId" : component.get("v.tileId")
		}).fire();
	},

	sendEstimateNowToHeader: function(component, event, helper) {
        var appEvent = $A.get("e.c:payNowRequest");
        appEvent.setParams({ "invoiceId" : component.get('v.estimate.singleEncounter.Id'), 'type': 'MakeAPayment', 'isEstimate': true });
        appEvent.fire();
	},

	activateTileHandler : function (component, event, helper) {
		var tileId = component.get("v.tileId");
		console.log(tileId);
		console.log(event.getParam('tileId'));
		console.log(event.getParam('tileId') == tileId);
		if (event.getParam('tileId') == tileId) {
			$A.util.addClass(component.find('tile'), 'active');
		} else {
			$A.util.removeClass(component.find('tile'), 'active');
		}
	},
})