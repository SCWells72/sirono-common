({
	doInit: function(component, event, helper) {
        var appEvent = $A.get("e.c:payCall");
        appEvent.fire();
    },
    payCall: function(component, event, helper) {
        var invoiceId =  event.getParam('invoiceId');
        if (invoiceId === undefined) {

			helper.getAllInvoices(component);
        } else {
        	helper.getInvoice(component, invoiceId);
        }
    },
})