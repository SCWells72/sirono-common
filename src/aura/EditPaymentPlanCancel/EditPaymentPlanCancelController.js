({
	showCancelPlanDialog: function (cmp, e, hlpr) {
		hlpr.showPopup(cmp, 'cancelDialog', 'slds-fade-in-');
		hlpr.showPopup(cmp,'backdrop','slds-backdrop--');
		cmp.set('v.hasError', false);
	},
	closeModal: function (cmp, e, hlpr) {
		hlpr.hidePopup(cmp, 'cancelDialog', 'slds-fade-in-');
		hlpr.hidePopup(cmp, 'backdrop', 'slds-backdrop--');
		cmp.set('v.hasError', false);
	},
	cancelPlan: function(cmp, e, hlpr) {
		var cancelPlan = cmp.get("c.deletePaymentPlan");
		cancelPlan.setParams({
			sfPaymentPlanId: cmp.get('v.PaymentInfo.paymentPlan.Id')
		});
		cancelPlan.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				hlpr.hidePopup(cmp, 'cancelDialog', 'slds-fade-in-');
				hlpr.hidePopup(cmp, 'backdrop', 'slds-backdrop--');
				//cmp.getEvent('resetPaymentTabs').fire();
		        $A.get("e.force:navigateToURL").setParams({
					'url' : '/',
					'isredirect' : true 
				}).fire();
			} else  {
				console.error(response.getError());
				var errors = response.getError();
				if (errors) {
					hlpr.showError(cmp, errors? errors[0].message : 'Error has been occurred');
				}
			}
		});
		$A.enqueueAction(cancelPlan);
	}
})