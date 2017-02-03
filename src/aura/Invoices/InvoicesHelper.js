({
	getAllInvoices : function(component) {
		var action = component.get("c.getAllInvoices");
		
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
			$A.createComponent(
				"c:Invoice",
				{
					"invoice" : listOfInvoices[i],
					"tileId" : i
				},
				function(invoice, status, errorMessage) {
					if (status === "SUCCESS") {
						var invoices = component.get('v.invoices');
						invoices.push(invoice);
						console.log('invoice', invoice.get('v.invoice').singleInvoice.Partial_Payment_Plan__c);
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

		$A.createComponent(
			"c:InvoiceDetails",
			{
				"listOfInvoices" : listOfInvoices
			},
			function(newComponent, status, errorMessage) {
				if (status === "SUCCESS") {
					var invoiceDetails = component.find('invoice_details');
					invoiceDetails.set("v.body", newComponent);
				}
				else if (status === "INCOMPLETE") {
					console.log("No response from server or client is offline.");
				}
				else if (status === "ERROR") {
					console.log("Error: " + errorMessage);
				}
			}
		);
	},
})