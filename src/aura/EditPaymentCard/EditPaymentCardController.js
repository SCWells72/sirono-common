({
	doCmpInit: function(cmp, e, hlpr) {
		var credtCardSelections = cmp.get('c.getCardSelectOptions');
		credtCardSelections.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				console.log('getCardSelectOptions EDIT');
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
					months.sort(function(a, b) {
						var av = parseInt(a.value);
						var bv = parseInt(b.value);
						return av - bv;
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
		console.log('CreditCard', CreditCard, CreditCard.length);
		if(CreditCard.length == undefined || CreditCard.length == 0){
			CreditCard = hlpr.getDefaultCard(cmp);
			console.log('CreditCard Init:', CreditCard);
		}
		var curr_month = date.getMonth() + 1;
		
		cmp.set('v.CreditCard', CreditCard);
	},
	doDateValueInit: function(cmp, e, hlpr) {
		var executeOnDay = cmp.get('v.PaymentRequestInfo.executeOnDay') || 15;

		var date = new Date();
		if (executeOnDay <= date.getDate()) {
			date.setMonth(date.getMonth() + 1);
		}
		date.setDate(executeOnDay);

		var curr_date = date.getDate();
		var curr_month = date.getMonth() + 1;
		var curr_year = date.getFullYear();

		cmp.set('v.nextPaymentDate', (curr_month < 10 ? '0' + curr_month : curr_month) + '/' + (curr_date < 10 ? '0' + curr_date : curr_date) + '/' + curr_year);
	},
	cancelAction: function(cmp, e, hlpr) {
		cmp.getEvent('paymentMethodInit').fire();
	},
	saveNewCard: function(cmp, e, hlpr) {
		console.log('saveNewCard');
		//if(hlpr.isValidateExpDate(cmp) && hlpr.isValidCutNOTNumber(cmp, "cvv") && hlpr.isValidateCVV(cmp) && hlpr.isValidateCardN(cmp) && hlpr.isValidCutNOTNumber(cmp, "zipcode")){
			cmp.set('v.hasError', false);
			var PaymentRequestInfo = cmp.get('v.PaymentRequestInfo');
			var CreditCard = cmp.get('v.CreditCard');
			console.log('Credit Card:', CreditCard);
			PaymentRequestInfo.creditCard = CreditCard;
			//console.info('Update Payment Plan: info', JSON.parse(JSON.stringify(PaymentRequestInfo)));

			var createPlan = cmp.get('c.doEditPaymentMethod');
			createPlan.setParams({
				'paymentInfoStr': JSON.stringify( PaymentRequestInfo )
			});
			createPlan.setCallback(this, function(response) {
				if (response.getState() === 'SUCCESS') {
					var plan = response.getReturnValue();
					cmp.getEvent('paymentMethodInit').fire();
					cmp.getEvent('updatePaymentMethod').setParams({
						paymentPlan: plan
					}).fire();
					return;
				}

				var errors = response.getError();
				if (errors) {
					hlpr.showError(cmp, errors? errors[0].message : 'Error has been occurred');
				}
			});
			$A.enqueueAction(createPlan);
		//}
	},
	setupPlan: function(cmp, e, hlpr) {
		try {
		//if (!hlpr.isValidateExpDate(cmp) || !hlpr.isValidCutNOTNumber(cmp, "cvv") || !hlpr.isValidCutNOTNumber(cmp, "zipcode") || !hlpr.isValidateCardN(cmp) || !hlpr.isValidateCVV(cmp)) {
		//	hlpr.showError(cmp, 'Please fill in all required fields');
		//	return;
		//}
		console.log('Is Valid');
		cmp.set('v.hasError', false);
		var PaymentRequestInfo = cmp.get('v.PaymentRequestInfo');
		var CreditCard = cmp.get('v.CreditCard');
		PaymentRequestInfo.creditCard = CreditCard;

		var createPlan = cmp.get('c.createPaymentPlan');
		createPlan.setParams({
			'paymentInfoStr': JSON.stringify( PaymentRequestInfo )
		});
		createPlan.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				var plan = response.getReturnValue();
				console.log(plan)
				var appEvent = $A.get("e.c:switchTab");
				appEvent.setParams({ "tabName" : 'CreatePaymentPlan'});
				appEvent.fire();
				setTimeout(function() { 
					cmp.getEvent('paymentPlanCreated').setParams({
					paymentPlan: plan }).fire(); 
				}, 2500);

				

				return;
			}

			var errors = response.getError();
			console.log('errors', errors);
			if (errors) {
				hlpr.showError(cmp, errors? errors[0].message : 'Error has been occurred');
			}
		});
		$A.enqueueAction(createPlan);
	} catch (e) {console.log(e)}
	},
	validateExpDate : function(cmp, e, hlpr) {
		hlpr.isValidateExpDate(cmp);
	},
	validateCVV : function(cmp, e, hlpr) {
		hlpr.isValidCutNOTNumber(cmp, "cvv");
		hlpr.isValidateCVV(cmp);
	},
	validateCardN : function(cmp, e, hlpr) {
		hlpr.isValidateCardN(cmp);
	},
	validateZip : function(cmp, e, hlpr) {
		hlpr.isValidCutNOTNumber(cmp, "zipcode");
	},
	bindChangeSave: function(cmp, e, hlpr) {
		var CreditCard = cmp.get('v.CreditCard') || {};
		CreditCard.isSaved = !CreditCard.isSaved;
		cmp.set('v.CreditCard', CreditCard);
	}
})