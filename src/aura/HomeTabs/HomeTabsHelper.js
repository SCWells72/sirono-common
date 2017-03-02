({
	activateTab: function (component, tabToActivate, aciveTab) {
		if (aciveTab != tabToActivate) {
			if (aciveTab) {
				$A.util.addClass(component.find(aciveTab), 'display_false');
				$A.util.removeClass(component.find(aciveTab+'_tab'), 'slds-active');
			}
			$A.util.removeClass(component.find(tabToActivate), 'display_false');
			$A.util.addClass(component.find(tabToActivate+'_tab'), 'slds-active');

			component.set("v.aciveTab",tabToActivate);
		}
	}
})