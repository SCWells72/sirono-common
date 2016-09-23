trigger ChargeGroupTrigger on Charge_Group__c (after insert, after update, after delete, after undelete) {
    if (trigger.isAfter && trigger.isInsert) {
        ChargeGroupTriggerHandler.afterInsert(trigger.new);
    }
    if (trigger.isAfter && trigger.isUpdate) {
        ChargeGroupTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
    }

    if (trigger.isAfter && trigger.isDelete) {
        ChargeGroupTriggerHandler.afterDelete(trigger.old);
    }

    if (trigger.isAfter && trigger.isUndelete) {
        ChargeGroupTriggerHandler.afterInsert(trigger.new);
    }
}