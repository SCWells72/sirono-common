trigger PaymentTrigger on Payment__c (after insert, after update, after delete, after undelete) {
    //executes after insert operation
    if (trigger.isAfter && trigger.isInsert) {
        PaymentTriggerHandler.afterInsert(trigger.new);
    }

    //executes after update operation
    if (trigger.isAfter && trigger.isUpdate) {
        PaymentTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
    }

    //executes after delete operation
    if (trigger.isAfter && trigger.isDelete) {
        PaymentTriggerHandler.afterDelete(trigger.old);
    }

    //executes after undelete operation
    if (trigger.isAfter && trigger.isUndelete) {
        PaymentTriggerHandler.afterInsert(trigger.new);
    }
}