/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    doInit: function (component, event, helper) {	
        var headerWrap = component.find('headerWrap');
        var headerMain = component.find('headerMain');
        var urlEvent = window.location.pathname;
        var homePage = '/guarantor/s/';
		var arrowToggleHeader = component.find('arrowToggleHeader');
        if(urlEvent == homePage){
            component.set("v.backButton","false");
			$A.util.removeClass(arrowToggleHeader,"arrowDisplay");

            if (window.location.href.includes('activeTab=')) {
                $A.util.addClass(headerWrap,"small");
                $A.util.addClass(headerMain,"small");
            }
        }
        else{
            component.set("v.backButton","true");
			$A.util.addClass(arrowToggleHeader,"arrowDisplay"); 
			$A.util.addClass(headerWrap,"small");
        	$A.util.addClass(headerMain,"small");

            if (window.location.href.includes('tab=')) {
                var tabType = window.location.href.split("=").pop();
                component.set('v.activeTab', tabType);
                var appEvent = $A.get("e.c:payCall");
                appEvent.fire();
            } 
        }
		
        helper.getAllHeaderInfo(component);
    },
    
    navigateToURLEvent: function (component, event, helper) {
		if(event.getParam('isredirect') == true) {
			location.reload();
			return;
		}
        var headerWrap = component.find('headerWrap');
        var headerMain = component.find('headerMain');
        var urlEvent = window.location.pathname;
		var arrowToggleHeader = component.find('arrowToggleHeader');
        var homePage = '/guarantor/s/';
        if(urlEvent == homePage){
            component.set("v.backButton","false"); 
			$A.util.removeClass(arrowToggleHeader,"arrowDisplay");
			if($A.util.hasClass(headerWrap,"small") == true){
				$A.util.removeClass(headerWrap,"small");
        		$A.util.removeClass(headerMain,"small");
			}
        }
        else{
            component.set("v.backButton","true");
			$A.util.addClass(arrowToggleHeader,"arrowDisplay"); 
			if($A.util.hasClass(headerWrap,"small") == false){
				$A.util.addClass(headerWrap,"small");
        		$A.util.addClass(headerMain,"small");
			}
        }
    },
    
	toggleHeader : function(component, event, helper) {
        var appEvent = $A.get("e.c:collapsedHeader");
        var headerWrap = component.find('headerWrap');
        var headerMain = component.find('headerMain');

        if($A.util.hasClass(headerWrap,"small")){
            component.set('v.statusHeader','true');
			
        }
        else{
            component.set('v.statusHeader','false');
			
        }
        appEvent.setParams({ "collapse" : component.get('v.statusHeader') });
        appEvent.fire();
		$A.util.toggleClass(headerWrap,"small");
        $A.util.toggleClass(headerMain,"small");
	},
    
    closeInfo: function(component, event, helper) {
        var appEvent = $A.get("e.c:collapsedHeader");
        var headerWrap = component.find('headerWrap');
        var notify = component.find('notify');
        component.set('v.statusAlert','true');
        appEvent.setParams({ "alert" : component.get('v.statusAlert') });
        appEvent.fire();
        $A.util.addClass(notify,"slds-hide");
        $A.util.removeClass(headerWrap,"alert");
    },
    
    showTooltip: function(component, event, helper) {
        var tooltip = component.find('popover-tooltip');
        var tooltipCopy = component.find('popover-tooltip-copy');
        $A.util.toggleClass(tooltip,"slds-hide");
        $A.util.toggleClass(tooltipCopy,"slds-hide");
    },
    
    backHomePage: function(component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({
			'url' : '/' 
		}).fire();
	},
    setInvoice: function(component, event, helper) {
		console.log('setInvoice');
        component.set('v.invoiceId', event.getParam('invoiceId'));
        component.set('v.activeTab', event.getParam('type'));
        component.set('v.filter', event.getParam('filter'));
        component.set('v.hideCreatePaymentPlanTab', event.getParam('hideCreatePaymentPlanTab'));
		if(event.getParam('isEstimate') == true){
			component.set('v.isEstimateRecord', true);
		}
        $A.get("e.force:navigateToURL").setParams({
            'url' : '/payments'
        }).fire();        
    },
    putInvoicePayment: function(component, event, helper) {
		console.log('Put params');
        var invoiceId = component.get('v.invoiceId');
        var activeTab = component.get('v.activeTab');
        var isEstimate = component.get('v.isEstimateRecord');
		var hideCreatePaymentPlanTab = component.get('v.hideCreatePaymentPlanTab');
		var filter = component.get('v.filter');
        component.set('v.invoiceId', undefined);
        component.set('v.activeTab', undefined);
        component.set('v.filter', undefined);
        component.set('v.hideCreatePaymentPlanTab', false);
        var appEvent = $A.get("e.c:payNowResponse");
        appEvent.setParams({ 
            "invoiceId" : invoiceId, 
            "activeTab": activeTab, 
            "isEstimateRecord": isEstimate, 
            "filter": filter,
            "hideCreatePaymentPlanTab" : hideCreatePaymentPlanTab
        });
        appEvent.fire();
    },
	updateHeaderAmountAndDate : function(component, event, helper) {
		var plan = event.getParam('paymentPlan');
		var amount = parseFloat(plan.Installment_Amount__c.toFixed(2));
		var delimiterPos = amount.toString().indexOf('.');
		if(delimiterPos >= 0){
			component.set('v.invoiceValue', '$' + Math.floor(amount));
			component.set('v.invoiceValuePart', parseFloat((amount % 1).toFixed(2)) * 100);
		}else{
			component.set('v.invoiceValue', '$' + amount);
		}
		
		var guarantorWrapper = component.get('v.guarantorWrapper');
		guarantorWrapper.paymentPlan.NextPaymentDate__c = plan.NextPaymentDate__c;
		component.set('v.guarantorWrapper', guarantorWrapper);
	}
})