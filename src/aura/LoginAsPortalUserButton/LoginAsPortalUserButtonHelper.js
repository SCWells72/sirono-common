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
        getLoginAttributesAction.setCallback(this,
            /**
             * @param {Action} response
             */
            function(response) {
                var state = response.getState();

                // If all was well, go to the impersonated user login URL
                if (component.isValid() && (state === "SUCCESS")) {
                    var loginAttributes = response.getReturnValue();

                    var loginUrl = "/servlet/servlet.su?" +
                        "retURL=/" + recordId + "&" +
                        "oid=" + loginAttributes.orgId + "&" +
                        "sunetworkid=" + loginAttributes.networkId + "&" +
                        "sunetworkuserid=" + loginAttributes.userId;

                    document.location.href = loginUrl;
                }

                // If there was an error, hide the spinner and show the message
                else if (component.isValid() && (state === "ERROR")) {
                    var errorMessage = "";
                    var errors = response.getError();
                    if (errors !== null) {
                        for (var i = 0; i < errors.length; i++) {
                            errorMessage += errors[i].message;
                            if (i < (errors.length - 1)) {
                                errorMessage += "\n";
                            }
                        }
                    }
                    component.set("v.errorMessage", errorMessage);
                    $A.get("e.force:refreshView").fire();
                }
            });
        $A.enqueueAction(getLoginAttributesAction);
    }
});