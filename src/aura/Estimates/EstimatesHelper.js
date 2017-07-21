/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
	getAllEstimates : function(component) {
	console.log('Init Estimate');
		var action = component.get("c.getAllEstimates");
		var additionalFilter = '';
		
		var selectedPatients = component.get('v.patientSet');
		console.log('pat', selectedPatients);
		if(selectedPatients != null && selectedPatients.length > 0) {
			for(var i = 0; i < selectedPatients.length; i++) {
				if(selectedPatients[i].isSelected == true) {
					additionalFilter += "'" + selectedPatients[i].id + "',";
				}
			}
			
			if(additionalFilter == '') {
				additionalFilter = 'null';
			}
		}
		
		action.setParams({
			'groupFilter' : component.get("v.groupFilter"),
			'additionalFilter' : additionalFilter
		});
		
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var listOfEstimates = response.getReturnValue();
				console.log('listOfEstimates', listOfEstimates);
				console.log('component.get("v.groupFilter")', component.get("v.groupFilter"));
				console.log('listOfEstimates.length', listOfEstimates.length);

					if (listOfEstimates.length > 0 || selectedPatients.length > 0) {
						$A.util.removeClass(component.find('main-body'), 'display-none');
						$A.util.removeClass(component.find('estimate_details'), 'display-none');
					} else {
						if(selectedPatients == null || selectedPatients.length == 0)
						$A.util.removeClass(component.find('empty-estimates'), 'display-none');
					}
				this.createTiles(component,listOfEstimates);
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
				this.getAllEstimates(component);
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

	createTiles : function(component,listOfEstimates) {
		
		component.set('v.estivates',[]);

		for (var i = 0; i < listOfEstimates.length; i++) {
			$A.createComponent(
				"c:Estimate",
				{
					"estimate" : listOfEstimates[i],
					"tileId" : i,
					'isOnPaymentsPage' : false
				},
				function(estivate, status, errorMessage) {
					if (status === "SUCCESS") {
						var estivates = component.get('v.estivates');
						estivates.push(estivate);
						component.set('v.estivates',estivates);
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
			"c:EstimateDetails",
			{
				"listOfEstimates" : listOfEstimates
			},
			function(newComponent, status, errorMessage) {
				if (status === "SUCCESS") {
					var invoiceEstimate = component.find('estimate_details');
					invoiceEstimate.set("v.body",newComponent);
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