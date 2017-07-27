/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

trigger PaymentTrigger on Payment__c (after insert, after update, after delete, after undelete) {
    //executes after insert operation
    if (Trigger.isAfter && Trigger.isInsert) {
        PaymentTriggerHandler.afterInsert(Trigger.new);
    }

    //executes after update operation
    if (Trigger.isAfter && Trigger.isUpdate) {
        PaymentTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }

    //executes after delete operation
    if (Trigger.isAfter && Trigger.isDelete) {
        PaymentTriggerHandler.afterDelete(Trigger.old);
    }

    //executes after undelete operation
    if (Trigger.isAfter && Trigger.isUndelete) {
        PaymentTriggerHandler.afterInsert(Trigger.new);
    }
}