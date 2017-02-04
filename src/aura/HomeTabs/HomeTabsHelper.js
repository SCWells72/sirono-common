({
	activateTab: function (component, tabToActivate, aciveTab) {
		if (aciveTab != tabToActivate) {
			if (aciveTab) {
				$A.util.addClass(component.find(aciveTab).getElement(), 'display_false');
				$A.util.removeClass(component.find(aciveTab+'_tab').getElement(), 'slds-active');
			}
			$A.util.removeClass(component.find(tabToActivate).getElement(), 'display_false');
			$A.util.addClass(component.find(tabToActivate+'_tab').getElement(), 'slds-active');

			component.set("v.aciveTab",tabToActivate);
		}
	}
})