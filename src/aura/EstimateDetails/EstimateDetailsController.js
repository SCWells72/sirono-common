({
	showDetails : function (component, event, helper) {
		var tileId = event.getParam('tileId');
		if (component.get("v.activeEstimate") != tileId) {
			component.set("v.activeEstimate",tileId);
			component.set("v.estimate",component.get("v.listOfEstimates")[tileId]);
			console.log('url' + component.get("v.listOfEstimates")[tileId].fileUrl);
			component.set("v.fileUrl", 'https://c.cs18.content.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=06811000000ADunAAG');
		}
	},

	sendEstimateNowToHeader: function(component, event, helper) {
        var appEvent = $A.get("e.c:payNowRequest");
        appEvent.setParams({ 
        	"invoiceId" : component.get('v.estimate.singleEncounter.Id'), 
        	'type': 'MakeAPayment', 
        	'isEstimate': true,
        	'hideCreatePaymentPlanTab' : true
    	});
        appEvent.fire();
	},
	preview : function(component, event, helper) {
		$A.get('e.lightning:openFiles').fire({
			recordIds: ['06811000000ADunAAG', '06911000000ADmwAAG']
		});
	},
	previewold : function(component, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({
		  "url": "https://cs18.salesforce.com/sfc/p/#11000000DprC/a/1100000000t1/9BtWR9wcq2.PCekp8HcjodW9JUfnlJBCP4WOIXOosBM"
		});
		urlEvent.fire();
	},
	toggleModal: function (component, event, helper) { 
		var modal = component.find('slds-modal'); 
		var backdrop = component.find('slds-backdrop'); 
		$A.util.toggleClass(modal, 'slds-fade-in-open'); 
		$A.util.toggleClass(backdrop, 'slds-backdrop--open'); 
	}
})