/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
	myAction: function (component, event, helper) {
		
	},

	checkMessages: function(component, event, helper){
		var messages = component.get('v.validationMessages');
		console.log('messages', messages);
		if(messages.length == 1){
			console.log('One message');
			if(messages[0].includes(';')){
				console.log('SM');
				component.set('v.showSuccessMessage', true);
				var arrList = messages[0].split(';');
				console.log(arrList);
				component.set('v.transactionNumber', arrList[1]);
				component.set('v.transactionAmount', arrList[2]);
			}
		}else{
			component.set('v.showSuccessMessage', false);
		}
	}
})