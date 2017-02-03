({
	
	getAllEstimates : function(component){
		var action = component.get('c.getAllEstimates');
		console.log('component.get("v.groupFilter")', component.get("v.groupFilter"));
		action.setParams({
			'groupFilter' : component.get("v.groupFilter"),
			'additionalFilter' : component.get("v.additionalFilter")
		});
		
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var listOfInvoices = response.getReturnValue();
				console.log('listOfInvoices ',listOfInvoices);
				component.set("v.listOfInvoices", listOfInvoices);
				var selectedBalance = 0;
				for(var i = 0; i < listOfInvoices.length; i++){
					console.log('invoice balance', listOfInvoices[i]);
					selectedBalance += listOfInvoices[i].singleEncounter.Balance__c;
				}
				console.log('selectedBalance', selectedBalance);
				var calculatePaymentBalance  = $A.get("e.c:calculatePaymentBalanceEvent");
				calculatePaymentBalance.setParams({
					"paymentBalance" : selectedBalance
				});
				calculatePaymentBalance.fire();
				this.createEstimateTiles(component,listOfInvoices);
			} else if (state === "ERROR") {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " + 
									errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			}
		});
        $A.enqueueAction(action);
	},
	
	getAllInvoices : function(component) {
		var action = component.get("c.getAllInvoices");
		console.log('component.get("v.groupFilter")', component.get("v.groupFilter"));
		action.setParams({
			'groupFilter' : component.get("v.groupFilter"),
			'additionalFilter' : component.get("v.additionalFilter")
		});
		
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var listOfInvoices = response.getReturnValue();
				console.log('listOfInvoices ',listOfInvoices);
				component.set("v.listOfInvoices", listOfInvoices);
				var selectedBalance = 0;
				for(var i = 0; i < listOfInvoices.length; i++){
					console.log('invoice balance', listOfInvoices[i]);
					selectedBalance += listOfInvoices[i].balanceDue;
				}
				console.log('selectedBalance', selectedBalance);
				var calculatePaymentBalance  = $A.get("e.c:calculatePaymentBalanceEvent");
				calculatePaymentBalance.setParams({
					"paymentBalance" : selectedBalance
				});
				calculatePaymentBalance.fire();
				this.createTiles(component,listOfInvoices);
			} else if (state === "ERROR") {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " + 
									errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			}
		});
        $A.enqueueAction(action);
	},

	getEstimate : function(component, invoiceId) {

		var action = component.get("c.getEstimate");
		
		action.setParams({
			'invoiceId' : invoiceId,
		});
		
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var listOfInvoices = response.getReturnValue();
				console.log('listOfInvoices ',listOfInvoices);
				component.set("v.listOfInvoices", listOfInvoices);
				var selectedBalance = 0;
				for(var i = 0; i < listOfInvoices.length; i++){
					console.log('invoice balance', listOfInvoices[i]);
					selectedBalance += listOfInvoices[i].singleEncounter.Balance__c;;
				}
				console.log('selectedBalance', selectedBalance);
				var calculatePaymentBalance  = $A.get("e.c:calculatePaymentBalanceEvent");
				calculatePaymentBalance.setParams({
					"paymentBalance" : selectedBalance
				});
				calculatePaymentBalance.fire();
				this.createEstimateTiles(component,listOfInvoices);
			} else if (state === "ERROR") {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " + 
									errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			}
		});
        $A.enqueueAction(action);
	},

	getInvoice : function(component, invoiceId) {

		var action = component.get("c.getInvoice");
		
		action.setParams({
			'invoiceId' : invoiceId,
		});
		
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var listOfInvoices = response.getReturnValue();
				console.log('listOfInvoices ',listOfInvoices);
				component.set("v.listOfInvoices", listOfInvoices);
				var selectedBalance = 0;
				for(var i = 0; i < listOfInvoices.length; i++){
					console.log('invoice balance', listOfInvoices[i]);
					selectedBalance += listOfInvoices[i].balanceDue;
				}
				console.log('selectedBalance', selectedBalance);
				var calculatePaymentBalance  = $A.get("e.c:calculatePaymentBalanceEvent");
				calculatePaymentBalance.setParams({
					"paymentBalance" : selectedBalance
				});
				calculatePaymentBalance.fire();
				this.createTiles(component,listOfInvoices);
			} else if (state === "ERROR") {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " + 
									errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			}
		});
        $A.enqueueAction(action);
	},

	createTiles : function(component,listOfInvoices) {
		
		component.set('v.invoices',[]);

		for (var i = 0; i < listOfInvoices.length; i++) {
			console.log(listOfInvoices[i]);
			$A.createComponent(
				"c:SingleInvoice",
				{
					"invoice" : listOfInvoices[i],
					"tileId" : i
				},
				function(invoice, status, errorMessage) {
					if (status === "SUCCESS") {
						var invoices = component.get('v.invoices');
						invoices.push(invoice);
						component.set('v.invoices',invoices);
					}
					else if (status === "INCOMPLETE") {
						console.log("No response from server or client is offline.");
					}
					else if (status === "ERROR") {
						console.log("Error: " + errorMessage);
					}
				}
			);
		}
	},

		createEstimateTiles : function(component, listOfInvoices){
			component.set('v.invoices',[]);

			for (var i = 0; i < listOfInvoices.length; i++) {
				console.log(listOfInvoices[i]);
				$A.createComponent(
					"c:Estimate",
					{
						"estimate" : listOfInvoices[i],
						"tileId" : i
					},
					function(invoice, status, errorMessage) {
						if (status === "SUCCESS") {
							var invoices = component.get('v.invoices');
							invoices.push(invoice);
							component.set('v.invoices',invoices);
						}
						else if (status === "INCOMPLETE") {
							console.log("No response from server or client is offline.");
						}
						else if (status === "ERROR") {
							console.log("Error: " + errorMessage);
						}
					}
				);
			}
		}
		
})