({
	
	getAllEstimates : function(component){
		var action = component.get('c.getAllEstimates');
		action.setParams({
			'groupFilter' : component.get("v.groupFilter"),
			'additionalFilter' : component.get("v.additionalFilter")
		});
		
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var listOfInvoices = response.getReturnValue();
				component.set("v.listOfInvoices", listOfInvoices);
				var selectedBalance = 0;
				for(var i = 0; i < listOfInvoices.length; i++){
					selectedBalance += listOfInvoices[i].singleEncounter.Balance__c;
				}
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
		var additionalFilter = [];
		
		var selectedPatients = component.get('v.patientSet');
		if(selectedPatients != null && selectedPatients.length > 0) {
			for(var i = 0; i < selectedPatients.length; i++) {
				if(selectedPatients[i].isSelected == true) {
					additionalFilter.push(selectedPatients[i].id);
				}
			}
		}
		action.setParams({
			'groupFilter' : component.get("v.groupFilter"),
			'patientsFilter' : additionalFilter
		});
		
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var listOfInvoices = response.getReturnValue();
				component.set("v.listOfInvoices", listOfInvoices);
				var selectedBalance = 0;
				var allInvoices = [];
				console.log('PISH:', listOfInvoices);
				for(var i = 0; i < listOfInvoices.length; i++){
					console.log('invoice balance', listOfInvoices[i]);
					selectedBalance += listOfInvoices[i].balanceDue;
					allInvoices.push(listOfInvoices[i].singleInvoice.Id);
				}
				console.log('selectedBalance', selectedBalance);
				console.log('allInvoices to event', allInvoices);
				var calculatePaymentBalance  = $A.get("e.c:calculatePaymentBalanceEvent");
				calculatePaymentBalance.setParams({
					"paymentBalance" : selectedBalance,
					"allInvoices" : allInvoices
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

	init: function(component) {
		var action = component.get("c.getPatientList");
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var patientList = response.getReturnValue();
				this.buildPatientList(component, patientList);
				this.getAllInvoices(component);
			} else if (state === "ERROR") {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " + errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			}
		});
		$A.enqueueAction(action);
	},

	buildPatientList : function(component, patientListDB) {
		//init patient list
		var patientList = [];
		var patientSet  = new Set();
		for (var i = 0; i < patientListDB.length; i++) {
			if(!patientSet.has(patientListDB[i].id)) {
				patientList.push({
							id : patientListDB[i].id,
						  name : patientListDB[i].name,
					isSelected : patientListDB[i].isSelected,
					       MRN : patientListDB[i].MRN
				});
				patientSet.add(patientListDB[i].id);
			}
		}
		component.set('v.patientSet', patientList);
		component.set('v.patientLabel', 'All Patients');
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
				var allInvoices = [];
				for(var i = 0; i < listOfInvoices.length; i++){
					console.log('invoice balance', listOfInvoices[i]);
					selectedBalance += listOfInvoices[i].balanceDue;
					allInvoices.push(listOfInvoices[i].singleInvoice.Id);
				}
				console.log('selectedBalance', selectedBalance);
				var calculatePaymentBalance  = $A.get("e.c:calculatePaymentBalanceEvent");
				calculatePaymentBalance.setParams({
					"paymentBalance" : selectedBalance,
					"allInvoices" : allInvoices
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
		console.log('listOfInvoices',listOfInvoices);
		component.set('v.invoices',[]);
		component.set('v.blockInvoices',[]);
		var selectedTab = component.get('v.selectedTab');
		console.log('CreateTiles', selectedTab);
		if(selectedTab != 'MakeAPayment'){
			for (var i = 0; i < listOfInvoices.length; i++) {
				console.log(listOfInvoices[i].singleInvoice.Invoice_Status__c);
				// Add additional checks for filling list of invoices in if conditions
				if(listOfInvoices[i].singleInvoice.Invoice_Status__c != 'On Payment Plan'){
					console.log('Check Invoice');
					$A.createComponent(
						"c:SingleInvoice",
						{
							"invoice" : listOfInvoices[i],
							"tileId" : i,
							"selectedTab" : "CreatePaymentPlan"
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
				}else{
					console.log('Block Invoice');
					$A.createComponent(
						"c:SingleInvoice",
						{
							"invoice" : listOfInvoices[i],
							"tileId" : i,
							"selectedTab" : "CreatePaymentPlan"
						},
						function(invoice, status, errorMessage) {
							if (status === "SUCCESS") {
								var invoices = component.get('v.blockInvoices');
								invoices.push(invoice);
								console.log('invoices', invoices);
								component.set('v.blockInvoices',invoices);
								console.log(component.get('v.blockInvoices'));
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
		}else{
			for (var i = 0; i < listOfInvoices.length; i++) {
				console.log('263',listOfInvoices[i]);
				// Add additional checks for filling list of invoices in if conditions
					$A.createComponent(
						"c:SingleInvoice",
						{
							"invoice" : listOfInvoices[i],
							"tileId" : i,
							"selectedTab" : "MakeAPayment"
						},
						function(invoice, status, errorMessage) {
							if (status === "SUCCESS") {
								var invoices = component.get('v.invoices');
								console.log('invoices', invoices);
								invoices.push(invoice);
								console.log('invoices2', invoices);
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
	},

	createEstimateTiles : function(component, listOfInvoices){
		component.set('v.invoices',[]);

		for (var i = 0; i < listOfInvoices.length; i++) {
			console.log('Estimate', listOfInvoices[i]);
			$A.createComponent(
				"c:Estimate",
				{
					"estimate" : listOfInvoices[i],
					"tileId" : i,
					"isOnPaymentsPage" : true
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