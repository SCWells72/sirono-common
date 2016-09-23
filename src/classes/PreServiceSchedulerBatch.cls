/*
ADDITION: {Encounter}.{Estimated Patient Balance} > 100 and
{Encounter}.{Date of Service} > Today and
{Encounter}.{Date of Service} - 14 <= Today and
{Encounter}.{Cancelled} = FALSE
*/
global with sharing class PreServiceSchedulerBatch
        implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    global Campaign callList;
    global Set<Id> existingMembers;

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new PreServiceSchedulerBatch(), 200);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        for (Campaign cl : [Select Id, Name From Campaign Where Name = 'Pre-service' and isActive = true]) {
            callList = cl;
        }
        if (callList != null) {
            existingMembers = new Set<Id>();
            for (CampaignMember cm : [
                    Select Id, ContactId
                    From CampaignMember
                    Where CampaignId = :callList.Id AND ContactId != null
            ]) {
                existingMembers.add(cm.ContactId);
            }

            return Database.getQueryLocator([
                    Select Id, FirstName, LastName
                    From Contact
                    Where RecordType.Name = 'Guarantor' AND ID NOT IN :existingMembers
            ]);
        } else {
            return Database.getQueryLocator([Select Id, FirstName From Contact Where RecordType.Name = 'Guarantor-DO-NOT-EXIST']);
        }
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Contact> guarantors = (List<Contact>) scope;
        Date dt14 = System.today().addDays(14);
        Date dt = System.today();
        if (callList != null) {
            List<CampaignMember> memberList = new List<CampaignMember>();
            for (Encounter__c ps : [
                    Select Id, Name, Guarantor__c, Liability__c, Date_of_Service__c
                    From Encounter__c
                    WHERE Patient__r.Guarantor__c IN :guarantors
                    AND Date_of_Service__c > :dt AND Date_of_Service__c <= :dt14
                    AND Liability__c > :100 AND Cancelled__c = false
            ]) {
	         	/*if(!existingMembers.contains(ps.Patient__r.Guarantor__c)){
	         		existingMembers.add(ps.Patient__r.Guarantor__c);
	         		memberList.add(new CampaignMember(CampaignId = callList.Id, ContactId = ps.Patient__r.Guarantor__c, Status = 'Sent'));
	         	}*/
                if (!existingMembers.contains(ps.Guarantor__c)) {
                    existingMembers.add(ps.Guarantor__c);
                    memberList.add(new CampaignMember(CampaignId = callList.Id, ContactId = ps.Guarantor__c, Status = 'Sent'));
                }
            }

            if (memberList.size() > 0) {
                insert memberList;
            }
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}