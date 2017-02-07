({
	myAction: function (component, event, helper) {

	},

	checkMessages: function(component, event, helper){
		var messages = component.get('v.validationMessages');
		if(messages.length == 1){
			if(messages[0].includes(';') !== -1){
				component.set('v.showSuccessMessage', true);
				var arrList = messages.split(';');
				component.set('v.transactionNumber', arrList[0]);
				component.set('v.transactionAmount', arrList[1]);
			}
		}else{
			component.set('v.showSuccessMessage', false);
		}
	}
})