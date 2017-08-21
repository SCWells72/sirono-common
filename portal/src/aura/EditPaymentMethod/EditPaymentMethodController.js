/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    doCmpInit: function (cmp, e, hlpr) {
        var PaymentInfo = cmp.get('v.PaymentInfo');

        var cardId = cmp.get('v.PaymentInfo.paymentPlan.sPRS__Payment_Method__c');
        var CreditCard = hlpr.getDefaultCard();
        if (PaymentInfo && PaymentInfo.creditCards.length) {
            PaymentInfo.creditCards.forEach(function (card) {
                if (card.sfId === cardId) {
                    cmp.set('v.hasCreditCard', true);
                }
            });
        } else {
            // If no payment methods were found display the create view.
          $A.util.toggleClass(cmp.find('editPaymentMethod'), 'slds-hide');
          $A.util.toggleClass(cmp.find('editCreditCard'), 'slds-hide');
        }

        cmp.set('v.selectedCardId', cardId);
        cmp.set('v.CreditCard', CreditCard);
    },

    initCardSelectOptions: function (cmp, e, hlpr) {
        var PaymentInfo = cmp.get('v.PaymentInfo'),
            cardSelection = cmp.find('state'),
            selectedCardId = PaymentInfo.paymentPlan.sPRS__Payment_Method__c;

        if (cardSelection !== undefined) {
            cardSelection.set('v.body', []);
            var body = cardSelection.get('v.body');
            PaymentInfo.creditCards.forEach(function (card) {

                var selected = false;
                // if the current card is matches the selectedCardId make the option selected.
                if (selectedCardId && card && (selectedCardId === card.sfId)) {
                    selected = true;
                }

                $A.createComponent(
                    'aura:html',
                    {
                        tag: 'option',
                        HTMLAttributes: {
                            value: card.sfId,
                            text: card.displayName,
                            selected: selected
                        }
                    },
                    function (newOption) {
                        if (cmp.isValid()) {
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

    /**
     * Edit an existing credit card.
     */
    editCreditCard: function (cmp, e, hlpr) {
        e.stopPropagation();
        //Temporary solution
        cmp.set('v.CreditCard', hlpr.getDefaultCard());
        $A.util.toggleClass(cmp.find('editPaymentMethod'), 'slds-hide');
        $A.util.toggleClass(cmp.find('editCreditCard'), 'slds-hide');
        return false;
    },

    /**
     * Create a new credit card.
     */
    addNewCreditCard: function (cmp, e, hlpr) {
        e.stopPropagation();

        cmp.set('v.CreditCard', hlpr.getDefaultCard());

        $A.util.toggleClass(cmp.find('editPaymentMethod'), 'slds-hide');
        $A.util.toggleClass(cmp.find('editCreditCard'), 'slds-hide');
        return false;
    },
    cancelEditCardAction: function (cmp, e, hlpr) {
        e.stopPropagation();

        $A.util.toggleClass(cmp.find('editPaymentMethod'), 'slds-hide');
        $A.util.toggleClass(cmp.find('editCreditCard'), 'slds-hide');
    },

    /**
     * Update the payment method.
     */
    updatePaymentMethod: function (cmp, e, hlpr) {
        var paymentPlanService = cmp.find('paymentPlanService'),
            PaymentInfo = cmp.get('v.PaymentInfo'),
            PaymentRequestInfo = cmp.get('v.PaymentRequestInfo'),
            selectedCardId = cmp.get('v.selectedCardId'),
            CreditCard;

        // Iterate over the credit cards and get a reference to one the one selected in the select element.
        PaymentInfo.creditCards.forEach(function(card) {
            if (card && card.sfId == selectedCardId) {
                CreditCard = card;
            }
        });
        cmp.set('v.hasError', false);

        paymentPlanService.getPaymentPlanInfoMap(PaymentRequestInfo, CreditCard, function (planInfo) {

            var doEditPaymentMethod = cmp.get('c.doEditPaymentMethod');
            doEditPaymentMethod.setParams({
                'ppInfoMap': planInfo
            });
            doEditPaymentMethod.setCallback(this, function (response) {
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
                    hlpr.showError(cmp, errors ? errors[0].message : 'Error has occurred');
                }
            });
            $A.enqueueAction(doEditPaymentMethod);

        });

    }
})