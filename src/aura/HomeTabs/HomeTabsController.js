/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
	doInit : function (component, event, helper) {
	
		if (window.location.href.includes('activeTab=')) {
			var aciveTab = component.get("v.aciveTab");
			var tabToActivate = window.location.href.split("=").pop();
			helper.activateTab(component, tabToActivate, aciveTab);
		}
	},

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