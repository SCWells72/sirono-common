({
	doCmpInit: function(cmp, e, hlpr) {
		var PaymentInfo = cmp.get('v.PaymentInfo');
		var cardId = cmp.get('v.PaymentInfo.paymentPlan.Payment_Method__c');
		var CreditCard = hlpr.getDefaultCard();

		if (PaymentInfo && PaymentInfo.creditCards.length) {
			PaymentInfo.creditCards.forEach(function(card) {
				if (card.sfId === cardId) {
					CreditCard = card;
				}
			});
		}

		cmp.set('v.selectedCardId', cardId);
		cmp.set('v.CreditCard', CreditCard);
	},
	cancelAction: function (cmp, e, hlpr) {
		cmp.getEvent('initPlanInfo').fire();
	},
	changeCard: function(cmp, e, hlpr) {
		var cardId = cmp.get('v.selectedCardId');
		var PaymentInfo = cmp.get('v.PaymentInfo');
		var CreditCard = {};
		if (PaymentInfo && PaymentInfo.creditCards.length) {
			PaymentInfo.creditCards.forEach(function(card) {
				CreditCard = card;
				if (card.sfId === cardId) {
					CreditCard = card;
				}
			});
		}
		cmp.set('v.CreditCard', CreditCard);
	},
	editCreditCard: function(cmp, e, hlpr) {
		e.stopPropagation();

		$A.util.toggleClass(cmp.find('editPaymentMethod'), 'slds-hide');
		$A.util.toggleClass(cmp.find('editCreditCard'), 'slds-hide');
		return false;
	},
	addNewCreditCard: function(cmp, e, hlpr) {
		e.stopPropagation();

		cmp.set('v.CreditCard', hlpr.getDefaultCard());

		$A.util.toggleClass(cmp.find('editPaymentMethod'), 'slds-hide');
		$A.util.toggleClass(cmp.find('editCreditCard'), 'slds-hide');
		return false;
	},
	cancelEditCardAction: function(cmp, e, hlpr) {
		e.stopPropagation();

		$A.util.toggleClass(cmp.find('editPaymentMethod'), 'slds-hide');
		$A.util.toggleClass(cmp.find('editCreditCard'), 'slds-hide');
	},
	updatePaymentMethod: function(cmp, e, hlpr) {
		cmp.set('v.hasError', false);
		var PaymentRequestInfo = cmp.get('v.PaymentRequestInfo');
		var CreditCard = cmp.get('v.CreditCard');
		PaymentRequestInfo.creditCard = CreditCard;
		console.info('Update Payment Plan: info', JSON.parse(JSON.stringify(PaymentRequestInfo)));

		var createPlan = cmp.get('c.doEditPaymentMethod');
		createPlan.setParams({
			'paymentInfoStr': JSON.stringify( PaymentRequestInfo )
		});
		createPlan.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				var plan = response.getReturnValue();
				console.log('responseresponse: ' , plan);
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
	}
})