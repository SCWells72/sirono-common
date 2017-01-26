({
	getPayments : function(component) {
		var action = component.get("c.getPaymentHistory");
        action.setCallback(this, function(response) {
        	var state = response.getState();
	    	if (state === 'SUCCESS') {
	    		var payments = response.getReturnValue();
	            component.set('v.payments', payments);
	    	}
        });
        $A.enqueueAction(action);
	},
	updateSorting : function(component, orderCriteria, orderType) {
		var action = component.get("c.getPaymentHistory");
		action.setParams({
            criteria: orderCriteria,
            orderType: orderType,
        });
        action.setCallback(this, function(response) {
        	var state = response.getState();
	    	if (state === 'SUCCESS') {
	    		var payments = response.getReturnValue();
	            component.set('v.payments', payments);
	    	}
        });
        $A.enqueueAction(action);
	}
})