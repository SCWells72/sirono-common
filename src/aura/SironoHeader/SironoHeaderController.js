({
    doInit: function (component, event, helper) {
        var urlEvent = window.location.pathname;
        var homePage = '/guarantor/s/';
        if(urlEvent == homePage){
            component.set("v.backButton","false");
        }
        else{
            component.set("v.backButton","true");
        }
    },
    
    navigateToURLEvent: function (component, event, helper) {
        var headerWrap = component.find('headerWrap');
        var headerMain = component.find('headerMain');
        var urlEvent = window.location.pathname;
        var homePage = '/guarantor/s/';
        if(urlEvent == homePage){
            component.set("v.backButton","false");
        }
        else{
            component.set("v.backButton","true");
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
	}
})