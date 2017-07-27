/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    showDetails: function (component, event, helper) {
        var tileId = event.getParam('tileId');
        if (component.get("v.activeEstimate") != tileId) {
            component.set("v.activeEstimate", tileId);
            component.set("v.estimate", component.get("v.listOfEstimates")[tileId]);
            console.log('url' + component.get("v.listOfEstimates")[tileId].fileUrl);
            component.set("v.fileUrl", 'https://c.cs18.content.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=06811000000ADunAAG');
        }
    },

    sendEstimateNowToHeader: function (component, event, helper) {
        var appEvent = $A.get("e.c:payNowRequest");
        appEvent.setParams({
            "invoiceId": component.get('v.estimate.singleEncounter.Id'),
            'type': 'MakeAPayment',
            'isEstimate': true,
            'hideCreatePaymentPlanTab': true
        });
        appEvent.fire();
    },
})