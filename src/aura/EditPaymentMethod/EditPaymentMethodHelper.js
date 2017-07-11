({
    getDefaultCard: function (cmp) {
        var date = new Date();
        date.setMonth(date.getMonth() + 1);
        return {
            isSaved: false,
            expirationMonth: '02',
            expirationYear: date.getFullYear(),
            cardHolderName: 'Charles Green',
            creditCardNumber: '4111111111111111',
            cvv: '123',
            address: '1221 Congress Ave',
            city: 'Austin',
            zip: '78701',
            state: 'TX'
        };
    },
    showError: function (cmp, message) {
        cmp.set('v.hasError', true);
        cmp.find('notificationCmp').showError(message);
    }
})