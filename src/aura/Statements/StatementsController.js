/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
	showPopoverRight : function(component, event, helper) {
		var myPopoverRight = component.find('sldsjsPopoverRight');
		$A.util.toggleClass(myPopoverRight, 'slds-hide');         
	},

	doInit : function(component, event, helper) {
		helper.getStatements(component);
	},
    

})