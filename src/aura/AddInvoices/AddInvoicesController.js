({
	doCmpInit: function(cmp, e, hlpr) {
		var selections = [];
		var _tmp = 1;
		while (_tmp <= 31) {
			selections.push(_tmp);
			_tmp++;
		}
		cmp.set('v.dayOfMonthSelection', selections);
		var dayOfMonthSelection = cmp.find('dayOfMonth');
		dayOfMonthSelection.set('v.body', []);
		var body = dayOfMonthSelection.get('v.body');
		selections.forEach(function(selection){
			$A.createComponent(
				'aura:html',
				{
					tag: 'option',
					HTMLAttributes: {
						value: selection,
						text: selection
					}
				},
				function(newOption){
					if(cmp.isValid()){
						body.push(newOption);
						dayOfMonthSelection.set('v.body', body);
					}
				})
		});
		//dayOfMonthSelection.set('v.value', defaultDayOfMonth);

		cmp.set('v.hasError', false);

		console.log('fillTempVariables');
		cmp.set('v.PaymentInfoTemp', cmp.get('v.PaymentInfo'));
		cmp.set('v.PaymentRequestInfoTemp', cmp.get('v.PaymentRequestInfo'));

		var PaymentRequestInfo = cmp.get('v.PaymentRequestInfo');
		var PaymentInfo = cmp.get('v.PaymentInfo');
		var newPlanValue = parseFloat(PaymentRequestInfo.planValue, 10);
		cmp.set('v.sliderValue', Math.floor(newPlanValue));
		cmp.set('v.sliderValuePart', (newPlanValue % 1).toFixed(2).toString().substring(2));
		cmp.set('v.hasError', false);

		var minInstallmentAmount = hlpr.getCalculatedMinInstallmentAmount(PaymentInfo.settings, PaymentRequestInfo.totalAmount);
		cmp.set('v.minAmount', minInstallmentAmount);

		if (newPlanValue > PaymentRequestInfo.totalAmount) {
			var message = "Monthly amount cannot exceed current payment plan balance";
			hlpr.showError(cmp, message);
		}

	},
	resetCmp: function(cmp, e, hlpr) {
		hlpr.toggleSections(cmp);
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
			if (response.getState() === 'SUCCESS') {
				var plan = response.getReturnValue();
				cmp.getEvent('updatePaymentTerms').setParams({
					paymentPlan: plan
				}).fire();
				return;
			}

			var errors = response.getError();
			if (errors) {
				hlpr.showError(cmp, errors? errors[0].message : 'Error has been occurred');
			}
		});
		$A.enqueueAction(updateTermsAction);
	},

	createPaymenTerms: function(cmp, e, hlpr) {
		hlpr.toggleSections(cmp);
		
	},
	doCalcView: function (cmp, e, hlpr) {
		var PaymentRequestInfo = cmp.get('v.PaymentRequestInfo');
		var PaymentInfo = cmp.get('v.PaymentInfo');
		var newPlanValue = parseFloat(PaymentRequestInfo.planValue, 10);
		cmp.set('v.sliderValue', Math.floor(newPlanValue));
		cmp.set('v.sliderValuePart', (newPlanValue % 1).toFixed(2).toString().substring(2));
		cmp.set('v.hasError', false);

		var minInstallmentAmount = hlpr.getCalculatedMinInstallmentAmount(PaymentInfo.settings, PaymentRequestInfo.totalAmount);
		cmp.set('v.minAmount', minInstallmentAmount);

		if (newPlanValue > PaymentRequestInfo.totalAmount) {
			var message = "Monthly amount cannot exceed current payment plan balance";
			hlpr.showError(cmp, message);
		}
	},
	changeSlider: function(cmp, e, hlpr) {
		var newPlanValue = parseFloat(e.srcElement.value || 0, 10);
		var PaymentRequestInfo = cmp.get('v.PaymentRequestInfo');
		var PaymentInfo = cmp.get('v.PaymentInfo');

		cmp.set('v.hasError', false);
		if (validateInstallments(newPlanValue, PaymentRequestInfo.totalAmount, PaymentInfo.settings)) {
			PaymentRequestInfo.totalInstallments = hlpr.getCalculatedIntallments(PaymentRequestInfo.totalAmount, newPlanValue);
			PaymentRequestInfo.planValue = newPlanValue;
			cmp.set('v.PaymentRequestInfo', PaymentRequestInfo);
		}

		function validateInstallments(planValue, totalAmount, Settings) {
			if (planValue < Settings.Min_Installment_Amount__c) {
				var message = 'Monthly amount must be equal to or greater than $' + Settings.Min_Installment_Amount__c + '.';
				hlpr.showError(cmp, message);
				return false;
			}

			if (planValue >= Settings.Min_Installment_Amount__c) {
				var totalInstallment = hlpr.getCalculatedIntallments(PaymentRequestInfo.totalAmount, planValue);

				if (totalInstallment > Settings.Max_Number_Plan_Installments__c) {
					var minimumInstallmentAmount = hlpr.getCalculatedMinInstallmentAmount(Settings, totalAmount);
					var message = 'This monthly amount would exceed ' + Settings.Max_Number_Plan_Installments__c + ' installments.' +
						' The minimum allowed installment amount is $' + minimumInstallmentAmount.toFixed(2) + '.';
					hlpr.showError(cmp, message);
					return false;
				}
			}
			return true;
		};
	},

	fillTempVariables: function(cmp, e, hlpr){
		
	},

	showPopoverInfo: function(cmp, e, hlpr) {
		var myPopoverInfo = cmp.find('sldsjsPopoverInfo');
		$A.util.toggleClass(myPopoverInfo, 'slds-hide');
	}
})