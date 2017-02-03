({
	doInit : function (component, event, helper) {
		helper.getAllInvoices(component);
	},
    bodyStatus: function (component, event, helper) {
        var status = event.getParam("collapse");
        var alert = event.getParam("alert");
        var scroll = component.find('payment_scroll');
        if(status == "true"){
            $A.util.removeClass(scroll,"small");
        }
        if(status == "false"){
            $A.util.addClass(scroll,"small");
        }
        if(alert == "true"){
            $A.util.removeClass(scroll,"alert");
        }
	},
	showDetails: function (component, event, helper) {
		var tileId = event.getParam('tileId');
		var activeTile = component.get('v.activeTile');
		if(activeTile != tileId) {
			var listOfInvoices = component.get('v.listOfInvoices');
			$A.createComponent(
				"c:InvoiceDetails",
				{
					"invoice" : listOfInvoices[tileId]
				},
				function(newComponent, status, errorMessage) {
					if (status === "SUCCESS") {
						var invoiceDetails = component.find('invoice_details');
						invoiceDetails.set("v.body",newComponent);
					}
					else if (status === "INCOMPLETE") {
						console.log("No response from server or client is offline.");
					}
					else if (status === "ERROR") {
						console.log("Error: " + errorMessage);
					}
				}
			); 
			component.set('activeTile', tileId);
			console.log('finish show detail');
		}
	},
	
    filterInvoices : function(component, event, helper) {
        if(component.get('v.groupFilter') != event.target.dataset.groupType){
            component.set('v.groupFilter', event.target.dataset.groupType);
            helper.getAllInvoices(component);	
			var blockSelect = component.find('blockSelect'); 
			$A.util.removeClass(blockSelect, 'showSelect'); 
        }  
    },
	activateSelect : function(component, event, helper) {
		var blockSelect = component.find('blockSelect'); 
		$A.util.toggleClass(blockSelect, 'showSelect');   
	}
})