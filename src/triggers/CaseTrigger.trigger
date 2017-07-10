/**
 * CaseTrigger is use when Case is created or updated.
 **/

trigger CaseTrigger on Case (before insert, after insert, after update) {

    // executes before Insert operation
    if (Trigger.isBefore && Trigger.isInsert) {
        CaseTriggerHandler.beforeInsert(Trigger.new);
    }

    // executes after Insert operation
    if (Trigger.isAfter && Trigger.isInsert) {
        CaseTriggerHandler.afterInsert(Trigger.new);
    }

    // executes after Update operation
    if (Trigger.isAfter && Trigger.isUpdate) {
        CaseTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }
}