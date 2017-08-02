/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    /**
     * @param {Component} component
     * @param {Event} event
     * @param helper
     */
    doInit: function(component, event, helper) {
        helper.loginAsPortalUser(component);
    }
});