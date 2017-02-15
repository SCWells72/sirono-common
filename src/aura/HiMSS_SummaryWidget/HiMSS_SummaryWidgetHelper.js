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
	    		if (typeof(guarantorWrapper.contact) != "undefined") {
		            component.set('v.guarantorWrapper', guarantorWrapper);
		            component.set('v.invoiceValue', formatter.format(Math.floor(guarantorWrapper.contact.invoicedBalance)));
	        		component.set('v.invoiceValuePart', (guarantorWrapper.contact.invoicedBalance % 1).toFixed(2).toString().substring(2));
	        	}
	    	}
        });
        $A.enqueueAction(action);
	},

	goToMainPage : function(component, tabType) {
        $A.get("e.force:navigateToURL").setParams({
            'url' : '/?activeTab=' + tabType
        }).fire();
	}
})