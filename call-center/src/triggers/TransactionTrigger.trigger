
/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

trigger TransactionTrigger on Transaction__c (after insert, after update, after delete, after undelete) {
    //executes after insert operation
    if (Trigger.isAfter && Trigger.isInsert) {
        TransactionTriggerHandler.afterInsert(Trigger.new);
    }

    //executes after insert operation
    if (Trigger.isAfter && Trigger.isUpdate) {
        TransactionTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }

    //executes after delete operation
    if (Trigger.isAfter && Trigger.isDelete) {
        TransactionTriggerHandler.afterDelete(Trigger.old);
    }

    //executes after undelete operation
    if (Trigger.isAfter && Trigger.isUndelete) {
        TransactionTriggerHandler.afterInsert(Trigger.new);
    }
}