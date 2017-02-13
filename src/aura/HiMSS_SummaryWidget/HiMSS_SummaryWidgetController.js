({  
    doInit: function (component, event, helper) {   
        var src = event.getSource();
        helper.getAllHeaderInfo(component);
    },

    goToMainPage: function(component, event, helper) {
    	var guarantorWrapper = component.get('v.guarantorWrapper');
        $A.get("e.force:navigateToURL").setParams({
            'url' : 'https://portal-sirono.cs18.force.com/guarantor/s/?un=' + guarantorWrapper.grtUser.userName + '&pw=' + guarantorWrapper.grtUser.password
        }).fire(); 
    },

    goToInvoices: function(component, event, helper) {
        var guarantorWrapper = component.get('v.guarantorWrapper');
        $A.get("e.force:navigateToURL").setParams({
            'url' : 'https://portal-sirono.cs18.force.com/guarantor/s/?un=' + guarantorWrapper.grtUser.userName + '&pw=' + guarantorWrapper.grtUser.password 
                + '&activeTab=Invoices'
        }).fire();
    },

    goToEstimates: function(component, event, helper) {
        var guarantorWrapper = component.get('v.guarantorWrapper');
        $A.get("e.force:navigateToURL").setParams({
            'url' : 'https://portal-sirono.cs18.force.com/guarantor/s/?un=' + guarantorWrapper.grtUser.userName + '&pw=' + guarantorWrapper.grtUser.password 
                + '&activeTab=Estimates'
        }).fire();
    },

    showTooltip: function(component, event, helper) {
        var tooltip = component.find('popover-tooltip');
        var tooltipCopy = component.find('popover-tooltip-copy');
        $A.util.toggleClass(tooltip,"slds-hide");
        $A.util.toggleClass(tooltipCopy,"slds-hide");
    },
})