({
	cancelAction: function (cmp, e, hlpr) {
		cmp.getEvent("initPlanInfo").fire();
	},
	updatePaymenTerms: function(cmp, e, hlpr) {
		cmp.getEvent('updatePaymentTerms').fire();
	},
	changeSlider: function(cmp, e, hlpr) {
		console.log(e.srcElement.value)
	},
	showPopoverInfo: function(component, event, helper) {
		var myPopoverInfo = component.find('sldsjsPopoverInfo');
		$A.util.toggleClass(myPopoverInfo, 'slds-hide');         
	}

})