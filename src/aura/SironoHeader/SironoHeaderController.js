({
    doInit: function (component, event, helper) {
        var urlEvent = window.location.pathname;
        var homePage = '/guarantor/s/';
		var arrowToggleHeader = component.find('arrowToggleHeader');
        if(urlEvent == homePage){
            component.set("v.backButton","false");
			$A.util.removeClass(arrowToggleHeader,"arrowDisplay");
        }
        else{
            component.set("v.backButton","true");
			$A.util.addClass(arrowToggleHeader,"arrowDisplay"); 
        }
		
        helper.getAllHeaderInfo(component);
    },
    
    navigateToURLEvent: function (component, event, helper) {
        var headerWrap = component.find('headerWrap');
        var headerMain = component.find('headerMain');
        var urlEvent = window.location.pathname;
		var arrowToggleHeader = component.find('arrowToggleHeader');
        var homePage = '/guarantor/s/';
        if(urlEvent == homePage){
            component.set("v.backButton","false"); 
			$A.util.removeClass(arrowToggleHeader,"arrowDisplay");
        }
        else{
            component.set("v.backButton","true");
			$A.util.addClass(arrowToggleHeader,"arrowDisplay"); 
        }
        if($A.util.hasClass(headerWrap,"small") == false){
            $A.util.addClass(headerWrap,"small");
        	$A.util.addClass(headerMain,"small");
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
		if(event.getParam('isEstimate') == true){
			component.set('v.isEstimateRecord', true);
		}
        $A.get("e.force:navigateToURL").setParams({
            'url' : '/payments'
        }).fire();        
    },
    putInvoucePaument: function(component, event, helper) {
        var invoiceId = component.get('v.invoiceId');
        var activeTab = component.get('v.activeTab');
		var isEstimate = component.get('v.isEstimateRecord');
		var filter = component.get('v.filter');
        component.set('v.invoiceId', undefined);
        component.set('v.activeTab', undefined);
        component.set('v.filter', undefined);
        var appEvent = $A.get("e.c:payNowResponse");
        appEvent.setParams({ "invoiceId" : invoiceId, "activeTab": activeTab, "isEstimateRecord": isEstimate, "filter": filter});
        appEvent.fire();
    },
})