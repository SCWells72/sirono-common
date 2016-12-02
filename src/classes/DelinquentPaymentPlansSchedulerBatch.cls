/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 06-02-2016
 * @DelinquentPaymentPlansSchedulerBatch class.
 
 * ADDITION: {Payment Plan}.{Delinquent Date} + 10 = Today and
 * {Payment Plan}.{Remaining Balance} < -100 and
 * {Payment Plan}.{Active} = TRUE

 * Sirono : 08-30-2016 - #128375287 Update Salesforce Campaign Names
*/
public with sharing class DelinquentPaymentPlansSchedulerBatch
        implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    //public Campaign callList;
    //public Set<Id> existingMembers;

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new DelinquentPaymentPlansSchedulerBatch(), 200);
    }

    public Database.QueryLocator start(Database.BatchableContext sc) {
       return Database.getQueryLocator([Select Id, FirstName From Contact]);
       /*
        //Sirono : 08-30-2016 - #128375287 Update Salesforce Campaign Names
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Delinquent'
        });
        string delinquent = mapCampaignMapping.get('Delinquent');

        for (Campaign cl : [Select Id, Name From Campaign Where Name = :delinquent and isActive = true]) {
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
                    Where RecordType.Name = 'Guarantor'
                    AND ID NOT IN :existingMembers
            ]);
        } else {
            return Database.getQueryLocator([
                    Select Id, FirstName
                    From Contact
                    Where RecordType.Name = 'Guarantor-DO-NOT-EXIST'
            ]);
        }*/
    }
    //Checks if the members exist if not Creates new Campaign members
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        /*List<Contact> guarantors = (List<Contact>) scope;
        Date dt = System.today().addDays(-10);
        if (callList != null) {
            List<CampaignMember> memberList = new List<CampaignMember>();
            for (test__c pp : [
                    Select Id, Name, Guarantor_Name__c, Delinquent_Date__c, Payable_Amount__c, Active__c
                    From test__c
                    WHERE Guarantor_Name__c IN :guarantors
                    AND Delinquent_Date__c = :dt
                    AND Payable_Amount__c < :-100 AND Active__c = true
            ]) {
                if (!existingMembers.contains(pp.Guarantor_Name__c)) {
                    existingMembers.add(pp.Guarantor_Name__c);
                    memberList.add(new CampaignMember(CampaignId = callList.Id,
                            ContactId = pp.Guarantor_Name__c, Status = 'Sent'));
                }
            }

            if (memberList.size() > 0) {
                insert memberList;
            }
        }*/
    }

    public void finish(Database.BatchableContext bc) {

    }
}