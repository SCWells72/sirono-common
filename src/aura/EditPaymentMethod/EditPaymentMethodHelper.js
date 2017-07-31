/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    getDefaultCard: function (cmp) {
        var date = new Date();
        // Set the date for a year from now as the expiration year must be in the future.
        date.setMonth(date.getMonth() + 13);
        return {
            isSaved: false,
            expirationMonth: '01',
            expirationYear: date.getFullYear(),
            cardHolderName: '',
            creditCardNumber: '',
            cvv: '',
            address: '',
            city: '',
            zip: '',
            state: ''
        };
    },
    showError: function (cmp, message) {
        cmp.set('v.hasError', true);
        cmp.find('notificationCmp').showError(message);
    }
})