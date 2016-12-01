/*
* @author  Sirono
* @version 1.0.1
* @date    05-30-2016 
* @description trigger on CampaignMember that gets invoked after insert or after update event
*/
trigger CampaignMemberTrigger on CampaignMember (after insert, after delete) {
	CampaignMemberTriggerHandler obj = new CampaignMemberTriggerHandler();
/*
    if (CaseUtil.executeCampaignMemberTrigger == false) return;

    //invoked after insert event 
    if (Trigger.isAfter && Trigger.isInsert) {
        CampaignMemberTriggerHandler.afterInsert(Trigger.new);
    }

    //invoked after delete event
    if (Trigger.isAfter && Trigger.isDelete) {
        CampaignMemberTriggerHandler.afterDelete(Trigger.old);
    }*/
}