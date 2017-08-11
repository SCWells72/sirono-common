/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    /**
     * Load the user information and populate the component attribute.
     * @param {Component} component
     */
    getUserInfo: function(component) {
        var action = component.get("c.getUserInfo");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var user = response.getReturnValue();
                component.set('v.userInfo', user);
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * Load the settings in order to get the org specific header image static resource name.
     *
     * @param {Component} component
     */
    getSironoSettings: function(component) {
        var settingsService = component.find('settingsService');
        settingsService.getSettings(function(err, settings) {
            if (err) {
                //TODO: we need to figure out a general error handler
                console.log(err);
                return;
            }

            if (settings.headerImageName && settings.headerImageName !== '') {
                component.set('v.headerLogoUrl', $A.get('$Resource.' + settings.headerImageName ));
            } else {
                component.set('v.headerLogoUrl', $A.get('$Resource.SironoData') + '/assets/images/health-system-logo.png');
            }
            // Remove the hide class so that the logo will show up in the UI. It is initially hidden to avoid shouding the
            // alt message initially.
            $A.util.removeClass(component.find('headerLogo'), 'slds-hide');
        });
    }
})