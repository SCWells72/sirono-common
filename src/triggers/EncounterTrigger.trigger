/* 
* @author  Sirono 
* @version 1.0.1
* @date    06-06-2016
*/
trigger EncounterTrigger on Encounter__c (after insert, after update) {
    //trigger invoked after an insert event
    if (trigger.isAfter && trigger.isInsert) {
        EncounterTriggerHandler.afterInsert(trigger.new);
    }
    //trigger invoked before an update event
    if (trigger.isBefore && trigger.isUpdate) {
        EncounterTriggerHandler.beforeUpdate(trigger.new, trigger.oldMap);
    }
    //trigger invoked after an update event
    if (trigger.isAfter && trigger.isUpdate) {
        EncounterTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
    }
}