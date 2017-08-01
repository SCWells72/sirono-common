/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    getDefaultCard: function (cmp) {
        var date = new Date(),
            monthStr;

        monthStr = (date.getMonth() + 1) + '';
        if (monthStr.length === 1) {
            monthStr = '0' + monthStr;
        }

        return {
            isSaved: true,
            expirationMonth: monthStr,
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