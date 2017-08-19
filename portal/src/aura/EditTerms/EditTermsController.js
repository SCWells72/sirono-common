/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    doCmpInit: function (cmp, e, hlpr) {
        var PaymentInfo = cmp.get('v.PaymentInfo');
        var CreditCard = hlpr.getDefaultCard(cmp);
        if (PaymentInfo && PaymentInfo.creditCards.length) {
            PaymentInfo.creditCards.forEach(function (card) {
                CreditCard = card;
            });
        }

        cmp.set('v.CreditCard', CreditCard);

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
        selections.forEach(function (selection) {
            $A.createComponent(
                'aura:html',
                {
                    tag: 'option',
                    HTMLAttributes: {
                        value: selection,
                        text: selection
                    }
                },
                function (newOption) {
                    if (cmp.isValid()) {
                        body.push(newOption);
                        dayOfMonthSelection.set('v.body', body);
                    }
                })
        });

        cmp.set('v.hasError', false);
    },
    resetCmp: function (cmp, e, hlpr) {
        hlpr.toggleSections(cmp);
    },
    cancelAction: function (cmp, e, hlpr) {
        cmp.getEvent("initPlanInfo").fire();
        cmp.set('v.hasError', false);
        $A.get("e.c:editTermsAction").fire();
    },
    cancelEditCardAction: function (cmp, e, hlpr) {
        e.stopPropagation();
        hlpr.toggleSections(cmp);
    },

    /**
     * Update the current users payment plan terms.
     */
    updatePaymentTerms: function (cmp, e, hlpr) {
        var paymentPlanService = cmp.find('paymentPlanService'),
            paymentRequestInfo = cmp.get('v.PaymentRequestInfo');

        cmp.set('v.hasError', false);

        paymentPlanService.getPaymentPlanInfoMap(paymentRequestInfo, {}, function (planInfo) {

            var updateTermsAction = cmp.get('c.doEditPaymentPlan');
            updateTermsAction.setParams({
                ppInfoMap: planInfo
            });

            updateTermsAction.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    var plan = response.getReturnValue();
                    $A.get("e.c:UpdatePaymentTermsEvent").setParams({
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
            $A.enqueueAction(updateTermsAction);

        });

    },

    createPaymenTerms: function (cmp, e, hlpr) {
        hlpr.toggleSections(cmp);
    },

    doCalcView: function (cmp, e, hlpr) {
        var PaymentRequestInfo = cmp.get('v.PaymentRequestInfo');
        var PaymentInfo = cmp.get('v.PaymentInfo');
        var maxAmount = cmp.get('v.maxAmount');
        var newPlanValue = parseFloat(PaymentRequestInfo.planValue, 10);
        cmp.set('v.hasError', false);
        var minInstallmentAmount = hlpr.getCalculatedMinInstallmentAmount(PaymentInfo.settings, PaymentRequestInfo.totalAmount);

        if (newPlanValue > PaymentRequestInfo.totalAmount) {
            var message = "Monthly amount cannot exceed current payment plan balance";
            hlpr.showError(cmp, message);
        }
        //fix lightning bug(position the cursor in the left corner)
        if (maxAmount !== PaymentRequestInfo.totalAmount) {
            cmp.set('v.maxAmount', PaymentRequestInfo.totalAmount);
            cmp.set('v.minAmount', minInstallmentAmount);
            window.setTimeout(
                $A.getCallback(function () {
                    if (cmp.isValid()) {
                        cmp.set('v.sliderValue', Math.ceil(newPlanValue));
                    }
                }), 5
            );
        } else {
            cmp.set('v.sliderValue', Math.ceil(newPlanValue));
        }
    },

    recalculateTotalAmount: function (cmp, e, hlpr) {
        var balance = e.getParam('paymentBalance');
        var PaymentRequestInfo = cmp.get('v.PaymentRequestInfo');
        PaymentRequestInfo.totalAmount = balance;
    },

    changeSlider: function (cmp, e, hlpr) {
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
            var message;
            if (planValue < Settings.sPRS__Min_Installment_Amount__c) {
                message = 'Monthly amount must be equal to or greater than $' + Settings.sPRS__Min_Installment_Amount__c + '.';
                hlpr.showError(cmp, message);
                return false;
            }

            if (planValue >= Settings.sPRS__Min_Installment_Amount__c) {
                var totalInstallment = hlpr.getCalculatedIntallments(PaymentRequestInfo.totalAmount, planValue);

                if (totalInstallment > Settings.sPRS__Max_Number_Plan_Installments__c) {
                    var minimumInstallmentAmount = hlpr.getCalculatedMinInstallmentAmount(Settings, totalAmount);
                    message = 'This monthly amount would exceed ' + Settings.sPRS__Max_Number_Plan_Installments__c + ' installments.' +
                        ' The minimum allowed installment amount is $' + minimumInstallmentAmount.toFixed(2) + '.';
                    hlpr.showError(cmp, message);
                    return false;
                }
            }
            return true;
        };
    },
    showPopoverInfo: function (cmp, e, hlpr) {
        var myPopoverInfo = cmp.find('sldsjsPopoverInfo');
        $A.util.toggleClass(myPopoverInfo, 'slds-hide');
    }

})