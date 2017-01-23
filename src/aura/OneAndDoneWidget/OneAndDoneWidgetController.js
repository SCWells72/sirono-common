({
	changePage : function(component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({
			'url' : '/payments' 
		}).fire();
	}
})