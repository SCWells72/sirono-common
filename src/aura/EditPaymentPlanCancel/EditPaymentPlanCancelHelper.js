/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    showPopup: function (cmp, componentId, className) {
        var modal = cmp.find(componentId);
        $A.util.removeClass(modal, className + 'hide');
        $A.util.addClass(modal, className + 'open');
    },
    hidePopup: function (cmp, componentId, className) {
        var modal = cmp.find(componentId);
        $A.util.addClass(modal, className + 'hide');
        $A.util.removeClass(modal, className + 'open');
    },
    showError: function (cmp, message) {
        cmp.set('v.hasError', true);
        cmp.find('notificationCmp').showError(message);
    }
})