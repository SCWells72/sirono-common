/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Used when Contact is created or updated.  
 */
trigger ContactTrigger on Contact (after insert, after update) {

    //invoked after an insert event
    if (Trigger.isAfter && Trigger.isInsert) {
        ContactTriggerHandler.afterInsert(Trigger.new);
    }

    //invoked after an update event
    if (Trigger.isAfter && Trigger.isUpdate) {
        ContactTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }
}