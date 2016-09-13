trigger TaskTrigger on Task (after insert, after update) {
	if(Trigger.isAfter && Trigger.isInsert){
		TaskTriggerHandler.afterInsert(Trigger.new);		
	}
	if(Trigger.isAfter && Trigger.isUpdate){
		TaskTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);		
	}
}