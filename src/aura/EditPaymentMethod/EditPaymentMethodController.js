({
	doCmpInit: function(cmp, e, hlpr) {
		hlpr.doCmpInit(cmp);
	},
	cancelAction: function (cmp, e, hlpr) {
		cmp.getEvent('initPlanInfo').fire();
	},
	editCreditCard: function(cmp, e, hlpr) {
		e.stopPropagation();

		$A.util.toggleClass(cmp.find('editPaymentMethod'), 'slds-hide');
		$A.util.toggleClass(cmp.find('editCreditCard'), 'slds-hide');
		return false;
	},
	addNewCreditCard: function(cmp, e, hlpr) {
		e.stopPropagation();

		$A.util.toggleClass(cmp.find('editPaymentMethod'), 'slds-hide');
		$A.util.toggleClass(cmp.find('editCreditCard'), 'slds-hide');
		return false;
	},
	cancelEditCardAction: function(cmp, e, hlpr) {
		e.stopPropagation();

		$A.util.toggleClass(cmp.find('editPaymentMethod'), 'slds-hide');
		$A.util.toggleClass(cmp.find('editCreditCard'), 'slds-hide');
	},
	updatePaymentMethod: function(cmp, e, hlpr) {
		cmp.getEvent('updatePaymentMethod').fire();
	}
})