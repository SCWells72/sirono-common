({
	showError: function(cmp, message) {
		cmp.set('v.hasError', true);
		cmp.find('notificationCmp').showError(message);
	},
	toggleSections: function(cmp) {
		var cardCmp = cmp.find('editCreditCard');
		var termsCmp = cmp.find('editTerms');
		$A.util.toggleClass(termsCmp, 'slds-hide');
		$A.util.toggleClass(cardCmp, 'slds-hide');
	}
})