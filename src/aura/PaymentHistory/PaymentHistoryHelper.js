({
	getPayments : function(component) {
		var action = component.get("c.getPaymentHistory");
        action.setCallback(this, function(response) {
        	var state = response.getState();
	    	if (state === 'SUCCESS') {
	    		var payments = response.getReturnValue();
	    		console.log('payments', payments);
	            component.set('v.payments', payments);
	    	}
        });
        $A.enqueueAction(action);
	}
})