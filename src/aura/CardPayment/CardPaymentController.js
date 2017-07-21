/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({

	doInit: function (component, event, helper) {
		var credtCardSelections = component.get('c.getCardSelectOptions');
		credtCardSelections.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				var selections = response.getReturnValue();
				console.log('SEL', selections);
				var months = [];
				var years = [];

				for (var val in selections.YEARS) {
					years.push(val);
				}
				for (var val in selections.MONTHS) {
					months.push({
						value: val,
						label: selections.MONTHS[val]
					});
					months.sort(function(a, b) {
						var av = parseInt(a.value);
						var bv = parseInt(b.value);
						return av - bv;
					});
				}

				component.set('v.months', months);
				component.set('v.years', years);
			}
		});
		$A.enqueueAction(credtCardSelections);
		helper.getCardInformation(component, event, helper);
		var curr = component.find("amount");
		curr.set("v.format", '$#,###.00');
	},

	changePaymentBalance: function(component, event, helper){
		console.log('Selected Balance Event');
		var rList = [];
		var balance = event.getParam('paymentBalance');
		var changeSum = event.getParam('changeSum');
		var recordId = event.getParam('recordId');
		var listOfInvoices = event.getParam('invoices');
		var allInvoices = event.getParam('allInvoices');
		var invoices = component.get('v.selectedInvoices');
		console.log(balance, changeSum);
		if(balance == undefined){
			var currentBalance = component.get('v.selectedPaymentSum');
			console.log(currentBalance);
			if((currentBalance - changeSum) < 0){
				return;
			}
			component.set('v.selectedPaymentSum', currentBalance - changeSum);
		}else{
			component.set('v.selectedPaymentSum', balance);
		}

		if(allInvoices != undefined && allInvoices.length != 0){
			component.set('v.selectedInvoices', allInvoices);
		}
		if(recordId != undefined){
			var wasAdded = false;
			for(var i = invoices.length - 1; i >= 0; i--){
				if(invoices[i] == recordId){
					wasAdded = true;
					invoices.splice(i,1);
				}
			}
			if(!wasAdded){
				invoices.push(recordId);
			}
			console.log('Invoices for payment:', invoices);
			component.set('v.selectedInvoices', invoices);
		}
		console.log(balance, changeSum);
		

		var curr = component.find("amount");
		curr.set("v.format", '$#,###.00');
	},

	makePayment : function(component, event, helper){		
		helper.makePaymentHelper(component, event, helper);          
	},

	updateAmountInformation : function(component, event, helper){
		var curr = component.find("amount");
		curr.set("v.format", '$#,###.00');
	},

	validateExpDate : function(cmp, e, hlpr) {
		hlpr.isValidateExpDate(cmp);
	},
	validateCVV : function(cmp, e, hlpr) {
		//hlpr.validateCVV(cmp);
		hlpr.isValidCutNOTNumber(cmp, "cvv");
		hlpr.isValidateCVV(cmp);
	},
	validateCardN : function(cmp, e, hlpr) {
		hlpr.isValidateCardN(cmp);         
	},
	validateZip : function(cmp, e, hlpr) {
		hlpr.isValidCutNOTNumber(cmp, "zipcode");
	},
})