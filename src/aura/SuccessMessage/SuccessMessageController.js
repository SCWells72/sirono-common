({
	returnToAccountSummary: function (component, event, helper) {
		$A.get("e.force:navigateToURL").setParams({
			'url' : '/',
			'isredirect' : true 
		}).fire();
	}
})