({
    checkValidation : function(component, event, helper){
        console.log('checkValidation');

        var cardName = component.find("cardName").get("v.validity");
        var cardNumber = component.find("cardNumber").get("v.validity");
        var cvv = component.find("cvv").get("v.validity");
        var month = component.find("month").get("v.validity");
        var year = component.find("year").get("v.validity");
        var address = component.find("address").get("v.validity"); 
        var zipcode = component.find("zipcode").get("v.validity");

        if ((cardName != null && cardName.valid) &&
           (cardNumber != null && cardNumber.valid) &&
           (cvv != null && cvv.valid) &&
           (month != null && month.valid) &&
           (year != null && year.valid) &&
           (address != null && address.valid) &&
		   (zipcode != null && zipcode.valid)           
        ) {
            console.log('checkValidation true');
           return true;
        } else {
            console.log('checkValidation false');
            return false;
        }        
    },
    
    checkErrorMessages : function(component, event, helper){
        console.log('checkErrorMessages');
        var cardNameErrors = component.find("cardNameError").get("v.value");
        console.log('cardNameError', cardNameErrors);
        var cardNumberErrors = component.find("cardNumberError").get("v.value");
        console.log('cardNumberError', cardNumberErrors);
        var cvvErrors = component.find("cvvError").get("v.value");
        console.log('cvvError', cvvErrors);
        var expirationErrors = component.find("expirationError").get("v.value");
        console.log('expirationError', expirationErrors);
        var addressErrors = component.find("addressError").get("v.value");
        console.log('addressError', addressErrors);
        var zipcodeErrors = component.find("zipcodeError").get("v.value");
        console.log('zipcodeError', zipcodeErrors);
        if(cardNameErrors != '' ||
           cardNumberErrors != '' ||
           cvvErrors != '' ||
           expirationErrors != '' ||
           addressErrors != '' ||
           zipcodeErrors != ''         
          ){
            console.log('checkValidationE false');
           return false;
        }else{
            console.log('checkValidationE true');
            return true;
        }    
    },
    
    isValidateExpDate : function(cmp) {
        cmp.find('expirationError').set('v.value', '');
		var monthcmp = cmp.find("month");
		var monthValue = monthcmp.get("v.value");
		var yearcmpValue = cmp.find("year").get("v.value");
		var expDate = new Date(yearcmpValue, monthValue);
		var isValid = expDate > Date.now();

		if (isValid) {
           //monthcmp.set("v.errors", [{message:"Expiration date must be in the future."}]);
		} else {
			//monthcmp.set("v.errors", null);
		    cmp.find('expirationError').set('v.value', 'Expiration date must be in the future.');
			
		}
		return isValid;
	},

	isValidateCVV : function(cmp, e) {
		var cncmp = cmp.find("cardNumber");
		var cnValue = cncmp.get("v.value") || '';
		var cvvcmp = cmp.find("cvv");
		var cvvValue = cvvcmp.get("v.value") || '';
		var errMesscmp = cmp.find("cardValidError");

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
					errMesscmp.set("v.value", "1 CVV must be 4 digits for American Express and 3 digits for other card types.");
				} else {
					isValid = true;
					errMesscmp.set("v.value", '');
				}
			} else {
				if (cvvValue.toString().length != 3) {
					errMesscmp.set("v.value", "2 CVV must be 4 digits for American Express and 3 digits for other card types.");
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
		
		return isValid;
	},
	isValidCutNOTNumber : function(cmp, idToVerify) {
		var numberCmp = cmp.find(idToVerify);
		var value = numberCmp.get("v.value");
		if (value && (isNaN(value) || value.includes(' '))) {
			value = value.toString().substring(0, value.toString().length - 1);
			numberCmp.set("v.value", value);
		}
		//numberCmp.showHelpMessageIfInvalid();
		return numberCmp.get('v.validity') !== null && numberCmp.get('v.validity').valid;
	}
})