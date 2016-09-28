/*
 * @author      Sirono
 * @version     1.0.1
 * @date        5-25-2016
 * @description trigger on Charge_Group__c invoked after insert,update,delete or undelete events 
*/

trigger ChargeGroupTrigger on Charge_Group__c (after insert, after update, after delete, after undelete) {

    //executes after insert operation
    if (trigger.isAfter && trigger.isInsert) {
        ChargeGroupTriggerHandler.afterInsert(trigger.new);
    }

    //executes after insert operation
    if (trigger.isAfter && trigger.isUpdate) {
        ChargeGroupTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
    }

    //executes after delete operation
    if (trigger.isAfter && trigger.isDelete) {
        ChargeGroupTriggerHandler.afterDelete(trigger.old);
    }

    //executes after undelete operation
    if (trigger.isAfter && trigger.isUndelete) {
        ChargeGroupTriggerHandler.afterInsert(trigger.new);
    }
}