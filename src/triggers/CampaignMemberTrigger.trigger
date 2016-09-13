trigger CampaignMemberTrigger on CampaignMember (after insert, after delete) {
    
    if(CaseUtil.ExecuteCampaignMemberTrigger == false) return;
    
    if(Trigger.isAfter && Trigger.isInsert){
        CampaignMemberTriggerHandler.afterInsert(Trigger.new);
    }
    if(Trigger.isAfter && Trigger.isDelete){
        CampaignMemberTriggerHandler.afterDelete(Trigger.old);
    }
}