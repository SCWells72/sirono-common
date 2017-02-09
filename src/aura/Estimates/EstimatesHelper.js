({
	getAllEstimates : function(component) {
		var action = component.get("c.getAllEstimates");
		var additionalFilter = '';
		
		var selectedPatients = component.get('v.patientSet');
		if(selectedPatients != null) {
			for(var i = 0; i < selectedPatients.length; i++) {
				if(selectedPatients[i].isSelected == true) {
					additionalFilter += "'" + selectedPatients[i].id + "',";
				}
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

				if (component.get("v.groupFilter") == 'All') {
					if (listOfEstimates.length > 0) {
						$A.util.removeClass(component.find('main-body'), 'display-none');
						$A.util.removeClass(component.find('estimate_details'), 'display-none');
					} else {
						$A.util.removeClass(component.find('empty-estimates'), 'display-none');
					}
				}

				if(additionalFilter == '') {
					this.buildPatientList(component, listOfEstimates, selectedPatients);
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

	buildPatientList : function(component, listOfEstimates, selectedPatients) {
		//init patient list
		var patientList = [];
		var patientSet  = new Set();
		for (var i = 0; i < listOfEstimates.length; i++) {
			if(!patientSet.has(listOfEstimates[i].singleEncounter.Patient__r.Id)) {
				var patientMRN = '';
				if(listOfEstimates[i].singleEncounter.Patient__r.Medical_Record_Number__c != undefined && listOfEstimates[i].singleEncounter.Patient__r.Medical_Record_Number__c != null) {
					patientMRN = ' (MRN: ' + listOfEstimates[i].singleEncounter.Patient__r.Medical_Record_Number__c + ')';
				}
				patientList.push({
							id : listOfEstimates[i].singleEncounter.Patient__r.Id,
						  name : listOfEstimates[i].singleEncounter.Patient__r.Name,
					isSelected : true,
					       MRN : patientMRN
				});
				patientSet.add(listOfEstimates[i].singleEncounter.Patient__r.Id);
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