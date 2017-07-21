/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
	resetCmp: function(cmp) { 
		$A.util.removeClass(cmp.find('planInfo'), 'slds-hide');
		$A.util.addClass(cmp.find('message'), 'slds-hide');
		cmp.set('v.editTermsVisible', !cmp.get('v.PaymentInfo.hasPaymentPlan'));
		$A.util.addClass(cmp.find(cmp.get('v.activeSectionId')), 'slds-hide');
		$A.util.addClass(cmp.find('addInvoices'), 'slds-hide');
		cmp.set('v.addInvoiceVisible', false);
		cmp.set('v.activeSectionId', null);
	}
})