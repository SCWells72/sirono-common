({
	getAllEstimates : function(component) {
		var action = component.get("c.getAllEstimates");
		
		action.setParams({
			'groupFilter' : component.get("v.groupFilter"),
			'additionalFilter' : component.get("v.additionalFilter")
		});
		
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var listOfEstimates = response.getReturnValue();
				console.log('listOfEstimates ',listOfEstimates);
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

	createTiles : function(component,listOfEstimates) {
		
		component.set('v.invoices',[]);

		for (var i = 0; i < listOfEstimates.length; i++) {
			$A.createComponent(
				"c:Estimate",
				{
					"estimate" : listOfEstimates[i],
					"tileId" : i
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