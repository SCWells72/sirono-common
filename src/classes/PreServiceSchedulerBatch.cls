/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class PreServiceSchedulerBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    public Campaign callList;
    public Set<Id> existingMembers;

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new PreServiceSchedulerBatch(), 200);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        //Sirono : 08-30-2016 - #128375287 Update Salesforce Campaign Names
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String> {
            Constants.CAMPAIGN_NAME_PRESERVICE
        });
        string preService = mapCampaignMapping.get(Constants.CAMPAIGN_NAME_PRESERVICE);

        if (CampaignSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            for (Campaign cl: [
                SELECT Id, Name
                FROM Campaign
                WHERE Name = :preService AND isActive = true
            ]) {
                callList = cl;
            }
        }

        if (callList != null) {
            existingMembers = new Set<Id>();
            if (CmpnMemberSecurityContext.SELECT_CONTEXT.actionAllowed()) {
                for (CampaignMember cm: [
                    SELECT Id, ContactId
                    FROM CampaignMember
                    WHERE CampaignId = :callList.Id AND ContactId != null
                ]) {
                    existingMembers.add(cm.ContactId);
                }
            }
            return Database.getQueryLocator(GuarantorService.getBatchContactsQuery());
        } else {
            return Database.getQueryLocator(GuarantorService.getNoContactsQuery());
        }
        return null;
    }

    //adding new campaign members
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<Contact> guarantors = (List<Contact>) scope;
        Date dt14 = System.today().addDays(14);
        Date dt = System.today();
        if (callList != null) {
            List<CampaignMember> memberList = new List<CampaignMember>();
            if (EncounterSecurityContext.PSS_SELECT_CONTEXT.actionAllowed()) {
                for (Encounter__c ps: [
                    SELECT Id, Name, Guarantor__c, Liability__c, Date_of_Service__c
                    FROM Encounter__c
                    WHERE Patient__r.Guarantor__c IN :guarantors
                    AND Date_of_Service__c > :dt AND Date_of_Service__c <= :dt14
                    AND Liability__c > :100 AND Cancelled__c = false
                ]) {
                    /*if(!existingMembers.contains(ps.Patient__r.Guarantor__c)){
                        existingMembers.add(ps.Patient__r.Guarantor__c);
                        memberList.add(new CampaignMember(CampaignId = callList.Id, ContactId = ps.Patient__r.Guarantor__c, Status = Constants.SENT));
                   }*/
                    System.debug('ps' + ps);
                    System.debug('existingMembers' + existingMembers);

                    if (!existingMembers.contains(ps.Guarantor__c)) {
                        existingMembers.add(ps.Guarantor__c);
                        memberList.add(new CampaignMember(
                            CampaignId = callList.Id,
                            ContactId = ps.Guarantor__c,
                            Status = Constants.SENT
                        ));
                    }
                }
            }

            if (memberList.size() > 0) {
                if (CmpnMemberSecurityContext.SB_CREATE_CONTEXT.actionAllowed()) {
                    INSERT memberList;
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc) {

    }
}