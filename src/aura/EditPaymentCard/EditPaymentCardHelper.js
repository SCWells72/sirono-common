({
	showError: function(cmp, message) {
		cmp.set('v.hasError', true);
		cmp.find('notificationCmp').showError(message);
	}, 
	showValidError: function(cmp, message) {
		var errMesscmp = cmp.find("cardValidError");
		var errMessage = errMesscmp.get("v.value");
		console.log('errMessage ' , errMessage);
		errMessage = !errMessage ? message : errMessage + '\n' + message;
		errMesscmp.set("v.value", errMessage);
	},
	isValidateExpDate : function(cmp) {
		var monthcmp = cmp.find("month");
		var monthValue = monthcmp.get("v.value");
		var yearcmpValue = cmp.find("year").get("v.value");
		var expDate = new Date(yearcmpValue, monthValue);
		var hasError = expDate < Date.now();

		if (hasError) {
			monthcmp.set("v.errors", [{message:"Expiration date must be in the future."}]);
		} else {
			monthcmp.set("v.errors", null);
		}
		return hasError;
	},
	isValidateCVV : function(cmp) {
		var cvvcmp = cmp.find("cvv");
		var cvvValue = cvvcmp.get("v.value");
		//console.log('cvvValue ', cvvValue);
		//console.log('cvvValue lenght', cvvValue.toString().length);
		var errMesscmp = cmp.find("cardValidError");
		var hasError = false;
		if (! cvvValue ) {
			errMesscmp.set("v.value", "CVV is a required field");
			hasError = true;
		} else if (cvvValue.toString().length < 3 || cvvValue.toString().length > 4) {
			//cvvcmp.set("v.errors", [{message:"CVV must be 4 digits for American Express and 3 digits for other card types."}]);
			errMesscmp.set("v.value", "CVV must be 4 digits for American Express and 3 digits for other card types.");
			hasError = true;
		} else {
			//monthcmp.set("v.errors", null);
			errMesscmp.set("v.value", '');
		}
		return hasError;
	},
	isValidateCardN: function(cmp) {
		// var errMesscmp = cmp.find("cardValidError");
		// if (! cnValue ) {
		// 	this.showValidError(cmp, "Card number is a required field.");
		// 	//errMesscmp.set("v.value", "Card number is a required field");
		// } else if (cnValue.toString().length < 12 || cnValue.toString().length > 19) {
		// 	//cvvcmp.set("v.errors", [{message:"CVV must be 4 digits for American Express and 3 digits for other card types."}]);
		// 	//errMesscmp.set("v.value", "Credit card number must be 12-19 digits.");
		// 	this.showValidError(cmp, "Credit card number must be 12-19 digits.");
		// } else {
		// 	//monthcmp.set("v.errors", null);
		// 	this.showValidError(cmp, "");
		//}
		var cncmp = cmp.find("cardNumber");
		var cnValue = cncmp.get("v.value");
		//console.log('cnValue ', cnValue);
		//console.log('cvvValue lenght', cvvValue.toString().length);
		var errMesscmp = cmp.find("cardValidError");
		// if (! cnValue ) {
		//     //this.showValidError(cmp, "Card number is a required field.");
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
		//     //this.showValidError(cmp, "Credit card number must be 12-19 digits.");
		// } else {
		//     errMesscmp.set("v.value", null);
		//     //this.showValidError(cmp, "");
		// }
	},
	// validateZip : function(cmp) {
	// 	var cvvcmp = cmp.find("cvv");
	// 	var cvvValue = cvvcmp.get("v.value");
	// 	//console.log('cvvValue ', cvvValue);
	// 	//console.log('cvvValue lenght', cvvValue.toString().length);
	// 	var errMesscmp = cmp.find("cardValidError");
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
	cutNOTNumber : function(cmp, idToVerify) {
		var cmp = cmp.find(idToVerify);
		var value = cmp.get("v.value");
		if (value && isNaN(value)) {
			value = value.toString().substring(0, value.toString().length - 1);
			cmp.set("v.value", value);
		} 
	}
})