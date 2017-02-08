({  
    doInit: function (component, event, helper) {   
        var src = event.getSource();
        helper.getAllHeaderInfo(component);
    },

    goToPayment: function(component, event, helper) {
        var appEvent = $A.get("e.c:payNowRequest");
        appEvent.setParams({ "invoiceId" : null, 'type': 'MakeAPayment' });
        appEvent.fire();      
    },

    goToPaymentPlan: function(component, event, helper) {
        var appEvent = $A.get("e.c:payNowRequest");
        appEvent.setParams({ "invoiceId" : null, 'type': 'CreatePaymentPlan' });
        appEvent.fire();      
    },

    goToMainPage: function(component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({
            'url' : '/'
        }).fire(); 
    },

    goToInvoices: function(component, event, helper) {
        var headerEvent = $A.get("e.c:ToggleHeader");
        headerEvent.fire(); 
        var appEvent = $A.get("e.c:ActivateTab");
        appEvent.setParams({ 'activeTab': 'Invoices' });
        appEvent.fire();      
    },

    goToEstimates: function(component, event, helper) {
        var headerEvent = $A.get("e.c:ToggleHeader");
        headerEvent.fire();  
        var appEvent = $A.get("e.c:ActivateTab");
        appEvent.setParams({ 'activeTab': 'Estimates' });
        appEvent.fire();   
    },

    showTooltip: function(component, event, helper) {
        var tooltip = component.find('popover-tooltip');
        var tooltipCopy = component.find('popover-tooltip-copy');
        $A.util.toggleClass(tooltip,"slds-hide");
        $A.util.toggleClass(tooltipCopy,"slds-hide");
    },
})