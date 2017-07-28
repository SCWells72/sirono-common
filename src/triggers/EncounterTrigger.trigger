/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

trigger EncounterTrigger on Encounter__c (after insert, after update, after delete, after undelete) {
    //trigger invoked after an insert event
    if (Trigger.isAfter && Trigger.isInsert) {
        EncounterTriggerHandler.afterInsert(Trigger.new);
    }

    //trigger invoked after an update event
    if (Trigger.isAfter && Trigger.isUpdate) {
        EncounterTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }

    //trigger invoked after a delete event
    if (Trigger.isAfter && Trigger.isDelete) {
        EncounterTriggerHandler.afterDelete(Trigger.old);
    }

    //trigger invoked after an undelete event
    if (Trigger.isAfter && Trigger.isUndelete) {
        EncounterTriggerHandler.afterInsert(Trigger.new);
    }
}