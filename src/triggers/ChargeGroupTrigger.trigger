/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Trigger on Charge_Group__c invoked after insert,update,delete or undelete events 
 */
trigger ChargeGroupTrigger on Charge_Group__c (after insert, after update, after delete, after undelete) {

    //executes after insert operation
    if (Trigger.isAfter && Trigger.isInsert) {
        ChargeGroupTriggerHandler.afterInsert(Trigger.new);
    }

    //executes after insert operation
    if (Trigger.isAfter && Trigger.isUpdate) {
        ChargeGroupTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }

    //executes after delete operation
    if (Trigger.isAfter && Trigger.isDelete) {
        ChargeGroupTriggerHandler.afterDelete(Trigger.old);
    }

    //executes after undelete operation
    if (Trigger.isAfter && Trigger.isUndelete) {
        ChargeGroupTriggerHandler.afterInsert(Trigger.new);
    }
}