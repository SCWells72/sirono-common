({
	doCmpInit: function(cmp, e, hlpr) {
		var credtCardSelections = cmp.get('c.getCardSelectOptions');
		credtCardSelections.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				var selections = response.getReturnValue();
				var months = [];
				var years = [];

				for (var val in selections.YEARS) {
					years.push(val);
				}
				for (var val in selections.MONTHS) {
					months.push({
						value: val,
						label: selections.MONTHS[val]
					});
				}

				cmp.set('v.months', months);
				cmp.set('v.years', years);
			}
		});
		$A.enqueueAction(credtCardSelections);

		// init exp date values
		var date = new Date();
		date.setMonth(date.getMonth() + 1);
		var CreditCard = cmp.get('v.CreditCard') || {};
		CreditCard.expirationMonth = date.getMonth() + 1;
		CreditCard.expirationYear = date.getFullYear();
		cmp.set('v.CreditCard', CreditCard);
	},
	doDateValueInit: function(cmp, e, hlpr) {
		var executeOnDay = cmp.get('v.PaymentRequestInfo.executeOnDay') || 15;

		var date = new Date();
		date.setMonth(date.getMonth() + 1);
		date.setDate(executeOnDay);

		var curr_date = date.getDate();
		var curr_month = date.getMonth() + 1;
		var curr_year = date.getFullYear();

		cmp.set('v.nextPaymentDate', (curr_month < 10 ? '0' + curr_month : curr_month) + '/' + (curr_date < 10 ? '0' + curr_date : curr_date) + '/' + curr_year);
	},
	cancelAction: function (cmp, e, hlpr) {
		cmp.getEvent('paymentMethodInit').fire();
	},
	submitInfo: function(cmp, e, hlpr) {
		cmp.set('v.hasError', false);
		var PaymentRequestInfo = cmp.get('v.PaymentRequestInfo');
		var CreditCard = cmp.get('v.CreditCard');
		PaymentRequestInfo.creditCard = CreditCard;
		console.info('Save Payment Plan: info', JSON.parse(JSON.stringify(PaymentRequestInfo)));
		//if (!hlpr.isValidateExpDate(cmp) || 
		//	!hlpr.isValidateCVV(cmp)){ 
			//!hlpr.isValidateCardN(cmp)) {
		//	return;
		//}

		var createPlan = cmp.get('c.createPaymentPlan');
		createPlan.setParams({
			'paymentInfoStr': JSON.stringify( PaymentRequestInfo )
		});
		createPlan.setCallback(this, function(response) {
			try {
			if (response.getState() === 'SUCCESS') {
				var plan = response.getReturnValue();
				console.log('responseresponse: ' , plan);
				cmp.getEvent('paymentPlanCreated').setParams({
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
		$A.enqueueAction(createPlan);
	},
	validateExpDate : function(cmp, e, hlpr) {
		hlpr.isValidateExpDate(cmp);
	},
	validateCVV : function(cmp, e, hlpr) {
		//hlpr.validateCVV(cmp);
		hlpr.cutNOTNumber(cmp, "cvv");
	},
	validateCardN : function(cmp, e, hlpr) {
		hlpr.isValidateCardN(cmp);
	},
	validateZip : function(cmp, e, hlpr) {
		hlpr.cutNOTNumber(cmp, "zipcode");
	}
})