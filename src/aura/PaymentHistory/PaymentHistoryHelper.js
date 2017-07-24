/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
	getPayments : function(component) {
		var action = component.get("c.getPaymentHistory");
        action.setCallback(this, function(response) {
        	var state = response.getState();
			console.log('state', state);
	    	if (state === 'SUCCESS') {
	    		var payments = response.getReturnValue();
				this.defaultSort(component, payments);
	    	}
        });
        $A.enqueueAction(action);
	},
	defaultSort : function(component, payments) {
		payments.sort(function(a, b) {
			  if(a['deposit'] == b['deposit'])
				return b['amount'] - a['amount'];
			  if(a['deposit'] >  b['deposit'])
				 return -1; 
			  if(a['deposit'] <  b['deposit'])
				 return 1; 
			  return 0;
		});
		component.set('v.payments', payments);
	},

	updateSorting : function(component, orderCriteria, orderType) {
		var payments = component.get('v.payments');
		payments.sort(function(a, b) {
			  if(a[orderCriteria] == b[orderCriteria])
				return 0;
			  if(a[orderCriteria] >  b[orderCriteria])
				 return -1; 
			  if(a[orderCriteria] <  b[orderCriteria])
				 return 1; 
			  return 0;
		});
		if(orderType == 'DESC') {
			payments.reverse();
		}
		component.set('v.payments', payments);
	}

})