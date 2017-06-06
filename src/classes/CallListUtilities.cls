/**
 * Call List utilities.
 *
 * There are Security Context Select and Delete exceptions in this class primarilly around Campaign Members.
 * The methods here are use in trigger handlers that can be fired due to portal users executing actions on payment
 * plans (Pay/create/delete/etc).  The SecurityContext check were removed b/c it is an intentional action that any user
 * should be able update the associated object when interacting with PaymentPlans from the portal.
 */

public with sharing class CallListUtilities {

    //Remove the Campaign Members for the pre collection
    public static void preCollectionCallListRemoval(Set<Id> contactIds) {
        Set<Id> membersToremove = new Set<Id>();
        for (Contact c: GuarantorService.getGuarantorsWithCG(contactIds)) {
            Decimal balToCheck = 0;
            if (c.Overdue_Balance__c != null) balToCheck += c.Overdue_Balance__c;
            if (c.Delinquent_Balance__c != null) balToCheck += c.Delinquent_Balance__c;

            if (c.Charge_Groups__r.size() == 0
                    || balToCheck > -100 || balToCheck < -5000) {
                membersToremove.add(c.Id);
            }
        }

        //Sirono : 08-30-2016 - #128375287 Update Salesforce Campaign Names
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'PreCollections'
        });
        string preCollection = mapCampaignMapping.get('PreCollections');

        // NOTE: The read access check for CampaignMember is skipped here in order allow Community Profile users
        // to create/delete Payment plans.
        List<CampaignMember> cmListToRemove = new List<CampaignMember>([
            SELECT Id, ContactId, CampaignId
            FROM CampaignMember
            WHERE ContactId = :membersToremove
            AND Campaign.Name = :preCollection
        ]);
        if (cmListToRemove.size() > 0) {
            // NOTE: could be triggered for portal user so removing delete check
            DELETE cmListToRemove;
        }
    }

    //Remove the Campaign Members for the Early Out case.
    public static void earlyOutCallListRemoval(List<Contact> contacts) {
        Set<Id> membersToremove = new Set<Id>();
        for (Contact c : contacts) {
            Decimal balToCheck = 0;
            if (c.Overdue_Balance__c != null) balToCheck += c.Overdue_Balance__c;
            if (c.Delinquent_Balance__c != null) balToCheck += c.Delinquent_Balance__c;

            if (balToCheck == 0
                    || balToCheck > -100 || balToCheck < -5000) {
                membersToremove.add(c.Id);
            }
        }

        //Sirono : 08-30-2016 - #128375287 Update Salesforce Campaign Names
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Early-out'
        });
        string earlyOut = mapCampaignMapping.get('Early-out');

        // NOTE: The read access check for CampaignMember is skipped here in order allow Community Profile users
        // to create/delete Payment plans.
        List<CampaignMember> cmListToRemove = new List<CampaignMember>([
            SELECT Id, ContactId, CampaignId
            FROM CampaignMember
            WHERE ContactId = :membersToremove
            AND Campaign.Name = :earlyOut
        ]);
        if (cmListToRemove.size() > 0) {
            // NOTE: could be triggered for portal user so removing delete check
            DELETE cmListToRemove;
        }
    }

    //Remove the Campaign Members for the Delinquent case.
    public static void delinquentPaymentPlanCallListRemoval(Set<Id> contactIds) {
        Set<Id> membersToremove = new Set<Id>();        
        for (Contact c: GuarantorService.getGuarantorsWithPmtPlan(contactIds)) {
            if (c.Payment_Plans__r.size() == 0) {
                membersToremove.add(c.Id);
            }
        }

        //Sirono : 08-30-2016 - #128375287 Update Salesforce Campaign Names
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Delinquent Payment Plans'
        });
        string delinquent = mapCampaignMapping.get('Delinquent Payment Plans');

        // NOTE: The read access check for CampaignMember is skipped here in order allow Community Profile users
        // to create/delete Payment plans.
        List<CampaignMember> cmListToRemove = new List<CampaignMember>([
            SELECT Id, ContactId, CampaignId
            FROM CampaignMember
            WHERE ContactId = :membersToremove
            AND Campaign.Name = :delinquent
        ]);
        if (cmListToRemove.size() > 0) {
            // NOTE: could be triggered for portal user so removing delete check
            DELETE cmListToRemove;
        }
    }

    //Remove the Campaign Members for the Pre-Service case.
    public static void preServiceCallListRemoval(Set<Id> contactIds) {
        Set<Id> membersToremove = new Set<Id>();
        for (Contact c: GuarantorService.getGuarantorsWithEncounters(contactIds)) {
            if (c.Encounters__r.size() == 0) {
                membersToremove.add(c.Id);
            }
        }

        //Sirono : 08-30-2016 - #128375287 Update Salesforce Campaign Names
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'PreService'
        });
        String preService = mapCampaignMapping.get('PreService');

        // NOTE: The read access check for CampaignMember is skipped here in order allow Community Profile users
        // to create/delete/pay Payment plans.
        List<CampaignMember> cmListToRemove = new List<CampaignMember>([
            SELECT Id, ContactId, CampaignId
            FROM CampaignMember
            WHERE ContactId = :membersToremove
            AND Campaign.Name = :preService
        ]);
        if (cmListToRemove.size() > 0) {
            // NOTE: could be triggered for portal user so removing delete check
            DELETE cmListToRemove;
        }
    }
}