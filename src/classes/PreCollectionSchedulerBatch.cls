/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class PreCollectionSchedulerBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    public Campaign callList;
    public Set<Id> existingMembers;

    public void execute(SchedulableContext bc) {
        Database.executeBatch(new PreCollectionSchedulerBatch(), 200);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        //Sirono : 08-30-2016 - #128375287 Update Salesforce Campaign Names
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String> {
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS
        });
        String preCollection = mapCampaignMapping.get(Constants.CAMPAIGN_NAME_PRECOLLECTIONS);

        if (CampaignSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            for (Campaign cl: [SELECT Id, Name FROM Campaign WHERE Name = :preCollection AND isActive = true]) {
                callList = cl;
            }
        }

        if (callList != null) {
            existingMembers = new Set<Id>();
            if (CmpnMemberSecurityContext.SELECT_CONTEXT.actionAllowed()) {
                for (CampaignMember cm: [SELECT Id, ContactId FROM CampaignMember WHERE CampaignId = :callList.Id AND ContactId != null]) {
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
        Date dt = System.today();
        if (callList != null) {
            List<CampaignMember> memberList = new List<CampaignMember>();
            for (Charge_Group__c cg: ChargeGroupService.getCGBasedOnGuarantorAndPreCollDate(guarantors, dt)) {
                Double bal = cg.Guarantor__r.Overdue_Balance__c + cg.Guarantor__r.Delinquent_Balance__c;
                System.debug('bal' + bal);
                if (bal <= -100 && bal > -5000 && !existingMembers.contains(cg.Guarantor__c)) {
                    existingMembers.add(cg.Guarantor__c);
                    memberList.add(new CampaignMember(
                        CampaignId = callList.Id,
                        ContactId = cg.Guarantor__c,
                        Status = Constants.SENT
                    ));
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