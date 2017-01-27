({
	closeModal: function (component, event, helper) {
		var modal = component.find('slds-modal');
		var backdrop = component.find('slds-backdrop');
        $A.util.removeClass(modal, 'slds-fade-in-open');
        $A.util.removeClass(backdrop, 'slds-backdrop--open');
	},

	displayInvoiceDetails: function (component, event, helper) {
		var invoice = event.getParam('invoice');
		if (invoice != null) {
			component.set("v.invoice", invoice);
		}
		console.log('::::invoice:::' + invoice);

		var modal = component.find('slds-modal');
		var backdrop = component.find('slds-backdrop');
        $A.util.addClass(modal, 'slds-fade-in-open');
        $A.util.addClass(backdrop, 'slds-backdrop--open');
	}
})