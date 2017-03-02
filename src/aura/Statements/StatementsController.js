({
	showPopoverRight : function(component, event, helper) {
		var myPopoverRight = component.find('sldsjsPopoverRight');
		$A.util.toggleClass(myPopoverRight, 'slds-hide');         
	},

	doInit : function(component, event, helper) {
		helper.getAllInfo(component);
	},
    

})