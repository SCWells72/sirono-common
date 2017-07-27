/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    doError: function (cmp, e) {
        if (!cmp.isValid()) {
            return;
        }
        var params = e.getParam('arguments');
        if (!params) {
            return;
        }

        console.error(params.message);
        cmp.set('v.show', true);
        cmp.set('v.title', 'Error');
        cmp.set('v.severity', 'error');
        cmp.set('v.message', params.message);
    }
})