({
	getAllHeaderInfo : function(component) {
		var action = component.get("c.getAllHeaderInfo");
		var formatter = new Intl.NumberFormat('en-US', {
		  style: 'currency',
		  currency: 'USD',
		  minimumFractionDigits: 0,
		});
        action.setCallback(this, function(response) {
        	var state = response.getState();
	    	if (state === 'SUCCESS') {
	    		var guarantorWrapper = response.getReturnValue();
	            component.set('v.guarantorWrapper', guarantorWrapper);
	            component.set('v.invoiceValue', formatter.format(Math.floor(guarantorWrapper.paymentPlan.Installment_Amount__c)));
        		component.set('v.invoiceValuePart', (guarantorWrapper.paymentPlan.Installment_Amount__c % 1).toFixed(2).toString().substring(2));
				var isWarning = guarantorWrapper.contact.Guarantor_Status__c == 'Overdue' || (guarantorWrapper.paymentPlan.Active__c && guarantorWrapper.paymentPlan.Plan_Type__c == 'Automatic' && guarantorWrapper.paymentPlan.Payment_Plan_Standing__c == 'In Error');
        		component.set('v.warningMessage', isWarning);
				var isError = guarantorWrapper.contact.Guarantor_Status__c == 'Delinquent' || (guarantorWrapper.paymentPlan.Active__c && guarantorWrapper.paymentPlan.Payment_Plan_Standing__c == 'Past Due');
        		component.set('v.errorMessage', isError);
  
	    	}
        });
        $A.enqueueAction(action);
	}
})