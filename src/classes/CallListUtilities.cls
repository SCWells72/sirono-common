/*
* @author: Sirono
* @version 1.0.1
* @Date: 06-06-2016
*
* Sirono : 08-30-2016 - #128375287 Update Salesforce Campaign Names
*/


public with sharing class CallListUtilities {

    //Remove the Campaign Members for the pre collection
    public static void preCollectionCallListRemoval(Set<Id> contactIds) {
        Set<Id> membersToremove = new Set<Id>();
        if (ContactSecurityContext.CU_SELECT_CONTEXT.actionAllowed() &&
                ChargeGroupSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            for (Contact c: [
                    SELECT Id, Overdue_Balance__c, Delinquent_Balance__c, (
                            SELECT Id, Pre_Collection_Sent__c
                            FROM Charge_Groups__r
                            WHERE Pre_Collection_Sent__c != null
                    )
                    FROM Contact
                    WHERE Id IN :contactIds
            ]) {

                Decimal balToCheck = 0;
                if (c.Overdue_Balance__c != null) balToCheck += c.Overdue_Balance__c;
                if (c.Delinquent_Balance__c != null) balToCheck += c.Delinquent_Balance__c;
    
                if (c.Charge_Groups__r.size() == 0
                        || balToCheck > -100 || balToCheck < -5000) {
                    membersToremove.add(c.Id);
                }
            }
        }

        //Sirono : 08-30-2016 - #128375287 Update Salesforce Campaign Names
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'PreCollections'
        });
        string preCollection = mapCampaignMapping.get('PreCollections');

        if (CmpnMemberSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            List<CampaignMember> cmListToRemove = new List<CampaignMember>([
                SELECT Id, ContactId, CampaignId
                FROM CampaignMember
                WHERE ContactId = :membersToremove
                AND Campaign.Name = :preCollection
            ]);
            if (cmListToRemove.size() > 0) {
                DELETE cmListToRemove;
            }
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

        if (CmpnMemberSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            List<CampaignMember> cmListToRemove = new List<CampaignMember>([
                SELECT Id, ContactId, CampaignId
                FROM CampaignMember
                WHERE ContactId = :membersToremove
                AND Campaign.Name = :earlyOut
            ]);
            if (cmListToRemove.size() > 0) {
                DELETE cmListToRemove;
            }
        }
    }

    //Remove the Campaign Members for the Delinquent case.
    public static void delinquentPaymentPlanCallListRemoval(Set<Id> contactIds) {
        Set<Id> membersToremove = new Set<Id>();
        if (ContactSecurityContext.CU_SELECT_CONTEXT.actionAllowed() &&
                PaymentPlanSecurityContext.CLU_SELECT_CONTEXT.actionAllowed()) {
            for (Contact c: [
                    SELECT Id, (
                            SELECT Id, Delinquent_Date__c, Active__c
                            FROM Payment_Plans__r
                            WHERE Delinquent_Date__c != null OR Active__c = true
                    )
                    FROM Contact
                    WHERE Id IN :contactIds
            ]) {
                if (c.Payment_Plans__r.size() == 0) {
                    membersToremove.add(c.Id);
                }
            }
        }

        //Sirono : 08-30-2016 - #128375287 Update Salesforce Campaign Names
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Delinquent Payment Plans'
        });
        string delinquent = mapCampaignMapping.get('Delinquent Payment Plans');

        if (CmpnMemberSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            List<CampaignMember> cmListToRemove = new List<CampaignMember>([
                SELECT Id, ContactId, CampaignId
                FROM CampaignMember
                WHERE ContactId = :membersToremove
                AND Campaign.Name = :delinquent
            ]);
            if (cmListToRemove.size() > 0) {
                DELETE cmListToRemove;
            }
        }
    }

    //Remove the Campaign Members for the Pre-Service case.
    public static void preServiceCallListRemoval(Set<Id> contactIds) {
        Set<Id> membersToremove = new Set<Id>();
        if (ContactSecurityContext.CU_SELECT_CONTEXT.actionAllowed() &&
                EncounterSecurityContext.CLU_SELECT_CONTEXT.actionAllowed()) {
            for (Contact c: [
                    SELECT Id, (
                            SELECT Id, Date_of_Service__c, Liability__c, Cancelled__c
                            FROM Encounters__r
                            WHERE Liability__c < 100 OR Date_of_Service__c != Today OR Cancelled__c = false
                    )
                    FROM Contact
                    WHERE Id IN :contactIds
            ]) {
                if (c.Encounters__r.size() == 0) {
                    membersToremove.add(c.Id);
                }
            }
        }

        //Sirono : 08-30-2016 - #128375287 Update Salesforce Campaign Names
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'PreService'
        });
        string preService = mapCampaignMapping.get('PreService');

        if (CmpnMemberSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            List<CampaignMember> cmListToRemove = new List<CampaignMember>([
                SELECT Id, ContactId, CampaignId
                FROM CampaignMember
                WHERE ContactId = :membersToremove
                AND Campaign.Name = :preService
            ]);
            if (cmListToRemove.size() > 0) {
                DELETE cmListToRemove;
            }
        }
    }
}