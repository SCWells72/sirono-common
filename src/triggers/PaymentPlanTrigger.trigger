/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

trigger PaymentPlanTrigger on Payment_Plan__c (before insert, after insert, before update, after update ) {
    //invoked before an insert event 
    if (Trigger.isBefore && Trigger.isInsert) {
        PaymentPlanTriggerHandler.beforeInsert(Trigger.new);
    }
    //invoked before an update event 
    if (Trigger.isBefore && Trigger.isUpdate) {
        PaymentPlanTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
    }
    //invoked after an insert event 
    if (Trigger.isAfter && Trigger.isInsert) {
        PaymentPlanTriggerHandler.afterInsert(Trigger.new);
    }
    //invoked after an update event 
    if (Trigger.isAfter && Trigger.isUpdate) {
        PaymentPlanTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }
}