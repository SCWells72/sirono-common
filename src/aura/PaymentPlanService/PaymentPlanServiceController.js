/**
 * Controller methods for the PaymentPlanService.
 */
({
    /**
     * Convert a PaymentPlanRequest and CreditCard object into a PaymentPlan Info object.
     *
     * @return {Object} - An object that can be passed to an Apex controller and converted into a PaymentPlayInformation
     * object.
     */
    populatePaymentPlanInfo: function(component, evt) {
        var params = evt.getParam('arguments'),
            paymentPlanInfo = {},
            paymentInfo, creditCard, cb;

        if (!params.PaymentRequestInfo) {
            throw new Error('PaymentRequestInfo argument must be provided.');
        } else if (!params.CreditCard) {
            throw new Error('CreditCard argument must be provided.');
        }

        paymentInfo = params.PaymentRequestInfo;
        creditCard = params.CreditCard;
        cb = params.callback;

        paymentPlanInfo.planType = 'auto';
        paymentPlanInfo.planValue = '';
        paymentPlanInfo.amount = paymentInfo.planValue;
        paymentPlanInfo.executeOnDay = paymentInfo.executeOnDay;
        paymentPlanInfo.chargeGroupIds = paymentInfo.chargeGroupId;
        paymentPlanInfo.guarantorId = paymentInfo.sironoId;
        paymentPlanInfo.cardHolderName = creditCard.cardHolderName;
        paymentPlanInfo.expirationYear = creditCard.expirationYear;
        paymentPlanInfo.expirationMonth = creditCard.expirationMonth;
        paymentPlanInfo.creditCardNumber = creditCard.creditCardNumber;
        paymentPlanInfo.cvv = creditCard.cvv;
        paymentPlanInfo.state = creditCard.state;
        paymentPlanInfo.zip = creditCard.zip;
        paymentPlanInfo.address = creditCard.address;
        paymentPlanInfo.city = creditCard.city;

        // The following properties are optional and not used in all instances.  So only include them if they are found.
        if (creditCard.sfId) {
            paymentPlanInfo.creditCardId = creditCard.sfId;
        }

        if (paymentInfo.sfId) {
            paymentPlanInfo.id = paymentInfo.sfId;
        }

        if (paymentInfo.paymentPlanId) {
            paymentPlanInfo.sironoPaymentPlanId = paymentInfo.paymentPlanId;
        }

        cb(paymentPlanInfo);
    }
})