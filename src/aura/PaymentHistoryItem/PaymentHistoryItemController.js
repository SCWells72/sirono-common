/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
	printReceipt: function (component, event, helper) {
		var index = component.get("v.index");
		$A.get("e.c:showReceiptPopUp").setParams({"index": index}).fire();
	}
})