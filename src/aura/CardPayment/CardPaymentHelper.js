/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
	getCardInformation : function(component, event, helper){
		var action = component.get('c.getCardInformation');
		action.setCallback(this, function(response){
            console.log('getCardInformation');
            if(component.isValid() && response.getState() == 'SUCCESS'){
                var info = response.getReturnValue();
				info.amount = component.get('v.selectedPaymentSum');
                component.set('v.cardInformation',info);
				console.log(component.get('v.cardInformation'))
            }else{
                console.error(response.getError()[0].message);
            }
            
        });
        $A.enqueueAction(action);
	},

	makePaymentHelper : function(component, event, helper){
		var sum = component.get('v.selectedPaymentSum');
		var creditCardInformation = component.get('v.cardInformation');
		if(creditCardInformation != undefined){
			creditCardInformation.amount = sum;
		}
		var isEstimate = component.get('v.isEstimate');
		var encounterId = component.get('v.estimateId');
		var action = isEstimate ? component.get('c.makeNewEstimatePayment') : component.get('c.makeNewPayment');
		if(!isEstimate){
			action.setParams({
				jsonPayment: JSON.stringify(creditCardInformation),
				listIds: JSON.stringify(component.get('v.selectedInvoices'))
			});
		} else {
			action.setParams({
				jsonPayment: JSON.stringify(creditCardInformation),
				estimateId : component.get('v.invoiceId')
			});
		}

        action.setCallback(this, function(response){
            if(component.isValid() && response.getState() == 'SUCCESS'){
                if(!response.getReturnValue().includes('Success')){
					var info = response.getReturnValue().split('.');
					var arraySplit = [];
					for(var i = 0;  i < info.length; i++){
						if( info[i].length>2 ){
							arraySplit.push(info[i]);
						}
					};	
				
					component.set('v.messages', arraySplit);
					component.set('v.IsIcon', true);
					component.set('v.IsIcon2', false);
				}else{
					component.set('v.messages', response.getReturnValue());
					component.set('v.IsIcon', false);
					component.set('v.IsIcon2', true);
					//ReInit list of invoices/estiamtes
					var appEvent = $A.get("e.c:switchTab");
					appEvent.setParams({ 
						"tabName" : 'MakeAPayment',
						"isEstimateType" : isEstimate
					});
					appEvent.fire();

					var appEventSummary = $A.get("e.c:UpdateSummaryWidget");
					appEventSummary.fire();
				}
            }else{

                console.error(response.getError()[0].message);
				component.set('v.IsIcon', false);
				component.set('v.IsIcon2', true);
				component.set('v.messages', "Something gone wrong. Please try again");
            }
            
        });
        $A.enqueueAction(action);
	},

	showError: function(cmp, message) {
		cmp.set('v.hasError', true);
		cmp.find('notificationCmp').showError(message);
	}, 
	showValidError: function(cmp, message) {
		var errMesscmp = cmp.find("cardValidError");
		var errMessage = errMesscmp.get("v.value");
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
		var isValid = false;
		if (! cvvValue ) {
			errMesscmp.set("v.value", '');
			return isValid;
		}
		if ((cncmp.get('v.validity') == null || cncmp.get('v.validity').valid) && cnValue) {
			var cardno = /^(?:3[47][0-9]{13})$/;
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
			//set error "please fill card number"
			errMesscmp.set("v.value", "Please fill in card number");
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
		return numberCmp.get('v.validity') !== null && numberCmp.get('v.validity').valid;
	}
})