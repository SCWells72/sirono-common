public with sharing class CallListUtilities {

    public static void PreCollectionCallListRemoval(Set<Id> contactIds) {
        Set<Id> membersToremove = new Set<Id>();
        for (Contact c : [
                Select Id, Overdue_Balance__c, Delinquent_Balance__c, (Select Id, Pre_Collection_Sent__c From Charge_Groups__r Where Pre_Collection_Sent__c != null)
                From Contact
                Where Id IN :contactIds
        ]) {
            Decimal balToCheck = 0;
            if (c.Overdue_Balance__c != null) balToCheck += c.Overdue_Balance__c;
            if (c.Delinquent_Balance__c != null) balToCheck += c.Delinquent_Balance__c;

            if (c.Charge_Groups__r.size() == 0
                    || balToCheck > -100 || balToCheck < -5000) {
                membersToremove.add(c.Id);
            }
        }

        List<CampaignMember> cmListToRemove = new List<CampaignMember>([
                Select Id, ContactId, CampaignId
                From CampaignMember
                Where ContactId = :membersToremove AND Campaign.Name = 'Pre-collections'
        ]);
        if (cmListToRemove.size() > 0) {
            delete cmListToRemove;
        }
    }

    public static void EarlyOutCallListRemoval(List<Contact> contacts) {
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

        List<CampaignMember> cmListToRemove = new List<CampaignMember>([
                Select Id, ContactId, CampaignId
                From CampaignMember
                Where ContactId = :membersToremove AND Campaign.Name = 'Early Out'
        ]);
        if (cmListToRemove.size() > 0) {
            delete cmListToRemove;
        }
    }

    public static void DelinquentPaymentPlanCallListRemoval(Set<Id> contactIds) {
        Set<Id> membersToremove = new Set<Id>();
        for (Contact c : [
                Select Id, (
                        Select Id, Delinquent_Date__c, Active__c
                        From Payment_Plans__r
                        WHERE Delinquent_Date__c != null OR Active__c = true
                )
                From Contact
                Where Id IN :contactIds
        ]) {
            if (c.Payment_Plans__r.size() == 0) {
                membersToremove.add(c.Id);
            }
        }

        List<CampaignMember> cmListToRemove = new List<CampaignMember>([
                Select Id, ContactId, CampaignId
                From CampaignMember
                Where ContactId = :membersToremove AND Campaign.Name = 'Delinquent Payment Plans'
        ]);
        if (cmListToRemove.size() > 0) {
            delete cmListToRemove;
        }
    }

    public static void PreServiceCallListRemoval(Set<Id> contactIds) {
        Set<Id> membersToremove = new Set<Id>();
        for (Contact c : [
                Select Id, (
                        Select Id, Date_of_Service__c, Liability__c, Cancelled__c
                        From Encounters__r
                        WHERE Liability__c < 100 OR Date_of_Service__c != Today OR Cancelled__c = false
                )
                From Contact
                Where Id IN :contactIds
        ]) {
            if (c.Encounters__r.size() == 0) {
                membersToremove.add(c.Id);
            }
        }

        List<CampaignMember> cmListToRemove = new List<CampaignMember>([
                Select Id, ContactId, CampaignId
                From CampaignMember
                Where ContactId = :membersToremove AND Campaign.Name = 'Pre-service'
        ]);
        if (cmListToRemove.size() > 0) {
            delete cmListToRemove;
        }
    }
}