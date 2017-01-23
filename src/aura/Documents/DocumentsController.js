({
	doInit : function(component, event, helper) {
		helper.getDocuments(component);
	},

	updateSorting : function(component, event, helper) {
		var orderType = event.currentTarget.dataset.orderType;
		helper.updateSorting(component, orderType);
		this.superRerender();
	},
    showPopoverRight : function(component, event, helper) {
		var myPopoverRight = component.find('sldsjsPopoverRight');
		$A.util.toggleClass(myPopoverRight, 'slds-hide');         
	}
})