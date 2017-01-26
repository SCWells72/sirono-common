({
	getDocuments : function(component) {
		var action = component.get("c.getDocumentsInOrder");
        action.setCallback(this, function(response) {
        	var state = response.getState();
	    	if (state === 'SUCCESS') {
	    		var docs = response.getReturnValue();
	    		var existPdfFlag = false;
	    		for(var i = 0; i < docs.length; i++) {
	    			if (docs[i].ContentType == 'application/pdf') {
	    				existPdfFlag = true;
	    				break;
	    			}
	    		}
	            component.set('v.documents', docs);
	            component.set('v.existPdfFlag', existPdfFlag);
	    	}
        });
        $A.enqueueAction(action);
	},

	updateSorting : function(component, orderCriteria, orderType) {
		var action = component.get("c.getDocumentsInOrder");
		console.log('help', orderCriteria, orderType);
		action.setParams({
            criteria: orderCriteria,
            orderType: orderType,
        });
        action.setCallback(this, function(response) {
        	var state = response.getState();
        	console.log('resp', state, response.getReturnValue());
	    	if (state === 'SUCCESS') {
	    		var docs = response.getReturnValue();
	            component.set('v.documents', docs);
	    	}
        });
        $A.enqueueAction(action);
	}
})