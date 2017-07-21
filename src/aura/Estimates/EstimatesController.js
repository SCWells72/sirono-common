/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
	doInit : function (component, event, helper) {
		helper.init(component);
	},
	bodyStatus: function (component, event, helper) {
		var status = event.getParam("collapse");
		var alert = event.getParam("alert");
		var scroll = component.find('payment_scroll');
		if(status == "true"){
			$A.util.removeClass(scroll,"small");
		}
		if(status == "false"){
			$A.util.addClass(scroll,"small");
		}
		if(alert == "true"){
			$A.util.removeClass(scroll,"alert");
		}
	},
	activateSelect : function(component, event, helper) {
		var blockSelect = component.find('blockSelect'); 
		$A.util.toggleClass(blockSelect, 'showSelect');   
	},
	patientsVisibility : function(component, Event, helper) {
		var blockSelect = component.find('patientList');
		$A.util.toggleClass(blockSelect, 'slds-is-open');
	},
	patientSelect : function(component, event, helper) {
		$A.util.toggleClass(event.currentTarget, 'slds-is-selected');
		var patientId = event.currentTarget.dataset.patientId;
		var patientSetOld = component.get('v.patientSet');
		var patientLabel = '';
		var selectCounter = 0;
		for(var i = 0; i < patientSetOld.length; i++) {		
			if(patientSetOld[i].id == patientId) {
				patientSetOld[i].isSelected = $A.util.hasClass(event.currentTarget, 'slds-is-selected');
			}	
			if(patientSetOld[i].isSelected) {
				selectCounter += 1;
				patientLabel += patientSetOld[i].name + ", ";
			}			
		}
		patientLabel = patientLabel.substring(0, patientLabel.length - 2);
		if(selectCounter != patientSetOld.length) {
			if(selectCounter == 0) {
				component.set('v.patientLabel', 'Not Selected');
			} else {
				component.set('v.patientLabel', patientLabel);
			}
		} else {
			component.set('v.patientLabel', 'All Patients');
		}

		helper.getAllEstimates(component);
	},

	filterEstimates : function (component, event, helper) {
		console.log(' event.target.id',  event.target.id);
		var filterValue = event.target.id == 'allEstimates' ? 'All' : 
				event.target.id == 'unpaidEstimates' ? 'Unpaid' : 'Paid';
		console.log('filterValue', filterValue);
		if(component.get('v.groupFilter') != filterValue){
            component.set('v.groupFilter', filterValue);
            helper.getAllEstimates(component);	
        } 
	}
})