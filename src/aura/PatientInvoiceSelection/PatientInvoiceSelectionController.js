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

    selectAllInvoices : function(component, event, helper) {
        var areAllInvoicesSelected = component.get('v.AreAllInvoicesSelected');
        $A.get("e.c:SelectInvoicesEvent").setParams({"SelectAll" : !areAllInvoicesSelected}).fire();
        component.set('v.AreAllInvoicesSelected', !areAllInvoicesSelected);
    },

    refreshAllInvoicesSelected : function(component, event, helper) {
        var areAllinvoicesSelected = true;
        component.get('v.invoices').forEach(function(item, i, arr) {
            areAllinvoicesSelected = areAllinvoicesSelected && item.get('v.activated');
        });
        component.set('v.AreAllInvoicesSelected', areAllinvoicesSelected);
    },

    filterInvoices : function(component, event, helper) {
        console.log('Filter');
    }
})