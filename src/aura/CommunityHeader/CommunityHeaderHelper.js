({
	getUserInfo : function(component) {
		var action = component.get("c.getUserInfo");
        action.setCallback(this, function(response) {
        	var state = response.getState();
	    	if (state === 'SUCCESS') {
	    		var user = response.getReturnValue();
	            component.set('v.userInfo', user);
	    	}
        });
        $A.enqueueAction(action);
	}
})