({
	showDetails : function (component, event, helper) {
		var tileId = event.getParam('tileId');
		if (component.get("v.activeEstimate") != tileId) {
			component.set("v.activeEstimate",tileId);
			component.set("v.estimate",component.get("v.listOfEstimates")[tileId]);
		}
	}
})