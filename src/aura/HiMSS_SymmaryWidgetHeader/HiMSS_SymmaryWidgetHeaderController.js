/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    processEvent : function(component, event, helper) {
    	var eventType = event.getParam('type');
    	console.log('::::eventType::::' + eventType);
    	if (eventType == 'post') {
    		component.set('v.guarantorWrapperTimer', event.getParam('guarantorWrapperTimer'));
    		component.set('v.guarantorWrapperListCounter', event.getParam('guarantorWrapperListCounter'));
    		component.set('v.isLogin', event.getParam('isLogin'));
    	} else if (eventType == 'get') {
    		var appEvent = $A.get("e.c:HiMSS_SummaryWidgetRotateEvent");
	        appEvent.setParams({ 
	        	'type': 'retrieve', 
	        	'guarantorWrapperTimer': component.get('v.guarantorWrapperTimer'),
	        	'guarantorWrapperListCounter' : component.get('v.guarantorWrapperListCounter'),
	        	'isLogin' : component.get('v.isLogin')
	    	});
	        appEvent.fire();
    	} else if (eventType == 'login') {
    		component.set('v.isLogin', true);
    	}
    }
})