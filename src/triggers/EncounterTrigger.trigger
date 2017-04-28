/* 
* @author  Sirono 
* @version 1.0.1
* @date    06-06-2016
*/
trigger EncounterTrigger on Encounter__c (after insert, after update, after delete, after undelete) {
    //trigger invoked after an insert event
    if (trigger.isAfter && trigger.isInsert) {
        EncounterTriggerHandler.afterInsert(trigger.new);
    }

    //trigger invoked after an update event
    if (trigger.isAfter && trigger.isUpdate) {
        EncounterTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
    }

    //trigger invoked after a delete event
    if (trigger.isAfter && trigger.isDelete) {
        EncounterTriggerHandler.afterDelete(trigger.old);
    }

    //trigger invoked after an undelete event
    if (trigger.isAfter && trigger.isUndelete) {
        EncounterTriggerHandler.afterInsert(trigger.new);
    }
}