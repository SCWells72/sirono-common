({
	getDefaultCard: function(cmp) {
		var date = new Date();
		date.setMonth(date.getMonth() + 1);
		return {
			isSaved: false,
			expirationMonth: date.getMonth() + 1,
			expirationYear: date.getFullYear()
		};
	},
	showError: function(cmp, message) {
		cmp.set('v.hasError', true);
		cmp.find('notificationCmp').showError(message);
	}
})