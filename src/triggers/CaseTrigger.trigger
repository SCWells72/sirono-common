/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * CaseTrigger is used when Case is created or updated.
 **/
trigger CaseTrigger on Case (before insert, after insert, after update) {

    // executes after Insert operation
    if (Trigger.isAfter && Trigger.isInsert) {
        CaseTriggerHandler.afterInsert(Trigger.new);
    }

    // executes after Update operation
    if (Trigger.isAfter && Trigger.isUpdate) {
        CaseTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }
}