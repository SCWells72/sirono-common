({
	myAction: function (component, event, helper) {

	},

	addInvoice : function(component, event, helper){
		console.log('addInvoice');
		component.set('v.addInvoiceShow', true);
	}
})