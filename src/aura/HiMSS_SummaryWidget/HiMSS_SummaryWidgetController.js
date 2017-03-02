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
        helper.goToUrl(component, event, helper, null, 'main');
    },

    goToInvoices: function(component, event, helper) {
        helper.goToUrl(component, event, helper, 'activeTab=Invoices', 'main');
    },

    goToEstimates: function(component, event, helper) {
        helper.goToUrl(component, event, helper, 'activeTab=Estimates', 'main');
    },

    goToPayments: function(component, event, helper) {
        helper.goToUrl(component, event, helper, 'tab=MakeAPayment', 'payment');
    },

    goToPaymentPlans: function(component, event, helper) {
        helper.goToUrl(component, event, helper, 'tab=CreatePaymentPlan', 'payment');
    },

    showTooltip: function(component, event, helper) {
        var tooltip = component.find('popover-tooltip');
        var tooltipCopy = component.find('popover-tooltip-copy');
        $A.util.toggleClass(tooltip,"slds-hide");
        $A.util.toggleClass(tooltipCopy,"slds-hide");
    },
})