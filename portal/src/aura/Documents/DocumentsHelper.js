/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    getDocuments: function (component) {
        var action = component.get("c.getDocumentsInOrder");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var docs = response.getReturnValue();
                var existPdfFlag = false;
                for (var i = 0; i < docs.length; i++) {
                    if (docs[i].doc.ContentType == 'application/pdf') {
                        existPdfFlag = true;
                        break;
                    }
                }
                component.set('v.documents', docs);
                component.set('v.existPdfFlag', existPdfFlag);
            }
        });
        $A.enqueueAction(action);
    },

    updateSorting: function (component, orderCriteria, orderType) {
        var action = component.get("c.getDocumentsInOrder");
        action.setParams({
            criteria: orderCriteria,
            orderType: orderType,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var docs = response.getReturnValue();
                component.set('v.documents', docs);
            }
        });
        $A.enqueueAction(action);
    }
})