({

	doCmpInit: function (component, event, helper) {	
		window.setTimeout(
			$A.getCallback(function() {
				if (component.isValid()) {	
					var stateSelections = component.get('c.getStates');
					stateSelections.setCallback(this, function(response){
						if(response.getState() === 'SUCCESS'){
							var states = response.getReturnValue();
							var stateSelection = component.find('state');
							if(states.length > 0) {			
								helper.initOptions(component, states, stateSelection);
							}
						}
					});
					$A.enqueueAction(stateSelections);
				}
			}), 5
		);
	},

	initSelectOptions: function (component, event, helper) {
		window.setTimeout(
			$A.getCallback(function() {
				if (component.isValid()) {	
					var years = component.get('v.years');
					var yearSelection = component.find('year');
					helper.initOptions(component, years, yearSelection);        

					helper.initMonthOptions(component);

					
					var CC = component.get('v.CreditCard');
					if(CC == null || CC.sfId == undefined || CC.sfId == ''){
						helper.getCardInformation(component, event, helper);
					}else{
						helper.getCardInformation(component, event, helper);
						setTimeout(function() { 
								component.set('v.CreditCard', CC);	
						}, 2000);
					}
				}
			}), 5
		);
	},
    
    checkValidation : function(component, event,helper){
        try{
			helper.isValidateExpDate(component);
			helper.isValidCutNOTNumber(component, "cvv");
			helper.isValidCutNOTNumber(component, "zipcode");
			helper.isValidateCVV(component, event);
			if(helper.checkValidation(component, event, helper) &&
			   helper.checkErrorMessages(component, event, helper)){
				component.set('v.CheckValidation', true);
    		}else{
        		component.set('v.CheckValidation', false);    
			}
		}catch(e){
			console.log('ERROR');
		}
    },

    validateExpDate : function(cmp, e, hlpr) {
		hlpr.isValidateExpDate(cmp);
	},
	validateCVV : function(cmp, e, hlpr) {
		hlpr.isValidCutNOTNumber(cmp, "cvv");
		hlpr.isValidateCVV(cmp, e);
	},
	validateCardN : function(cmp, e, hlpr) {
		hlpr.isValidateCardN(cmp);         
	},
	validateZip : function(cmp, e, hlpr) {
		hlpr.isValidCutNOTNumber(cmp, "zipcode");
	},
})