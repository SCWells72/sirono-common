/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    /**
     * Go set the settings for the application.
     *
     * @param {Component} component
     * @param {Function} callback - The callback function for return the result from the server.
     */
    getSettings: function (component, callback) {
        var action = component.get('c.getSironoSettings');

        action.setCallback(this,
            /**
             * @param {Action} response
             **/
            function (response) {

                if (response.getState() === 'SUCCESS') {
                    var settings = response.getReturnValue();
                    callback(null, settings);
                    return;
                } else if (response.getState() === 'ERROR') {
                    callback(response.getError());
                }

            });
        $A.enqueueAction(action);
    }
})