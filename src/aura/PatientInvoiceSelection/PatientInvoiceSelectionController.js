({
	doInit: function(component, event, helper) {
        var invoiceId = component.get('v.invoiceId');
		var isEstimate = component.get('v.isEstimateType');
		console.log('Patient type:', isEstimate);
		if (invoiceId == null) {
			helper.getAllInvoices(component);
		} else if(!isEstimate) {
            var filtes = component.find('filtes');
            $A.util.toggleClass(filtes, 'slds-hide');
			helper.getInvoice(component, invoiceId);
		}else{
			var filtes = component.find('filtes');
            $A.util.toggleClass(filtes, 'slds-hide');
			helper.getEstimate(component, invoiceId);
		}
    },
    selectAllInvoices : function(component, event, helper) {
        console.log('event', event);
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
        if(event.target.id){
            component.set('v.groupFilter', event.target.id);
            helper.getAllInvoices(component);
        }
        console.log('groupFilter', component.get('v.groupFilter'));

    }
})