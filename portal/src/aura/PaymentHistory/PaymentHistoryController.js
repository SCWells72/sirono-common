/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    doInit: function (component, event, helper) {
        helper.getPayments(component);
    },
    updateSorting: function (component, event, helper) {
        var arrowUse = event.currentTarget.querySelector('svg').querySelector("use");
        var orderType = '';
        var arrowPath = arrowUse.getAttribute('href');
        if (arrowPath.includes('arrowdown')) {
            orderType = 'ASC';
            arrowPath = arrowPath.replace('arrowdown', 'arrowup');
        } else {
            orderType = 'DESC';
            arrowPath = arrowPath.replace('arrowup', 'arrowdown');
        }
        arrowUse.setAttribute('href', arrowPath);
        var orderCriteria = event.currentTarget.dataset.orderType;
        helper.updateSorting(component, orderCriteria, orderType);
        this.superRerender();
    }
})