/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    /**
     * @param {Component} component
     */
    loginAsPortalUser: function(component) {
        var recordId = component.get("v.recordId");

        var getLoginAttributesAction = component.get("c.getLoginAttributes");
        getLoginAttributesAction.setParams({
            "contactId": recordId
        });
        getLoginAttributesAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var loginAttributes = response.getReturnValue();

                console.log('recordId = ' + recordId);
                var loginUrl = "/servlet/servlet.su?" +
                    "retURL=/" + recordId + "&" +
                    "oid=" + loginAttributes.orgId + "&" +
                    "sunetworkid=" + loginAttributes.networkId + "&" +
                    "sunetworkuserid=" + loginAttributes.userId;
                console.log('loginUrl = ' + loginUrl);

                document.location.href = loginUrl;
            }
        });
        $A.enqueueAction(getLoginAttributesAction);
    }
});