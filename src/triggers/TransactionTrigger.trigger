
/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

trigger TransactionTrigger on Transaction__c (after insert, after update, after delete, after undelete) {
    //executes after insert operation
    if (trigger.isAfter && trigger.isInsert) {
        TransactionTriggerHandler.afterInsert(trigger.new);
    }

    //executes after insert operation
    if (trigger.isAfter && trigger.isUpdate) {
        TransactionTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
    }

    //executes after delete operation
    if (trigger.isAfter && trigger.isDelete) {
        TransactionTriggerHandler.afterDelete(trigger.old);
    }

    //executes after undelete operation
    if (trigger.isAfter && trigger.isUndelete) {
        TransactionTriggerHandler.afterInsert(trigger.new);
    }
}