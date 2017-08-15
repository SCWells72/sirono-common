/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    initialize: function (component, event, helper) {
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent": helper.qsToEventMap}).fire();
        component.set('v.isUsernamePasswordEnabled', helper.getIsUsernamePasswordEnabled(component, event, helper));
        component.set("v.isSelfRegistrationEnabled", helper.getIsSelfRegistrationEnabled(component, event, helper));
        component.set("v.communityForgotPasswordUrl", helper.getCommunityForgotPasswordUrl(component, event, helper));
        component.set("v.communitySelfRegisterUrl", helper.getCommunitySelfRegisterUrl(component, event, helper));

        if (helper.getUrlParameter('un') != false && helper.getUrlParameter('pw') != false) {
            var username = helper.getUrlParameter('un').replace('%40', '@');
            var password = helper.getUrlParameter('pw');

            helper.handleLogin(component, event, helper, username, password);
        }
    },

    handleLogin: function (component, event, helper) {
        var username = component.find("username").get("v.value");
        var password = component.find("password").get("v.value");
        helper.handleLogin(component, event, helper, username, password);
    },

    setStartUrl: function (component, event, helper) {
        var startUrl = event.getParam('startURL');
        if (startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },
    onKeyUp: function (component, event, helper) {
        //checks for "enter" key
        if (event.getParam('keyCode') === 13) {
            helper.handleLogin(component, event, helper);
        }
    },

    navigateToForgotPassword: function (cmp, event, helper) {
        var forgotPwdUrl = cmp.get("v.communityForgotPasswordUrl");
        if ($A.util.isUndefinedOrNull(forgotPwdUrl)) {
            forgotPwdUrl = cmp.get("v.forgotPasswordUrl");
        }
        var attributes = {url: forgotPwdUrl};
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    },

    navigateToSelfRegister: function (cmp, event, helper) {
        var selrRegUrl = cmp.get("v.communitySelfRegisterUrl");
        if (selrRegUrl == null) {
            selrRegUrl = cmp.get("v.selfRegisterUrl");
        }

        var attributes = {url: selrRegUrl};
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    }
})