({	
	eventActivateTab : function (component, event, helper) {
		var tabToActivate = event.getParam('activeTab');
		var aciveTab = component.get("v.aciveTab");
		helper.activateTab(component, tabToActivate, aciveTab);
	},

	activateTab : function (component, event, helper) {
		var tabToActivate = event.target.id;
		var aciveTab = component.get("v.aciveTab");
		helper.activateTab(component, tabToActivate, aciveTab);
	},
})