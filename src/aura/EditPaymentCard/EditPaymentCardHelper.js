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
	isAllFieldsValid: function(cmp) {
		var allValid = cmp.find('field').reduce(function(validSoFar, inputCmp) {
			//inputCmp.showHelpMessageIfInvalid();
			return !validSoFar || !inputCmp.get('v.validity') || !inputCmp.get('v.validity').valid;
		}, true);
		return allValid;
	},
	isValidateExpDate : function(cmp) {
		var monthcmp = cmp.find("month");
		var monthValue = monthcmp.get("v.value");
		var yearcmpValue = cmp.find("year").get("v.value");
		var expDate = new Date(yearcmpValue, monthValue);
		var isValid = expDate > Date.now();

		if (isValid) {
			monthcmp.set("v.errors", [{message:"Expiration date must be in the future."}]);
		} else {
			monthcmp.set("v.errors", null);
		}
		return isValid;
	},
	isValidateCVV : function(cmp) {
		var cncmp = cmp.find("cardNumber");
		var cnValue = cncmp.get("v.value") || '';
		var cvvcmp = cmp.find("cvv");
		var cvvValue = cvvcmp.get("v.value") || '';
		var errMesscmp = cmp.find("cardValidError");
		// console.log('cvvValue ', cvvValue);
		// console.log('valid ', cncmp.get('v.validity').valid);
		var isValid = false;
		if (! cvvValue ) {
			errMesscmp.set("v.value", '');
			return isValid;
		}
		if ((cncmp.get('v.validity') == null || cncmp.get('v.validity').valid) && cnValue) {
			var cardno = /^(?:3[47][0-9]{13})$/;
			//console.log("match = ", cnValue.match(cardno));
			if (cnValue.match(cardno)) {
				if (cvvValue.toString().length != 4) {
					errMesscmp.set("v.value", "CVV must be 4 digits for American Express and 3 digits for other card types.");
				} else {
					isValid = true;
					errMesscmp.set("v.value", '');
				}
			} else {
				if (cvvValue.toString().length != 3) {
					errMesscmp.set("v.value", "CVV must be 4 digits for American Express and 3 digits for other card types.");
				} else {
					isValid = true;
					errMesscmp.set("v.value", '');
				}
			}

		} else {
			//console.log("Please fill in card number");
			//set error "please fill card number"
			errMesscmp.set("v.value", "Please fill in card number");
			//errMesscmp.set("v.value", '');
		}
		/*var cvvcmp = cmp.find("cvv");
		var cvvValue = cvvcmp.get("v.value");
		//console.log('cvvValue ', cvvValue);
		//console.log('cvvValue lenght', cvvValue.toString().length);
		var errMesscmp = cmp.find("cardValidError");
		if (! cvvValue ) {
			errMesscmp.set("v.value", "CVV is a required field");
			isValid = true;
		} else if (cvvValue.toString().length < 3 || cvvValue.toString().length > 4) {
			//cvvcmp.set("v.errors", [{message:"CVV must be 4 digits for American Express and 3 digits for other card types."}]);
			errMesscmp.set("v.value", "CVV must be 4 digits for American Express and 3 digits for other card types.");
			isValid = true;
		} else {
			//monthcmp.set("v.errors", null);
			errMesscmp.set("v.value", '');
		}
		*/
		//cncmp.showHelpMessageIfInvalid();
		//cvvcmp.showHelpMessageIfInvalid();
		return isValid;
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
		//var errMesscmp = cmp.find("cardValidError");
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
		//cncmp.showHelpMessageIfInvalid();
		return cncmp.get('v.validity') !== null && cncmp.get('v.validity').valid;
	},
	isValidCutNOTNumber : function(cmp, idToVerify) {
		var numberCmp = cmp.find(idToVerify);
		var value = numberCmp.get("v.value");
		if (value && isNaN(value)) {
			value = value.toString().substring(0, value.toString().length - 1);
			numberCmp.set("v.value", value);
		}
		//numberCmp.showHelpMessageIfInvalid();
		return numberCmp.get('v.validity') !== null && numberCmp.get('v.validity').valid;
	}
})