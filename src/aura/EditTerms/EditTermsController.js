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
	changePaymentBalance : function(cmp, e, hlpr){
		console.log('selected balance event');
		var balance = e.getParam('paymentBalance');
		console.log('balance', balance);
		var paymentRequestInfo = cmp.get('v.PaymentRequestInfo');
		console.log(paymentRequestInfo, paymentRequestInfo.length);
		if(paymentRequestInfo.totalAmount != undefined){
			paymentRequestInfo.totalAmount = balance;
			cmp.set('v.PaymentRequestInfo', paymentRequestInfo);
		}else{
			cmp.set('v.selectedInvoiceBalance', balance);
		}
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
		cmp.getEvent('updatePaymentTerms').fire();
		cmp.set('v.hasError', false);
	},
	createPaymenTerms: function(cmp, e, hlpr) {
		console.info('PaymentRequestInfo', cmp.get('v.PaymentRequestInfo'));
		hlpr.toggleSections(cmp);
	},
	doCalcView: function (cmp, e, hlpr) {
		var PaymentRequestInfo = cmp.get('v.PaymentRequestInfo');
		var PaymentInfo = cmp.get('v.PaymentInfo');
		cmp.set('v.sliderValue', Math.floor(PaymentRequestInfo.planValue));
		cmp.set('v.sliderValuePart', (PaymentRequestInfo.planValue % 1).toFixed(2).toString().substring(2));
		cmp.set('v.hasError', false);
		
		if (PaymentRequestInfo.planValue > PaymentRequestInfo.totalAmount) {
			var message = "Monthly amount cannot exceed current payment plan balance";
			hlpr.showError(cmp, message);
		}
	},
	changeSlider: function(cmp, e, hlpr) {
		var newPlanValue = e.srcElement.value;
		console.log('PP planned value', newPlanValue);

		var PaymentRequestInfo = cmp.get('v.PaymentRequestInfo');
		var PaymentInfo = cmp.get('v.PaymentInfo');

		cmp.set('v.hasError', false);
		if (validateInstallments(newPlanValue, PaymentRequestInfo.totalAmount, PaymentInfo)) {
			var totalInstallment = Math.round( PaymentRequestInfo.totalAmount / newPlanValue, 10 );
			PaymentRequestInfo.totalInstallments = totalInstallment;
			PaymentRequestInfo.planValue = newPlanValue;
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
				var minimumInstallmentAmount = 0;

				if (PaymentInfo.settings.Max_Number_Plan_Installments__c > 0) {
					minimumInstallmentAmount = parseFloat( PaymentRequestInfo.totalAmount / PaymentInfo.settings.Max_Number_Plan_Installments__c );
				}
				
				if (totalInstallment > PaymentInfo.settings.Max_Number_Plan_Installments__c) {
					var message = 'This monthly amount would exceed ' + PaymentInfo.settings.Max_Number_Plan_Installments__c + ' installments.' +
						' The minimum allowed installment amount is $' + minimumInstallmentAmount + '.';
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