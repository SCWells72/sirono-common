/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
	getAllHeaderInfo : function(component, helper) {
		helper.getDataFromHeader(component, helper);
	},

	getDataFromHeader : function(component, helper) {
		var appEvent = $A.get("e.c:HiMSS_SummaryWidgetRotateEvent");
		appEvent.setParams({ 
        	'type': 'get'
    	});
        appEvent.fire();
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
		var isTimer = helper.checkTimer(component, event);
		var isActiveUser = event.getParam('isActiveUser');

		var getNewUser = (isTimer == true || (isTimer == null && ! isActiveUser)) ? 'true' : 'false';
		var action = component.get("c.getAllHeaderInfo");
		action.setParams({
			'getNewUser' : getNewUser
		});

        action.setCallback(this, function(response) {
	    	if (response.getState() === 'SUCCESS') {
	    		var guarantorWrapperList = response.getReturnValue();
		        component.set('v.guarantorWrapperList', guarantorWrapperList);
		        component.set('v.guarantorWrapper', guarantorWrapperList[0]);
		        var guarantorWrapper = component.get('v.guarantorWrapper');
		        var formatter = helper.getFormatter();
		        if (typeof(guarantorWrapper.contact) != "undefined") {
		            component.set('v.invoiceValue', formatter.format(Math.floor(guarantorWrapper.contact.invoicedBalance)));
		    		component.set('v.invoiceValuePart', (guarantorWrapper.contact.invoicedBalance % 1).toFixed(2).toString().substring(2));
		    	}

				if (event.getParam('userName') != guarantorWrapper.grtUser.userName) {
					component.set('v.isLogin', false);
				} else {
					component.set('v.isLogin', true);
				}

				var guarantorWrapperTimer;
				if (typeof(guarantorWrapper.paymentPlan) != 'undefined' && guarantorWrapper.paymentPlan != null && guarantorWrapper.paymentPlan.isActive) {
					var previousDateTime = event.getParam('guarantorWrapperTimer');
					if (typeof(previousDateTime) != 'undefined' && previousDateTime != null) {
						guarantorWrapperTimer = previousDateTime;
					} else {
						guarantorWrapperTimer = new Date();
					}
				} else {
					guarantorWrapperTimer = null;
				}

				var appEvent = $A.get("e.c:HiMSS_SummaryWidgetRotateEvent");
					appEvent.setParams({ 
			        	'type': 'post',
			        	'userName': guarantorWrapper.grtUser.userName,
			        	'guarantorWrapperTimer': guarantorWrapperTimer,
			        	'isActiveUser': true
			    	});
		        appEvent.fire();
	    	}
        });
        $A.enqueueAction(action);
		// var guarantorWrapperListCounter = helper.getGuarantorWrapperListCounter(component, event, helper, guarantorWrapperList);
		// var guarantorWrapper = guarantorWrapperList[guarantorWrapperListCounter];
        // component.set('v.guarantorWrapper', guarantorWrapper);
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

	goToUrl : function(component, event, helper, tabAttribute, pageType) {
		var mainPartUrl = helper.getUrl(component, pageType);
		var url = (tabAttribute == null) ? mainPartUrl : mainPartUrl + tabAttribute;
        $A.get("e.force:navigateToURL").setParams({
            'url' : url
        }).fire(); 
        helper.setLogin(component, event, helper);
	},

	getUrl : function(component, pageType) {
		var guarantorWrapper = component.get('v.guarantorWrapper');
		var isLogin = component.get('v.isLogin');
		var url;
		if (pageType == 'main') {
			url = (isLogin) ? 'https://portal-sirono.cs18.force.com/guarantor/s/?' : 'https://portal-sirono.cs18.force.com/guarantor/s/login/?startURL=/guarantor/s/&ec=302&';
		} else {
			url = (isLogin) ? 'https://portal-sirono.cs18.force.com/guarantor/s/payments?' : 'https://portal-sirono.cs18.force.com/guarantor/s/login/?startURL=/guarantor/s/payments&ec=302&';
		}
		
		if (! isLogin) {
			url += 'un=' + guarantorWrapper.grtUser.userName + '&pw=' + guarantorWrapper.grtUser.password + '&';	
		}
		
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
			return null;
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