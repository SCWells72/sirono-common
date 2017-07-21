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
        Set<Id> membersToRemove = new Set<Id>();
        for (Contact c: GuarantorService.getGuarantorsWithCG(contactIds)) {
            Decimal balToCheck = 0;
            if (c.Overdue_Balance__c != null) balToCheck += c.Overdue_Balance__c;
            if (c.Delinquent_Balance__c != null) balToCheck += c.Delinquent_Balance__c;

            if (c.Charge_Groups__r.size() == 0
                    || balToCheck > -100 || balToCheck < -5000) {
                membersToRemove.add(c.Id);
            }
        }

        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                Constants.CAMPAIGN_NAME_PRECOLLECTIONS
        });
        String campaignName = mapCampaignMapping.get(Constants.CAMPAIGN_NAME_PRECOLLECTIONS);

        removeFromCampaign(campaignName, membersToRemove);
    }

    //Remove the Campaign Members for the Early Out case.
    public static void earlyOutCallListRemoval(List<Contact> contacts) {
        Set<Id> membersToRemove = new Set<Id>();
        for (Contact c : contacts) {
            Decimal balToCheck = 0;
            if (c.Overdue_Balance__c != null) balToCheck += c.Overdue_Balance__c;
            if (c.Delinquent_Balance__c != null) balToCheck += c.Delinquent_Balance__c;

            if (balToCheck == 0
                    || balToCheck > -100 || balToCheck < -5000) {
                membersToRemove.add(c.Id);
            }
        }

        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                Constants.CAMPAIGN_NAME_OVERDUE
        });
        String campaignName = mapCampaignMapping.get(Constants.CAMPAIGN_NAME_OVERDUE);

        removeFromCampaign(campaignName, membersToRemove);
    }

    public static void delinquentPaymentPlanCallListRemoval(Set<Id> contactIds) {
        Set<Id> membersToRemove = new Set<Id>();
        for (Contact c: GuarantorService.getGuarantorsWithPmtPlan(contactIds)) {
            if (c.Payment_Plans__r.isEmpty()) {
                membersToRemove.add(c.Id);
            }
        }

        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                Constants.CAMPAIGN_NAME_PAST_DUE
        });

        String campaignName = mapCampaignMapping.get(Constants.CAMPAIGN_NAME_PAST_DUE);

        removeFromCampaign(campaignName, membersToRemove);
    }

    //Remove the Campaign Members for the Pre-Service case.
    public static void preServiceCallListRemoval(Set<Id> contactIds) {
        Set<Id> membersToRemove = new Set<Id>();
        for (Contact c: GuarantorService.getGuarantorsWithEncounters(contactIds)) {
            if (c.Encounters__r.size() == 0) {
                membersToRemove.add(c.Id);
            }
        }

        //Sirono : 08-30-2016 - #128375287 Update Salesforce Campaign Names
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                Constants.CAMPAIGN_NAME_PRESERVICE
        });
        String campaignName = mapCampaignMapping.get(Constants.CAMPAIGN_NAME_PRESERVICE);

        removeFromCampaign(campaignName, membersToRemove);
    }

    private static void removeFromCampaign(String campaignName, Set<Id> membersToRemove) {
        if (!membersToRemove.isEmpty()) {
            CampaignMemberDao.ElevatedPrivilegesHelper helper = new CampaignMemberDao.ElevatedPrivilegesHelper();
            helper.removeFromCampaign(campaignName, membersToRemove);
        }
    }
}