({
	activateTab : function (component, event, helper) {
		var tabToActivate = event.target.id;
		var aciveTab = component.get("v.aciveTab");
		if (aciveTab != tabToActivate) {
			if (aciveTab) {
				$A.util.addClass(component.find(aciveTab), 'display_false');
				$A.util.removeClass(component.find(aciveTab+'_tab'), 'active');
			}
			$A.util.removeClass(component.find(tabToActivate), 'display_false');
			$A.util.addClass(component.find(tabToActivate+'_tab'), 'active');
			component.set("v.aciveTab",tabToActivate);
		}
	}
})