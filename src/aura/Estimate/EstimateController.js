({
	doInit : function (component, event, helper) {
		var isOnPaymentsPage = component.get('v.isOnPaymentsPage');
		if(isOnPaymentsPage) {
			console.log('CREATED');		
			var monthNames = ["January", "February", "March", "April", "May", "June",
			  "July", "August", "September", "October", "November", "December"
			];
			var estimate = component.get('v.estimate');
			var dateOfService = new Date(estimate.singleEncounter.Date_of_Service__c);
			var year = dateOfService.getFullYear();
			var month = dateOfService.getMonth();
			var day =  dateOfService.getDate();
			component.set('v.depositDueBy', monthNames[month].substring(0, 3) + ' ' + day);
			month++;
			month = month < 10 ? '0' + month : month;
			day = day < 10 ? '0' + day : day;
			component.set('v.invoiceNameDate', month + '/' + day + '/' + year)
			console.log('dateOfService', month + '/' + day + '/' + year);
		}
	},

	activateTile : function (component, event, helper) {
		console.log(component.get("v.tileId"));
		if(!component.get('v.isOnPaymentsPage')) {
			$A.get("e.c:activateEstimateTileRequest").setParams({
				"tileId" : component.get("v.tileId")
			}).fire();
		}
	},

	sendEstimateNowToHeader: function(component, event, helper) {
        var appEvent = $A.get("e.c:payNowRequest");

console.log('SinglerEstimateId', component.get('v.estimate.singleEncounter.Id'));
        appEvent.setParams({ 
        	"invoiceId" : component.get('v.estimate.singleEncounter.Id'), 
        	'type': 'MakeAPayment', 
        	'isEstimate': true,
        	'hideCreatePaymentPlanTab' : true 
        });
        appEvent.fire();
	},

	activateTileHandler : function (component, event, helper) {
		var tileId = component.get("v.tileId");
		console.log(tileId);
		console.log(event.getParam('tileId'));
		console.log(event.getParam('tileId') == tileId);
		if (event.getParam('tileId') == tileId) {
			$A.util.addClass(component.find('tile'), 'active');
		} else {
			$A.util.removeClass(component.find('tile'), 'active');
		}
	},

	selectEstimate: function(component, event, helper){
		$A.util.toggleClass(component.find('selectIcon'), 'selected');
		var activated = component.get('v.activated');
		var estimate = component.get('v.estimate');
		var balanceDue = estimate.singleEncounter.Patient_Portion__c;
		if(!activated){
			balanceDue = - balanceDue;
		}
		component.set('v.activated', !activated);
		var calculatePaymentBalance  = $A.get("e.c:calculatePaymentBalanceEvent");
		calculatePaymentBalance.setParams({
			"changeSum" : balanceDue,
			"add": !activated
		});
		calculatePaymentBalance.fire();
	},

	toggleAllInvoices : function(component, event, helper) {
		if(component.get('v.activated') === event.getParam('SelectAll')){
			return;
		}
		var balanceDue;
		var activated = event.getParam('SelectAll');
		var invoice = component.get('v.invoice');
		if(activated) {
			$A.util.addClass(component.find('selectIcon'), 'selected');
			balanceDue = -invoice.balanceDue;
		} else {
			$A.util.removeClass(component.find('selectIcon'), 'selected');
			balanceDue = invoice.balanceDue;
		}
		component.set('v.activated', activated);
		var calculatePaymentBalance  = $A.get("e.c:calculatePaymentBalanceEvent");
		calculatePaymentBalance.setParams({
			"changeSum" : balanceDue,
			"invoices": [invoice],
			"add": activated
		});
		calculatePaymentBalance.fire();
	},
})