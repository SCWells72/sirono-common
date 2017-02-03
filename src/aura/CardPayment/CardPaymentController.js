({

	doInit: function (component, event, helper) {
		var states = ['Alaska', 'Alabama'];
		helper.getCardInformation(component, event, helper);
		component.set('v.States', states);
		var curr = component.find("amount");
		curr.set("v.format", '$#,###.00');
		
	},

	changePaymentBalance: function(component, event, helper){
		console.log('selected balance event');
		var rList = [];
		var balance = event.getParam('paymentBalance');
		var changeSum = event.getParam('changeSum');
		console.log(balance, changeSum);
		if(balance == undefined){
			var currentBalance = component.get('v.selectedPaymentSum');
			console.log(currentBalance);
			component.set('v.selectedPaymentSum', currentBalance - changeSum);
		}else{
			component.set('v.selectedPaymentSum', balance);
		}
		var curr = component.find("amount");
		curr.set("v.format", '$#,###.00');
	},

	makePayment : function(component, event, helper){
		console.log('make payment method');
		console.log(component.get('v.cardInformation'));
		helper.makePaymentHelper(component, event, helper);
	},

	updateAmountInformation : function(component, event, helper){
		var sum = component.get('v.selectedPaymentSum');
		var creditCardInformation = component.get('v.cardInformation');
		console.log('CCI',creditCardInformation);
		console.log('sum', sum);
		if(creditCardInformation != undefined){
			creditCardInformation.amount = sum;
			component.set('v.cardInformation', creditCardInformation);
		}
		var curr = component.find("amount");
		curr.set("v.format", '$#,###.00');
	}
})