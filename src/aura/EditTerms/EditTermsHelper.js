({
	showError: function(cmp, message) {
		cmp.set('v.hasError', true);
		var supportCmp = cmp.find('notificationCmp');
		if (supportCmp) {
			supportCmp.showError(message);
		}
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
			minimumInstallmentAmount = parseFloat( totalAmount / Settings.Max_Number_Plan_Installments__c );
			minimumInstallmentAmount.toFixed(2)
		}
		return parseFloat(minimumInstallmentAmount, 10);
	},
	getCalculatedIntallments: function(total, part) {
		var _total = Math.round(total * 100) / 100;
		var _part = Math.round(part * 100) / 100;
		var totalInstallment = Math.round( _total / _part );
		totalInstallment = Math.round(totalInstallment * _part * 100) / 100 <= Math.round(_total * 100) / 100 ? totalInstallment : totalInstallment + 1;
		return totalInstallment;
	}
})