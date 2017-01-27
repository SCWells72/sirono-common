({
	doInit: function (component, event, helper) {
		// component.set("v.isVisibleModal", false);
	},

	selectInvoice: function(component, event, helper){
		$A.util.toggleClass(component.find('selectIcon'), 'selected');
		var activated = component.get('v.activated');
		var balanceDue = component.get('v.invoice').balanceDue;
		if(!activated){
			balanceDue = - balanceDue;
		}
		component.set('v.activated', !activated);
		var calculatePaymentBalance  = $A.get("e.c:calculatePaymentBalanceEvent");
		calculatePaymentBalance.setParams({
			"changeSum" : balanceDue,
		});
		calculatePaymentBalance.fire();
	},

	toggleAllInvoices : function(component, event, helper) {
		if(component.get('v.activated') === event.getParam('SelectAll')){
			return;
		}
		var balanceDue;
		if(event.getParam('SelectAll')) {
			$A.util.addClass(component.find('selectIcon'), 'selected');
			balanceDue = -component.get('v.invoice').balanceDue;
		} else {
			$A.util.removeClass(component.find('selectIcon'), 'selected');
			balanceDue = component.get('v.invoice').balanceDue;
		}
		component.set('v.activated', event.getParam('SelectAll'));
		var calculatePaymentBalance  = $A.get("e.c:calculatePaymentBalanceEvent");
		calculatePaymentBalance.setParams({
			"changeSum" : balanceDue,
		});
		calculatePaymentBalance.fire();
	},

	openInvoiceDetails : function(component, event, helper){
		console.log('open invoice details');
		console.log(component.get("v.invoice"));
		$A.get("e.c:SingleInvoiceDetailsEvent").setParams({
			"invoice" : component.get("v.invoice")
		}).fire();
	}


})