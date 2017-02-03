({
	doCmpInit: function(cmp, e, hlpr) {
		var selections = [];
		var _tmp = 1;
		while (_tmp <= 31) {
			selections.push(_tmp);
			_tmp++;
		}
		cmp.set('v.dayOfMonthSelection', selections);
		cmp.set('v.hasError', false);
	},
	cancelAction: function (cmp, e, hlpr) {
		cmp.getEvent("initPlanInfo").fire();
		cmp.set('v.hasError', false);
	},
	cancelEditCardAction: function(cmp, e, hlpr) {
		e.stopPropagation();
		hlpr.toggleSections(cmp);
	},
	updatePaymenTerms: function(cmp, e, hlpr) {
		cmp.set('v.hasError', false);
		var PaymentRequestInfo = cmp.get('v.PaymentRequestInfo');

		var updateTermsAction = cmp.get('c.doEditPaymentPlan');
		updateTermsAction.setParams({
			'paymentInfoStr': JSON.stringify( PaymentRequestInfo )
		});
		updateTermsAction.setCallback(this, function(response) {
			try {
			if (response.getState() === 'SUCCESS') {
				var plan = response.getReturnValue();
				console.log('responseresponse: ' , plan);
				cmp.getEvent('updatePaymentTerms').setParams({
					paymentPlan: plan
				}).fire();
				return;
			}

			var errors = response.getError();
			if (errors) {
				hlpr.showError(cmp, errors? errors[0].message : 'Error has been occurred');
			}
			} catch (e) {console.log(e);}
		});
		$A.enqueueAction(updateTermsAction);
	},
	createPaymenTerms: function(cmp, e, hlpr) {
		hlpr.toggleSections(cmp);
	},
	doCalcView: function (cmp, e, hlpr) {
		var PaymentRequestInfo = cmp.get('v.PaymentRequestInfo');
		var newPlanValue = parseFloat(PaymentRequestInfo.planValue, 10);
		cmp.set('v.sliderValue', Math.floor(newPlanValue));
		cmp.set('v.sliderValuePart', (newPlanValue % 1).toFixed(2).toString().substring(2));
		cmp.set('v.hasError', false);
		
		if (PaymentRequestInfo.planValue > PaymentRequestInfo.totalAmount) {
			var message = "Monthly amount cannot exceed current payment plan balance";
			hlpr.showError(cmp, message);
		}
	},
	changeSlider: function(cmp, e, hlpr) {
		var newPlanValue = parseFloat(e.srcElement.value || 0, 10);
		var PaymentRequestInfo = cmp.get('v.PaymentRequestInfo');
		var PaymentInfo = cmp.get('v.PaymentInfo');

		cmp.set('v.hasError', false);
		if (validateInstallments(newPlanValue, PaymentRequestInfo.totalAmount, PaymentInfo)) {
			var totalInstallment = Math.round( PaymentRequestInfo.totalAmount / newPlanValue, 10 );
			totalInstallment  = totalInstallment * newPlanValue >= PaymentRequestInfo.totalAmount ? totalInstallment : totalInstallment + 1;
			PaymentRequestInfo.totalInstallments = totalInstallment;
			PaymentRequestInfo.planValue = parseFloat(newPlanValue, 10);
			cmp.set('v.PaymentRequestInfo', PaymentRequestInfo);
		}

		function validateInstallments(planValue, totalAmount, PaymentInfo) {
			if (planValue < PaymentInfo.settings.Min_Installment_Amount__c) {
				var message = 'Monthly amount must be equal to or greater than $' + PaymentInfo.settings.Min_Installment_Amount__c + '.';
				hlpr.showError(cmp, message);
				return false;
			}

			if (planValue >= PaymentInfo.settings.Min_Installment_Amount__c) {
				var totalInstallment = Math.round( PaymentRequestInfo.totalAmount / planValue, 10 );
				totalInstallment  = totalInstallment * planValue >= PaymentRequestInfo.totalAmount ? totalInstallment : totalInstallment + 1;
				var minimumInstallmentAmount = 0;

				if (PaymentInfo.settings.Max_Number_Plan_Installments__c > 0) {
					minimumInstallmentAmount = parseFloat( PaymentRequestInfo.totalAmount / PaymentInfo.settings.Max_Number_Plan_Installments__c );
				}
				
				if (totalInstallment > PaymentInfo.settings.Max_Number_Plan_Installments__c) {
					var message = 'This monthly amount would exceed ' + PaymentInfo.settings.Max_Number_Plan_Installments__c + ' installments.' +
						' The minimum allowed installment amount is $' + minimumInstallmentAmount.toFixed(2) + '.';
					hlpr.showError(cmp, message);
					return false;
				}
			}
			return true;
		};
	},
	showPopoverInfo: function(cmp, e, hlpr) {
		var myPopoverInfo = cmp.find('sldsjsPopoverInfo');
		$A.util.toggleClass(myPopoverInfo, 'slds-hide');
	}
})