({
<<<<<<< HEAD
	doCmpInit: function(cmp, e, hlpr) {
		 var selections = [];
		var _tmp = 1;
		while (_tmp <= 31) {
			selections.push(_tmp);
			_tmp++;
		}
		cmp.set('v.dayOfMonthSelection', selections);
		cmp.set('v.hasError', false);
	},
	changePaymentBalance : function(cmp, e, hlpr){
		console.log('selected balance event');
		var balance = e.getParam('paymentBalance');
		console.log('balance', balance);
		var paymentRequestInfo = cmp.get('v.PaymentRequestInfo');
		console.log(paymentRequestInfo, paymentRequestInfo.length);
		if(paymentRequestInfo.totalAmount != undefined){
			paymentRequestInfo.totalAmount = balance;
			cmp.set('v.PaymentRequestInfo', paymentRequestInfo);
		}else{
			cmp.set('v.selectedInvoiceBalance', balance);
		}
	},
=======
>>>>>>> parent of b62e69b... Changes on "Create Payment Plan", "Make a Payment" tabs and "List of Invoices" component.
	cancelAction: function (cmp, e, hlpr) {
		cmp.getEvent("initPlanInfo").fire();
	},
	updatePaymenTerms: function(cmp, e, hlpr) {
		cmp.getEvent('updatePaymentTerms').fire();
	},
	changeSlider: function(cmp, e, hlpr) {
		console.log(e.srcElement.value)
	},
	showPopoverInfo: function(component, event, helper) {
		var myPopoverInfo = component.find('sldsjsPopoverInfo');
		$A.util.toggleClass(myPopoverInfo, 'slds-hide');         
	}

})