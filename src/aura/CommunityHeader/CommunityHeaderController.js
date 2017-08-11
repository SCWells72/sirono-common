/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    /**
     * Handler for the show Settings button.
     *
     * @param {Component} component
     * @param {Event} event
     * @param helper
     */
    showSettings: function (component, event, helper) {
        var mySettings = component.find('sldsjsPopoverAction');
        $A.util.toggleClass(mySettings, 'slds-hide');
    },

    /**
     * Handler for the help button.
     *
     * @param {Component} component
     * @param {Event} event
     * @param helper
     */
    showHelp: function (component, event, helper) {
        var mySettings = component.find('sldsjsPopoverActionHelp');
        $A.util.toggleClass(mySettings, 'slds-hide');
    },

    /**
     * Initialization function.
     *
     * @param {Component} component
     * @param {Event} event
     * @param helper
     */
    doInit: function (component, event, helper) {
        helper.getUserInfo(component);
        helper.getSironoSettings(component);
    }
})