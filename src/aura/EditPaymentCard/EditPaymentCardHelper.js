({
	showError: function(cmp, message) {
		cmp.set('v.hasError', true);
		cmp.find('notificationCmp').showError(message);
	}, 
	showValidError: function(cmp, message) {
		var errMesscmp = component.find("cardValidError");
		var errMessage = errMesscmp.get("v.value");
		console.log('errMessage ' , errMessage);
		errMessage = !errMessage ? message : errMessage + '\n' + message;
		errMesscmp.set("v.value", errMessage);
	},
	validateExpDate : function(component) {
		var monthcmp = component.find("month");
		var monthValue = monthcmp.get("v.value");
		var yearcmpValue = component.find("year").get("v.value");
		var expDate = new Date(yearcmpValue, monthValue);
		
		if (expDate < Date.now()) {
			monthcmp.set("v.errors", [{message:"Expiration date must be in the future."}]);
		} else {
			monthcmp.set("v.errors", null);
		}
	},
	validateCVV : function(component) {
		var cvvcmp = component.find("cvv");
		var cvvValue = cvvcmp.get("v.value");
		//console.log('cvvValue ', cvvValue);
		//console.log('cvvValue lenght', cvvValue.toString().length);
		var errMesscmp = component.find("cardValidError");
		if (! cvvValue ) {
			errMesscmp.set("v.value", "CVV is a required field");
		} else if (cvvValue.toString().length < 3 || cvvValue.toString().length > 4) {
			//cvvcmp.set("v.errors", [{message:"CVV must be 4 digits for American Express and 3 digits for other card types."}]);
			errMesscmp.set("v.value", "CVV must be 4 digits for American Express and 3 digits for other card types.");
		} else {
			//monthcmp.set("v.errors", null);
			errMesscmp.set("v.value", '');
		}
	},
	validateCardN : function(component) {
		// var errMesscmp = component.find("cardValidError");
		// if (! cnValue ) {
		// 	this.showValidError(component, "Card number is a required field.");
		// 	//errMesscmp.set("v.value", "Card number is a required field");
		// } else if (cnValue.toString().length < 12 || cnValue.toString().length > 19) {
		// 	//cvvcmp.set("v.errors", [{message:"CVV must be 4 digits for American Express and 3 digits for other card types."}]);
		// 	//errMesscmp.set("v.value", "Credit card number must be 12-19 digits.");
		// 	this.showValidError(component, "Credit card number must be 12-19 digits.");
		// } else {
		// 	//monthcmp.set("v.errors", null);
		// 	this.showValidError(component, "");
		//}
		var cncmp = component.find("cardNumber");
        var cnValue = cncmp.get("v.value");
        //console.log('cnValue ', cnValue);
        //console.log('cvvValue lenght', cvvValue.toString().length);
        var errMesscmp = component.find("cardValidError");
        // if (! cnValue ) {
        //     //this.showValidError(component, "Card number is a required field.");
        //     errMesscmp.set("v.value", "Card number is a required field");
        // } else
        if (cnValue && isNaN(cnValue)) {
            cnValue = cnValue.toString().substring(0, cnValue.toString().length - 1);
            console.log('cnValue --- > ', cnValue);
            cncmp.set("v.value", cnValue);
        } 
        // else if (cnValue.toString().length < 12 || cnValue.toString().length > 19) {
        //     //cncmp.set("v.errors", [{message:"CVV must be 4 digits for American Express and 3 digits for other card types."}]);
        //     errMesscmp.set("v.value", "Credit card number must be 12-19 digits.");
        //     if (cnValue.toString().length > 19) {
        //         cnValue = cnValue.toString().substring(0, 19);
        //         console.log('cnValue --- > ', cnValue);
        //         cncmp.set("v.value", cnValue);
        //     }
        //     //this.showValidError(component, "Credit card number must be 12-19 digits.");
        // } else {
        //     errMesscmp.set("v.value", null);
        //     //this.showValidError(component, "");
        // }
	},
	// validateZip : function(component) {
	// 	var cvvcmp = component.find("cvv");
	// 	var cvvValue = cvvcmp.get("v.value");
	// 	//console.log('cvvValue ', cvvValue);
	// 	//console.log('cvvValue lenght', cvvValue.toString().length);
	// 	var errMesscmp = component.find("cardValidError");
	// 	if (! cvvValue ) {
	// 		errMesscmp.set("v.value", "CVV is a required field");
	// 	} else if (cvvValue.toString().length < 3 || cvvValue.toString().length > 4) {
	// 		//cvvcmp.set("v.errors", [{message:"CVV must be 4 digits for American Express and 3 digits for other card types."}]);
	// 		errMesscmp.set("v.value", "CVV must be 4 digits for American Express and 3 digits for other card types.");
	// 	} else {
	// 		//monthcmp.set("v.errors", null);
	// 		errMesscmp.set("v.value", '');
	// 	}
	// }
	cutNOTNumber : function(component, idToVerify) {
		var cmp = component.find(idToVerify);
        var value = cmp.get("v.value");
        if (value && isNaN(value)) {
            value = value.toString().substring(0, value.toString().length - 1);
            cmp.set("v.value", value);
        } 
	}
})