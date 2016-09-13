trigger CaseCommentTrigger on CaseComment (after insert) {
	if(Trigger.isAfter && Trigger.isInsert){
		CaseCommentTriggerHandler.afterInsert(Trigger.new);
	}
}