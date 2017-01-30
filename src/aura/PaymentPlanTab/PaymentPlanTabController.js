({
	showCancelPlanDialog: function (cmp, e, hlpr) {
		try {
		cmp.find('cancelPlanCmp').showCancelDialog();
		$A.util.removeClass(cmp.find('cancelPlan'), 'slds-hide');
		} catch (e) {
			console.log(e);
		}
	},
	editTerms: function(cmp, e, hlpr) {
		var editTerms = cmp.find('editTerms');
		$A.util.removeClass(editTerms, 'slds-hide');
		cmp.set('v.editTermsVisible', true);
		$A.util.addClass(cmp.find('planInfo'), 'slds-hide');
		cmp.set('v.activeSectionId', 'editTerms');
	},
	editPaymentMethod: function(cmp, e, hlpr) {
		var editPaymentMethod = cmp.find('editPaymentMethod');
		$A.util.toggleClass(editPaymentMethod, 'slds-hide');
		$A.util.addClass(cmp.find('planInfo'), 'slds-hide');
		cmp.set('v.activeSectionId', 'editPaymentMethod');
	},
	doCmpInit: function(cmp, e, hlpr) {
		var params = e.getParam('arguments');
		if (!params) {
			return;
		}
		cmp.set('v.PaymentInfo', params.PaymentInfo);
		cmp.set('v.PaymentRequestInfo', params.PaymentRequestInfo);
		hlpr.resetCmp(cmp);
	},
	doInitInfo: function(cmp, e, hlpr) {
		e.stopPropagation();
		//TODO add resetCmp
		//hlpr.resetCmp(cmp);
	},
	showSuccess: function(cmp, e, hlpr) {
		e.stopPropagation();

		$A.util.addClass(cmp.find('planInfo'), 'slds-hide');
		$A.util.addClass(cmp.find(cmp.get('v.activeSectionId')), 'slds-hide');
		$A.util.removeClass(cmp.find('message'), 'slds-hide');
		if (cmp.get('v.activeSectionId') === 'editTerms') {
			cmp.set('v.editTermsVisible', false);
		}
		cmp.set('v.activeSectionId', '');
	},
	resetCmp: function(cmp, e, hlpr) {
		cmp.getEvent('resetPaymentTabs').fire();
	}
})