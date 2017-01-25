({
	myAction: function (component, event, helper) {

	},

	selectInvoice: function(component, event, helper){
			$A.util.toggleClass(component.find('selectIcon'), 'selected');
			var activated = component.get('v.activated');
			var balanceDue = component.get('v.invoice').balanceDue;
			if(!activated){
				balanceDue = - balanceDue;
			}
			var calculatePaymentBalance  = $A.get("e.c:calculatePaymentBalanceEvent");
			calculatePaymentBalance.setParams({
				"changeSum" : balanceDue,
			});
			calculatePaymentBalance.fire();
			component.set('v.activated', !activated);
	},

	openInvoiceDetails : function(component, event, helper){
		console.log('open invoice details');
		console.log(component.get("v.tileId"));
		$A.get("e.c:activateTileRequest").setParams({
			"tileId" : component.get("v.tileId")
		}).fire();
	}


})