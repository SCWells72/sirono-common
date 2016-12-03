/*
* @author Sirono
* @version 1.0.1
* @date: 06-06-2016
* @TaskTrigger used when task is created or updated.  
*/

trigger TaskTrigger on Task (after insert, after update, before update) {

    //trigger invoked after an insert event 
    if (Trigger.isAfter && Trigger.isInsert) {
        TaskTriggerHandler.afterInsert(Trigger.new);
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