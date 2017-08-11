/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    /**
     * Handler for the getSettings Aura method.
     *
     * @param {Component} component
     * @param {Event} event
     * @param helper
     */
    getSettings: function (component, event, helper) {
        var params = event.getParam('arguments'),
            cb = params.callback;

        helper.getSettings(component, cb);
    }
})