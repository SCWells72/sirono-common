/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Used when Contact is created or updated.  
 */
trigger ContactTrigger on Contact (after insert, after update) {

    //invoked after an insert event
    if (trigger.isAfter && trigger.isInsert) {
        ContactTriggerHandler.afterInsert(trigger.new);
    }

    //invoked after an update event
    if (trigger.isAfter && trigger.isUpdate) {
        ContactTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
    }
}