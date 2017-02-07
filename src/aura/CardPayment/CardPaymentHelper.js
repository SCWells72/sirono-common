({
	helperMethod: function () {

	},

	getCardInformation : function(component, event, helper){
		var action = component.get('c.getCardInformation');
		action.setCallback(this, function(response){
            console.log('getCardInformation');
            if(component.isValid() && response.getState() == 'SUCCESS'){
                var info = response.getReturnValue();
				info.amount = component.get('v.selectedPaymentSum');
                component.set('v.cardInformation',info);
				console.log(component.get('v.cardInformation'))
            }else{
                console.error(response.getError()[0].message);
            }
            
        });
        $A.enqueueAction(action);
	},

	makePaymentHelper : function(component, event, helper){
		console.log('t:', JSON.stringify(component.get('v.cardInformation')));
		var isEstimate = component.get('v.isEstimate');
		var action = isEstimate ? component.get('c.makeNewEstimatePayment') : component.get('c.makeNewPayment');
		console.log('action', action);
		action.setParams({jsonPayment: JSON.stringify(component.get('v.cardInformation'))});
        action.setCallback(this, function(response){
            console.log('makePayment');
            if(component.isValid() && response.getState() == 'SUCCESS'){
                var info = response.getReturnValue().split('.');
				var arraySplit = [];
				//arraySplit.push('Errors');
				for(var i = 0;  i < info.length; i++){
					if( info[i].length>2 ){
						arraySplit.push(info[i]);
					}
				};	
				
				component.set('v.messages', arraySplit);
				component.set('v.IsIcon', true);
				component.set('v.IsIcon2', false);

            }else{

                console.error(response.getError()[0].message);
				component.set('v.IsIcon', false);
				component.set('v.IsIcon2', true);
				component.set('v.messages', "Success");
            }
            
        });
        $A.enqueueAction(action);
	}
})