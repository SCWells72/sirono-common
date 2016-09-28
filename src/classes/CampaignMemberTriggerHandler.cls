/* @author: Sirono
 * @Date: 05-30-2016
 * @Description TriggerHandler class for CampaignMemberTrigger
*/

public with sharing class CampaignMemberTriggerHandler {
    //static method that creates CampaignHistoryObject
    public static void afterInsert(List<CampaignMember> newList) {
        createCampaignHistoryObject(newList);
    }
    //static method that updates CampaignHistoryObject
    public static void afterDelete(List<CampaignMember> oldList) {
        updateCampaignHistoryObject(oldList);
    }
    // private static method inserts Campaignmemberhistory list and Case list
    private static void createCampaignHistoryObject(List<CampaignMember> newList) {
        Id callListCaseRtId = null;
        for (RecordType rt : [
                Select Id, Name
                From RecordType
                Where sObjectType = 'Case'
                AND Name = 'Call List Case'
        ]) {
            callListCaseRtId = rt.Id;
        }
        List<Campaign_Member_History__c> historyList = new List<Campaign_Member_History__c>();
        List<Case> caseList = new List<Case>();
        List<CampaignMember> newCMList = [
                Select Id, CampaignId, Campaign.Name, ContactId,
                        Contact.FirstName, Contact.LastName
                From CampaignMember
                WHERE Id = :newList AND ContactId != null
        ];
        for (CampaignMember cm : newCMList) {
            if (cm.ContactId != null) {
                historyList.add(new Campaign_Member_History__c(Campaign__c = cm.CampaignId, Contact__c = cm.ContactId));
                caseList.add(new Case(RecordTypeId = callListCaseRtId,
                        ContactId = cm.ContactId,
                        Origin = 'Web',
                        Status = 'New',
                        Type = cm.Campaign.Name,
                        Subject = 'Guarantor - ' + cm.Contact.FirstName + ' ' + cm.Contact.LastName
                                + ' added to ' + cm.Campaign.Name + ' Campaign'));
            }
        }
        if (historyList.size() > 0) {
            insert historyList;
        }
        if (caseList.size() > 0) {
            insert caseList;
        }
    }
    //private static method
    private static void updateCampaignHistoryObject(List<CampaignMember> oldList) {
        Set<Id> contactIds = new Set<Id>();
        Set<Id> campaignIds = new Set<Id>();
        for (CampaignMember cm : oldList) {
            if (cm.ContactId != null) {
                contactIds.add(cm.ContactId);
                campaignIds.add(cm.CampaignId);
            }
        }

        Map<String, Campaign_Member_History__c> historyMap = new Map<String, Campaign_Member_History__c>();
        for (Campaign_Member_History__c cmh : [
                Select Id, Name, Contact__c, Campaign__c,
                        Date_Removed__c, CreatedDate
                From Campaign_Member_History__c
                WHERE (Contact__c IN :contactIds OR Campaign__c IN :campaignIds)
                AND Date_Removed__c = null
                ORDER BY Contact__c, Campaign__c, CreatedDate
        ]) {

            String keyStr = String.valueOf(cmh.Contact__c).substring(0, 15) + '-' + String.valueOf(cmh.Campaign__c).substring(0, 15);
            historyMap.put(keyStr, cmh);
        }

        List<Campaign_Member_History__c> historyListToUpdate = new List<Campaign_Member_History__c>();
        for (CampaignMember cm : oldList) {
            String keyStr = String.valueOf(cm.ContactId).substring(0, 15) + '-' + String.valueOf(cm.CampaignId).substring(0, 15);
            if (historyMap.containsKey(keyStr)) {
                Campaign_Member_History__c cmh = historyMap.get(keyStr);
                cmh.Date_Removed__c = System.today();
                historyListToUpdate.add(cmh);
            }
        }
        if (historyListToUpdate.size() > 0) {
            update historyListToUpdate;
        }
    }
}