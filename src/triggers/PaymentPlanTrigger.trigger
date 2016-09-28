/* 
* @author   Sirono
* @version  1.0.1
* @date     06-06-2016
*/
trigger PaymentPlanTrigger on test__c (before insert, after insert, before update, after update ) {
    //invoked before an insert event 
    if (trigger.isBefore && trigger.isInsert) {
        PaymentPlanTriggerHandler.beforeInsert(trigger.new);
    }
    //invoked before an update event 
    if (trigger.isBefore && trigger.isUpdate) {
        PaymentPlanTriggerHandler.beforeUpdate(trigger.new, trigger.oldMap);
    }
    //invoked after an insert event 
    if (trigger.isAfter && trigger.isInsert) {
        PaymentPlanTriggerHandler.afterInsert(trigger.new);
    }
    //invoked after an update event 
    if (trigger.isAfter && trigger.isUpdate) {
        PaymentPlanTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
    }
}