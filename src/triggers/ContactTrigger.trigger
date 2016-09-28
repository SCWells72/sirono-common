/*
* @author Sirono
* @version 1.0.1
* @date: 06-06-2016
* @ContactTrigger used when contact is created or updated.  
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