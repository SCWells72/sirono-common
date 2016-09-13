trigger PaymentPlanTrigger on test__c (after insert, after update) {
	if(trigger.isAfter && trigger.isInsert){
		PaymentPlanTriggerHandler.afterInsert(trigger.new);
	}
	if(trigger.isAfter && trigger.isUpdate){
		PaymentPlanTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
	}
}