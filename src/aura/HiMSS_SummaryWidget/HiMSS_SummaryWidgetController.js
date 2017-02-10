({  
    doInit: function (component, event, helper) {   
        var src = event.getSource();
        helper.getAllHeaderInfo(component);
    },

    goToMainPage: function(component, event, helper) {
    	var guarantorWrapper = component.get('v.guarantorWrapper');
    	console.log('::::guarantorWrapper.grtUser.userName::' + guarantorWrapper.grtUser.userName);
    	console.log('::::guarantorWrapper.grtUser.password::' + guarantorWrapper.grtUser.password);
        $A.get("e.force:navigateToURL").setParams({
            'url' : 'https://portal-sirono.cs18.force.com/guarantor/s/?un=' + guarantorWrapper.grtUser.userName + '@gmail.com&pw=' + guarantorWrapper.grtUser.password
        }).fire(); 
    },

    // goToInvoices: function(component, event, helper) {
    //     helper.goToMainPage(component, 'Invoices');
    // },

    // goToEstimates: function(component, event, helper) {
    //     helper.goToMainPage(component, 'Estimates');
    // },

    showTooltip: function(component, event, helper) {
        var tooltip = component.find('popover-tooltip');
        var tooltipCopy = component.find('popover-tooltip-copy');
        $A.util.toggleClass(tooltip,"slds-hide");
        $A.util.toggleClass(tooltipCopy,"slds-hide");
    },
})