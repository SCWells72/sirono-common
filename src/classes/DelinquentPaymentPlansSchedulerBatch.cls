/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class DelinquentPaymentPlansSchedulerBatch
    implements Database.Batchable<SObject>, Schedulable, Database.Stateful {
    public Campaign callList;
    public Set<Id> existingMembers;

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new DelinquentPaymentPlansSchedulerBatch(), 200);
    }

    public Database.QueryLocator start(Database.BatchableContext sc) {
        //Sirono : 08-30-2016 - #128375287 Update Salesforce Campaign Names
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String> {
            Constants.CAMPAIGN_NAME_PAST_DUE
        });
        String delinquent = mapCampaignMapping.get(Constants.CAMPAIGN_NAME_PAST_DUE);

        if (CampaignSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            for (Campaign cl : [
                SELECT Id, Name
                FROM Campaign
                WHERE Name = :delinquent
                AND IsActive = TRUE
            ]) {
                callList = cl;
            }
        }

        if (callList != null) {
            existingMembers = new Set<Id>();
            if (CmpnMemberSecurityContext.SELECT_CONTEXT.actionAllowed()) {
                for (CampaignMember cm : [
                    SELECT Id, ContactId
                    FROM CampaignMember
                    WHERE CampaignId = :callList.Id AND ContactId != NULL
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
    //Checks if the members exist if not Creates new Campaign members
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Contact> guarantors = (List<Contact>) scope;
        Date dt = System.today().addDays(-10);
        if (callList != null) {
            List<CampaignMember> memberList = new List<CampaignMember>();
            if (PaymentPlanSecurityContext.DPPSB_SELECT_CONTEXT.actionAllowed() &&
                CmpnMemberSecurityContext.SB_CREATE_CONTEXT.actionAllowed()) {
                for (Payment_Plan__c pp : [
                    SELECT Id, Name, Guarantor__c, Delinquent_Date__c, Remaining_Balance__c, Active__c
                    FROM Payment_Plan__c
                    WHERE Guarantor__c IN :guarantors
                    AND Delinquent_Date__c = :dt
                    AND Remaining_Balance__c < :-100
                    AND Active__c = TRUE
                ]) {
                    if (!existingMembers.contains(pp.Guarantor__c)) {
                        existingMembers.add(pp.Guarantor__c);
                        memberList.add(new CampaignMember(
                            CampaignId = callList.Id,
                            ContactId = pp.Guarantor__c,
                            Status = Constants.SENT
                        ));
                    }
                }

                if (memberList.size() > 0) {
                    insert memberList;
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc) {

    }
}