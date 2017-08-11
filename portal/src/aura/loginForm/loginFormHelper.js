/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({

    qsToEventMap: {
        'startURL': 'e.c:setStartUrl'
    },

    handleLogin: function (component, event, helper, username, password) {
        var action = component.get("c.login");
        var startUrl = component.get("v.startUrl");

        startUrl = decodeURIComponent(startUrl);

        action.setParams({username: username, password: password, startUrl: startUrl});
        action.setCallback(this, function (response) {
            var rtnValue = response.getReturnValue();
            if (rtnValue != null) {
                if (helper.getUrlParameter('activeTab') != false) {
                    rtnValue = rtnValue.replace('CommunitiesLanding', 'CommunitiesLanding?activeTab=' + helper.getUrlParameter('activeTab'));
                } else if (helper.getUrlParameter('tab') != false) {
                    rtnValue = rtnValue.replace('CommunitiesLanding', 'CommunitiesLanding?tab=' + helper.getUrlParameter('tab'));
                }
                window.location.href = rtnValue;
                // component.set("v.errorMessage",rtnValue);
                // component.set("v.showError",true);
            }
        });

        $A.enqueueAction(action);
    },

    getUrlParameter: function (sParam) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1));
        var sURLVariablesGl = sPageURL.split('?');
        var sURLVariablesStr;
        var sURLVariables;
        var sParameterName, i;

        for (i = 0; i < sURLVariablesGl.length; i++) {
            sURLVariablesStr += sURLVariablesGl[i] + '&';
        }

        sURLVariables = sURLVariablesStr.split('&');

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');

            if (sParameterName[0] === sParam) {
                return sParameterName[1] === undefined ? false : sParameterName[1];
            }
        }
        return false;
    },

    getIsUsernamePasswordEnabled: function (component, event, helpler) {
        var action = component.get("c.getIsUsernamePasswordEnabled");
        action.setCallback(this, function (a) {
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isUsernamePasswordEnabled', rtnValue);
            }
        });
        $A.enqueueAction(action);
    },

    getIsSelfRegistrationEnabled: function (component, event, helpler) {
        var action = component.get("c.getIsSelfRegistrationEnabled");
        action.setCallback(this, function (a) {
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isSelfRegistrationEnabled', rtnValue);
            }
        });
        $A.enqueueAction(action);
    },

    getCommunityForgotPasswordUrl: function (component, event, helpler) {
        var action = component.get("c.getForgotPasswordUrl");
        action.setCallback(this, function (a) {
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communityForgotPasswordUrl', rtnValue);
            }
        });
        $A.enqueueAction(action);
    },

    getCommunitySelfRegisterUrl: function (component, event, helpler) {
        var action = component.get("c.getSelfRegistrationUrl");
        action.setCallback(this, function (a) {
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communitySelfRegisterUrl', rtnValue);
            }
        });
        $A.enqueueAction(action);
    }
})