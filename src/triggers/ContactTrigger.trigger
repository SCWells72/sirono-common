trigger ContactTrigger on Contact (after insert, after update) {
	if(trigger.isAfter && trigger.isInsert){
		ContactTriggerHandler.afterInsert(trigger.new);
	}
	if(trigger.isAfter && trigger.isUpdate){
		ContactTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
	}
}