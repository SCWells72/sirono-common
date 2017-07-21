/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Used when Task is created or updated.  
 */
trigger TaskTrigger on Task (after insert, before insert, after update,before update) {
    
    //trigger invoked after an insert event 
    if (Trigger.isAfter && Trigger.isInsert) {
        TaskTriggerHandler.afterInsert(Trigger.new);
    }

    //trigger invoked before an insert event 
    if (Trigger.isBefore && Trigger.isInsert) {
        TaskTriggerHandler.beforeInsert(Trigger.new);        
    }
    
    //trigger invoked after an update event
    if (Trigger.isAfter && Trigger.isUpdate) {
        TaskTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }

    //trigger invoked after an update event
    if (Trigger.isBefore && Trigger.isUpdate) {
        TaskTriggerHandler.beforeUpdate(Trigger.new);
    }


}