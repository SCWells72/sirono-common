({
	showSettings : function(component, event, helper) {
		var mySettings = component.find('sldsjsPopoverAction');
		$A.util.toggleClass(mySettings, 'slds-hide');     
	},
	showHelp : function(component, event, helper) {
		var mySettings = component.find('sldsjsPopoverActionHelp'); 
		$A.util.toggleClass(mySettings, 'slds-hide');         
	},
	doInit : function(component, event, helper) {
		helper.getUserInfo(component);
	}
})