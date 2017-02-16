({
	getDataFromHeader : function(component, helper) {
		var appEvent = $A.get("e.c:HiMSS_SummaryWidgetRotateEvent");
		console.log('::::appEvent:::::' + appEvent);
		appEvent.setParams({ 
        	'type': 'get'
    	});
        appEvent.fire();
	},

	getAllHeaderInfo : function(component, helper) {
		var action = component.get("c.getAllHeaderInfo");
        action.setCallback(this, function(response) {
	    	if (response.getState() === 'SUCCESS') {
	    		var guarantorWrapperList = response.getReturnValue();
		        component.set('v.guarantorWrapperList', guarantorWrapperList);
		        // helper.setGuarantorWrapper(component, helper);
		        helper.getDataFromHeader(component, helper);
	    	}
        });
        $A.enqueueAction(action);
	},

	getFormatter : function() {
		var formatter = new Intl.NumberFormat('en-US', {
		  style: 'currency',
		  currency: 'USD',
		  minimumFractionDigits: 0,
		});
		return formatter;
	},

	setGuarantorWrapper : function(component, event, helper) {
		console.log('::::setGuarantorWrapper::::::');
		component.set('v.isLogin', event.getParam('isLogin'));
		var formatter = helper.getFormatter();
		var guarantorWrapperList = component.get('v.guarantorWrapperList');
		var guarantorWrapperListCounter = helper.getGuarantorWrapperListCounter(component, event, helper, guarantorWrapperList);
		var guarantorWrapper = guarantorWrapperList[guarantorWrapperListCounter];
        component.set('v.guarantorWrapper', guarantorWrapper);
        
        if (typeof(guarantorWrapper.contact) != "undefined") {
            component.set('v.invoiceValue', formatter.format(Math.floor(guarantorWrapper.contact.invoicedBalance)));
    		component.set('v.invoiceValuePart', (guarantorWrapper.contact.invoicedBalance % 1).toFixed(2).toString().substring(2));
    	}

	},

	getGuarantorWrapperListCounter : function(component, event, helper, guarantorWrapperList) {
		console.log('::::event.getParam(guarantorWrapperListCounter)::::::' + event.getParam('guarantorWrapperListCounter'));
		var guarantorWrapperListCounter = event.getParam('guarantorWrapperListCounter');
		if (helper.checkTimer(component, event) || typeof(guarantorWrapperListCounter) == 'undefined') {
			guarantorWrapperListCounter = (typeof(guarantorWrapperListCounter) == 'undefined' || guarantorWrapperListCounter == guarantorWrapperList.length - 1) ?
				0 : guarantorWrapperListCounter + 1;

			var appEvent = $A.get("e.c:HiMSS_SummaryWidgetRotateEvent");
			appEvent.setParams({ 
	        	'type': 'post',
	        	'guarantorWrapperListCounter': guarantorWrapperListCounter,
	        	'guarantorWrapperTimer': new Date(),
	        	'isLogin': false
	    	});
	        appEvent.fire();
            component.set('v.isLogin', false);	        
		}
		return guarantorWrapperListCounter;
	},

	goToMainPage : function(component, tabType) {
        $A.get("e.force:navigateToURL").setParams({
            'url' : '/?activeTab=' + tabType
        }).fire();
	},

	getUrl : function(component) {
		var guarantorWrapper = component.get('v.guarantorWrapper');
		var isLogin = component.get('v.isLogin');
		var url = (isLogin) ? 'https://portal-sirono.cs18.force.com/guarantor/s/?' : 'https://portal-sirono.cs18.force.com/guarantor/s/login/?startURL=/guarantor/s/&ec=302&';
		url += 'un=' + guarantorWrapper.grtUser.userName + '&pw=' + guarantorWrapper.grtUser.password;
		return url;
	},

	checkTimer : function(component, event) {
		console.log('::::checkTimer::::');
		var previousDateTime = event.getParam('guarantorWrapperTimer');
		console.log('::::previousDateTime::::' + previousDateTime);
		if (typeof(previousDateTime) != 'undefined' && previousDateTime != null) {
			console.log('::::::previousDateTime::::' + previousDateTime);
			var currentDateTime = new Date();
			console.log('::::::currentDateTime::::' + currentDateTime);
			var diffMs = (currentDateTime - previousDateTime);
			console.log('::::::diffMs::::' + diffMs);
			var diffMins = ((diffMs % 86400000) % 3600000) / 60000;
			console.log('::::::diffMins::::' + diffMins);
			return (diffMins >= 2) ? true : false;
		} else {
			console.log('::::true::::');
			return true;
		}
	},

	setLogin : function(component, event, helper) {
		component.set('v.isLogin', true);
		var appEvent = $A.get("e.c:HiMSS_SummaryWidgetRotateEvent");
        appEvent.setParams({ 
            'type': 'login'
        });
        appEvent.fire();
	}
})