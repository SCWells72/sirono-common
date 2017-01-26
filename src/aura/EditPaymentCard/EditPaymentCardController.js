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
	},
	cancelAction: function (cmp, e, hlpr) {
		cmp.getEvent('paymentMethodInit').fire();
	},
	submitInfo: function(cmp, e, hlpr) {
		cmp.set('v.hasError', false);
		var PaymentRequestInfo = cmp.get('v.PaymentRequestInfo');
		console.info('save Payment Plan', PaymentRequestInfo);

		// PaymentRequestInfo.creditCard.cardholderName = 'Testing Tester';
		// PaymentRequestInfo.creditCard.expirationYear = '2022';
		// PaymentRequestInfo.creditCard.expirationMonth = '11';
		// PaymentRequestInfo.creditCard.creditCardNumber = '4111111111111111';
		// PaymentRequestInfo.creditCard.cvv = '123';
		// PaymentRequestInfo.creditCard.city = 'Alabamna';
		// PaymentRequestInfo.creditCard.state = 'AL';
		// PaymentRequestInfo.creditCard.zip = '12345';
		// PaymentRequestInfo.creditCard.address = 'Testing Str #123';

		hlpr.validateExpDate(cmp);
		hlpr.validateCVV(cmp);
		hlpr.validateCardN(cmp);

		var createPlan = cmp.get('c.createPaymentPlan');
		createPlan.setParams({
			'paymentInfoStr': JSON.stringify( PaymentRequestInfo )
		});
		createPlan.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				var response = response.getReturnValue();
				console.log(response);
				//@TODO
				return;
			}

			var errors = response.getError();
			if (errors) {
				hlpr.showError(cmp, errors? errors[0].message : 'Error has been occurred');
			}
		});
		$A.enqueueAction(createPlan);
	},
	validateExpDate : function(cmp, e, hlpr) {
		hlpr.validateExpDate(cmp);
	},
	validateCVV : function(cmp, e, hlpr) {
		//hlpr.validateCVV(cmp);
		hlpr.cutNOTNumber(cmp, "cvv");
	},
	validateCardN : function(cmp, e, hlpr) {
		hlpr.validateCardN(cmp);
	},
	validateZip : function(cmp, e, hlpr) {
		hlpr.cutNOTNumber(cmp, "zipcode");
	}
})