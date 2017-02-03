({
	resetCmp: function(cmp) { 
		$A.util.removeClass(cmp.find('planInfo'), 'slds-hide');
		$A.util.addClass(cmp.find('message'), 'slds-hide');
		cmp.set('v.editTermsVisible', !cmp.get('v.PaymentInfo.hasPaymentPlans'));
		$A.util.addClass(cmp.find(cmp.get('v.activeSectionId')), 'slds-hide');
		cmp.set('v.activeSectionId', null);
	}
})