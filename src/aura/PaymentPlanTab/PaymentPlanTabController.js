({
	editPaymentCancel: function (cmp, e, hlpr) {
		$A.util.removeClass(cmp.find('cancelPlan'), 'slds-hide');
		cmp.find('cancelPlanCmp').showCancelDialog();
	},
	editTerms: function(cmp, e, hlpr) {
		$A.get("e.c:editTermsAction").fire();
		var editTerms = cmp.find('editTerms');
		$A.util.removeClass(editTerms, 'slds-hide');
		cmp.set('v.editTermsVisible', true);
		$A.util.addClass(cmp.find('planInfo'), 'slds-hide');
		cmp.set('v.activeSectionId', 'editTerms');
	},
	
	hideBlocks : function(cmp, e, hlpr){
		console.log('hideBlocks', cmp.get('v.addInvoiceVisible'));
		if(cmp.get('v.addInvoiceVisible')){
			var editTerms = cmp.find('editTerms');
			$A.util.addClass(editTerms, 'slds-hide');
			$A.util.addClass(cmp.find('planInfo'), 'slds-hide');
		}
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
		console.log('params', params);
		
		cmp.set('v.PaymentInfo', params.PaymentInfo);
		cmp.set('v.PaymentRequestInfo', params.PaymentRequestInfo);
		hlpr.resetCmp(cmp);
	},
	doInitInfo: function(cmp, e, hlpr) {
		e.stopPropagation();
		hlpr.resetCmp(cmp);
	},
	showSuccess: function(cmp, e, hlpr) {
		e.stopPropagation();
		var params = e.getParams();
		if (params && params.paymentPlan) {
			cmp.set('v.PlanInfoRecord', params.paymentPlan);
			console.log('isEditTerms', params.isEditTerms);
			if(params.isEditTerms){
				cmp.set('v.showEditTermsMessage', params.isEditTerms);
			}
		}
		$A.util.addClass(cmp.find('planInfo'), 'slds-hide');
		$A.util.addClass(cmp.find(cmp.get('v.activeSectionId')), 'slds-hide');
		$A.util.removeClass(cmp.find('message'), 'slds-hide');
		cmp.set('v.isSuccess', true);
		cmp.set('v.editTermsVisible', false);
		cmp.set('v.activeSectionId', null);
		cmp.set('v.addInvoiceVisible', false);	
	},
	resetCmp: function(cmp, e, hlpr) {
		cmp.getEvent('resetPaymentTabs').fire();
		var appEvent = $A.get("e.c:switchTab");
		appEvent.setParams({ "tabName" : 'CreatePaymentPlan'});
        appEvent.fire();
	}
})