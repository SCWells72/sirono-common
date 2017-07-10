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

	initCardSelectOptions: function(cmp, e, hlpr) {
		var PaymentInfo = cmp.get('v.PaymentInfo');
		var cardSelection = cmp.find('state');
		if(cardSelection !== undefined){
			cardSelection.set('v.body', []);
			var body = cardSelection.get('v.body');
			PaymentInfo.creditCards.forEach(function(card){
				$A.createComponent(
					'aura:html',
					{
						tag: 'option',
						HTMLAttributes: {
							value: card.sfId,
							text: card.displayName
						}
					},
					function(newOption){
						if(cmp.isValid()){
							body.push(newOption);
						}
					})
			});
			cardSelection.set('v.body', body);
		}
	},

	cancelAction: function (cmp, e, hlpr) {
		cmp.getEvent('initPlanInfo').fire();
	},
	editCreditCard: function(cmp, e, hlpr) {
		e.stopPropagation();
		//Temporary solution
		cmp.set('v.CreditCard', hlpr.getDefaultCard());
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

    /**
	 * Update the payment method.
     */
	updatePaymentMethod: function(cmp, e, hlpr) {
		var paymentPlanService = cmp.find('paymentPlanService'),
        	PaymentRequestInfo = cmp.get('v.PaymentRequestInfo'),
        	CreditCard = cmp.get('v.CreditCard');

        cmp.set('v.hasError', false);

		paymentPlanService.getPaymentPlanInfoMap(PaymentRequestInfo, CreditCard, function(planInfo) {

			var doEditPaymentMethod = cmp.get('c.doEditPaymentMethod');
            doEditPaymentMethod.setParams({
                'ppInfoMap': planInfo,
                'isCreditCardSaved': CreditCard.isSaved
            });
            doEditPaymentMethod.setCallback(this, function(response) {
                if (response.getState() === 'SUCCESS') {
                    var plan = response.getReturnValue();

                    cmp.getEvent('updatePaymentMethod').setParams({
                        paymentPlan: plan,
                        isEditTerms: true
                    }).fire();

                    return;
                }

                var errors = response.getError();
                if (errors) {
                    hlpr.showError(cmp, errors? errors[0].message : 'Error has occurred');
                }
            });
            $A.enqueueAction(doEditPaymentMethod);

        });

	}
})