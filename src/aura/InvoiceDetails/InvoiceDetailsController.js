({
	showDetails : function (component, event, helper) {
		var tileId = event.getParam('tileId');
		if (component.get("v.activeInvoice") != tileId) {
			component.set("v.activeInvoice",tileId);
			component.set("v.invoice",component.get("v.listOfInvoices")[tileId]);
		}
	}
})