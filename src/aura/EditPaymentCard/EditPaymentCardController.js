/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    doCmpInit: function (cmp, e, hlpr) {
        var credtCardSelections = cmp.get('c.getCardSelectOptions');
        credtCardSelections.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                var selections = response.getReturnValue();
                var months = [];
                var years = [];

                for (var val in selections.YEARS) {
                    years.push(val);
                }
                for (var val1 in selections.MONTHS) {
                    months.push({
                        value: val1,
                        label: selections.MONTHS[val1]
                    });
                    months.sort(function (a, b) {
                        var av = parseInt(a.value, 10);
                        var bv = parseInt(b.value, 10);
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
        if (CreditCard.length === undefined || CreditCard.length === 0) {
            CreditCard = hlpr.getDefaultCard(cmp);
        }
        var curr_month = date.getMonth() + 1;

        cmp.set('v.CreditCard', CreditCard);
    },

    doDateValueInit: function (cmp, e, hlpr) {
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

    cancelAction: function (cmp, e, hlpr) {
        cmp.getEvent('paymentMethodInit').fire();
    },

    /**
     * Save a new credit card.
     */
    saveNewCard: function (cmp, e, hlpr) {
        try {
            var paymentPlanService = cmp.find('paymentPlanService'),
                paymentRequestInfo = cmp.get('v.PaymentRequestInfo'),
                creditCard = cmp.get('v.CreditCard');

            cmp.set('v.hasError', false);

            paymentPlanService.getPaymentPlanInfoMap(paymentRequestInfo, creditCard, function (planInfo) {

                var editPaymentMethod = cmp.get('c.doEditPaymentMethod');
                editPaymentMethod.setParams({
                    'ppInfoMap': planInfo,
                    'isCreditCardSaved': creditCard.isSaved
                });

                editPaymentMethod.setCallback(this, function (response) {
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
                        hlpr.showError(cmp, errors ? errors[0].message : 'Error has occurred');
                    }
                });
                $A.enqueueAction(editPaymentMethod);

            });

        } catch (err) {
            hlpr.showError(cmp, err.message);
        }
    },

    /**
     * Setup a new payment plan.  Will fire the paymentPlanCreated event when successful.
     */
    setupPlan: function (cmp, e, hlpr) {
        try {
            var creditCard = cmp.get('v.CreditCard'),
                paymentRequestInfo = cmp.get('v.PaymentRequestInfo'),
                createPlan = cmp.get('c.createPaymentPlan'),
                paymentPlanService = cmp.find('paymentPlanService');

            cmp.set('v.hasError', false);

            paymentPlanService.getPaymentPlanInfoMap(paymentRequestInfo, creditCard, function (planInfo) {
                createPlan.setParams({
                    'ppInfoMap': planInfo,
                    'isCreditCardSaved': creditCard.isSaved
                });
                createPlan.setCallback(this, function (response) {
                    if (response.getState() === 'SUCCESS') {
                        var plan = response.getReturnValue();
                        var appEvent = $A.get("e.c:switchTab");
                        appEvent.setParams({"tabName": 'CreatePaymentPlan'});
                        appEvent.fire();
                        setTimeout(function () {
                            cmp.getEvent('paymentPlanCreated').setParams({
                                paymentPlan: plan
                            }).fire();
                        }, 2500);

                        return;
                    }

                    var errors = response.getError();
                    if (errors) {
                        hlpr.showError(cmp, errors ? errors[0].message : 'Error has occurred');
                    }
                });
                $A.enqueueAction(createPlan);
            });

        } catch (err) {
            hlpr.showError(cmp, err.message);
        }
    },

    validateExpDate: function (cmp, e, hlpr) {
        hlpr.isValidateExpDate(cmp);
    },
    validateCVV: function (cmp, e, hlpr) {
        hlpr.isValidCutNOTNumber(cmp, "cvv");
        hlpr.isValidateCVV(cmp);
    },
    validateCardN: function (cmp, e, hlpr) {
        hlpr.isValidateCardN(cmp);
    },
    validateZip: function (cmp, e, hlpr) {
        hlpr.isValidCutNOTNumber(cmp, "zipcode");
    },
    bindChangeSave: function (cmp, e, hlpr) {
        var CreditCard = cmp.get('v.CreditCard') || {};
        CreditCard.isSaved = !CreditCard.isSaved;
        cmp.set('v.CreditCard', CreditCard);
    }
})