({  
    doInit: function (component, event, helper) {   
        var src = event.getSource();
        helper.getAllHeaderInfo(component, helper);
    },

    doRotate: function (component, event, helper) {   
        if (event.getParam('type') == 'retrieve') {
            console.log(':::::doRotate::::');
            helper.setGuarantorWrapper(component, event, helper);    
        }
    },

    setRotate: function (component, event, helper) {
        $A.get("e.c:HiMSS_SummaryWidgetRotateEvent").setParams().fire();
    },

    goToMainPage: function(component, event, helper) {
        var url = helper.getUrl(component);
        $A.get("e.force:navigateToURL").setParams({
            'url' : url
        }).fire(); 
        helper.setLogin(component, event, helper);
    },

    goToInvoices: function(component, event, helper) {
        var url = helper.getUrl(component) + '&activeTab=Invoices';
        $A.get("e.force:navigateToURL").setParams({
            'url' : url 
        }).fire();
        helper.setLogin(component, event, helper);
    },

    goToEstimates: function(component, event, helper) {
        var url = helper.getUrl(component) + '&activeTab=Estimates';
        $A.get("e.force:navigateToURL").setParams({
            'url' : url 
        }).fire();
        helper.setLogin(component, event, helper);
    },

    showTooltip: function(component, event, helper) {
        var tooltip = component.find('popover-tooltip');
        var tooltipCopy = component.find('popover-tooltip-copy');
        $A.util.toggleClass(tooltip,"slds-hide");
        $A.util.toggleClass(tooltipCopy,"slds-hide");
    },
})