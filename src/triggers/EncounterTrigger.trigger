trigger EncounterTrigger on Encounter__c (before insert, after insert, before update, after update) {
	if(trigger.isBefore && trigger.isInsert){
		EncounterTriggerHandler.beforeInsert(trigger.new);
	}
	if(trigger.isAfter && trigger.isInsert){
		EncounterTriggerHandler.afterInsert(trigger.new);
	}
	if(trigger.isBefore && trigger.isUpdate){
		EncounterTriggerHandler.beforeUpdate(trigger.new, trigger.oldMap);
	}
	if(trigger.isAfter && trigger.isUpdate){
		EncounterTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
	}
}