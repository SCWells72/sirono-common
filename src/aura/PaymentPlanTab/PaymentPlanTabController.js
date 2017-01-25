({
	closeModal: function (cmp, e, hlpr) {
		hlpr.hidePopup(cmp, 'cancelDialog', 'slds-fade-in-');
		hlpr.hidePopup(cmp, 'backdrop', 'slds-backdrop--');
	},
	showCancelPlanDialog : function (cmp, e, hlpr) {
		hlpr.showPopup(cmp, 'cancelDialog', 'slds-fade-in-');
		hlpr.showPopup(cmp,'backdrop','slds-backdrop--');
	},
	editTerms: function(cmp, e, hlpr) {
		var editTerms = cmp.find('editTerms');
		$A.util.toggleClass(editTerms, 'slds-hide');
		$A.util.addClass(cmp.find('planInfo'), 'slds-hide');
		cmp.set('v.activeSectionId', 'editTerms');
	},
	editPaymentMethod: function(cmp, e, hlpr) {
		var editPaymentMethod = cmp.find('editPaymentMethod');
		$A.util.toggleClass(editPaymentMethod, 'slds-hide');
		$A.util.addClass(cmp.find('planInfo'), 'slds-hide');
		cmp.set('v.activeSectionId', 'editPaymentMethod');
	},
	doInitInfo: function(cmp, e, hlpr) {
		e.stopPropagation();

		$A.util.removeClass(cmp.find('planInfo'), 'slds-hide');
		$A.util.toggleClass(cmp.find(cmp.get('v.activeSectionId')), 'slds-hide');
		cmp.set('v.activeSectionId', '');
	},
	showSuccess: function(cmp, e, hlpr) {
		e.stopPropagation();

		$A.util.addClass(cmp.find('planInfo'), 'slds-hide');
		$A.util.addClass(cmp.find(cmp.get('v.activeSectionId')), 'slds-hide');
		$A.util.removeClass(cmp.find('message'), 'slds-hide');
		cmp.set('v.activeSectionId', '');
	}
})