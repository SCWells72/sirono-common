({
	showError: function(cmp, message) {
		cmp.set('v.hasError', true);
		cmp.find('notificationCmp').showError(message);
		
	},
	toggleSections: function(cmp) {
		var cardCmp = cmp.find('editCreditCard');
		var termsCmp = cmp.find('editTerms');
		$A.util.toggleClass(termsCmp, 'slds-hide');
		$A.util.toggleClass(cardCmp, 'slds-hide');
	},
	getCalculatedMinInstallmentAmount: function(Settings, totalAmount) {
		var minimumInstallmentAmount = Settings.Min_Installment_Amount__c || 0;
		if (Settings.Max_Number_Plan_Installments__c && Settings.Max_Number_Plan_Installments__c > 0) {
			minimumInstallmentAmount = Math.ceil( totalAmount / Settings.Max_Number_Plan_Installments__c );
			minimumInstallmentAmount.toFixed(2);
			if(Settings.Min_Installment_Amount__c >= minimumInstallmentAmount){
				minimumInstallmentAmount = Settings.Min_Installment_Amount__c;
			}
		}
		return parseFloat(minimumInstallmentAmount, 10);
	},
	getCalculatedIntallments: function(total, part) {
		var _total = Math.round(total * 100) / 100;
		var _part = Math.round(part * 100) / 100;
		var totalInstallment = Math.round( _total / _part );
		totalInstallment = Math.round(totalInstallment * _part * 100) / 100 < Math.round(_total * 100) / 100 ? totalInstallment + 1: totalInstallment;
		return totalInstallment;
	},

	getDefaultCard: function(cmp) {
		var date = new Date();
		date.setMonth(date.getMonth() + 1);
		return {
			isSaved: false,
			expirationMonth: ("0" + (date.getMonth())).slice(-2),
			expirationYear: date.getFullYear(),
			cardHolderName:'',
			creditCardNumber: '',
			cvv: '',
			address: '',
			city: '',
			zip: '',
			state: ''
		};
	},
})