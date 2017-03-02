({
	showReceiptPopUp: function (component, event, helper) {
		var eventIndex = event.getParam('index');
		var index = component.get("v.index");
		if (eventIndex == index) {
			$A.util.removeClass(component.find("receiptPopUp"), "slds-hide");
		}
	},
	closePopup: function (component, event, helper) {
		var index = component.get("v.index");
		$A.util.addClass(component.find("receiptPopUp"), "slds-hide");
	}
})