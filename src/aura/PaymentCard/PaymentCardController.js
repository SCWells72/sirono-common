({

	doInit: function (component, event, helper) {
		var CreditCard = component.get('v.CreditCard');
        console.log('CreditCard', CreditCard);
	},
    
    checkValidation : function(component, event,helper){
        console.log('checkValidation');
        helper.isValidateExpDate(component);
        if(helper.checkValidation(component, event, helper) &&
           helper.checkErrorMessages(component, event, helper)){
            component.set('v.CheckValidation', true);
    	}else{
        	component.set('v.CheckValidation', false);    
        }
    },

    validateExpDate : function(cmp, e, hlpr) {
        console.log('validateExpDate');
		hlpr.isValidateExpDate(cmp);
	},
	validateCVV : function(cmp, e, hlpr) {
		//hlpr.validateCVV(cmp);
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