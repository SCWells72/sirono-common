/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 05-30-2016
  
ADDITION: any {Charge Group}.{Pre Collection Sent} = Today and
{Guarantor}.{Overdue Balance} + {Guarantor}.{Delinquent Balance} <= -100 and
{Guarantor}.{Overdue Balance} + {Guarantor}.{Delinquent Balance} > -5000

Sirono : 08-30-2016 - #128375287 Update Salesforce Campaign Names

*/
public with sharing class PreCollectionSchedulerBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    public Campaign callList;
    public Set<Id> existingMembers;

    public void execute(SchedulableContext bc) {
        Database.executeBatch(new PreCollectionSchedulerBatch(), 200);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        //Sirono : 08-30-2016 - #128375287 Update Salesforce Campaign Names
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'PreCollections'
        });
        string preCollection = mapCampaignMapping.get('PreCollections');

        for (Campaign cl : [Select Id, Name From Campaign Where Name = :preCollection and isActive = true]) {
            callList = cl;
        }
        if (callList != null) {
            existingMembers = new Set<Id>();
            for (CampaignMember cm : [Select Id, ContactId From CampaignMember Where CampaignId = :callList.Id AND ContactId != null]) {
                existingMembers.add(cm.ContactId);
            }

            return Database.getQueryLocator([Select Id, FirstName From Contact Where RecordType.Name = 'Guarantor' AND ID NOT IN :existingMembers]);
        } else {
            return Database.getQueryLocator([Select Id, FirstName From Contact Where RecordType.Name = 'Guarantor-DO-NOT-EXIST']);
        }
    }

    //adding new campaign members
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<Contact> guarantors = (List<Contact>) scope;
        Date dt = System.today();
        if (callList != null) {
            List<CampaignMember> memberList = new List<CampaignMember>();
            for (Charge_Group__c cg : [
                    Select Id, Name, Guarantor_Name__c, Pre_Collection_Sent__c, Guarantor_Name__r.Overdue_Balance__c, Guarantor_Name__r.Delinquent_Balance__c
                    From Charge_Group__c
                    WHERE Guarantor_Name__c IN :guarantors AND Pre_Collection_Sent__c = :dt
            ]) {
                Double bal = cg.Guarantor_Name__r.Overdue_Balance__c + cg.Guarantor_Name__r.Delinquent_Balance__c;
                System.debug('bal' + bal);
                if (bal <= -100 && bal > -5000 && !existingMembers.contains(cg.Guarantor_Name__c)) {
                    existingMembers.add(cg.Guarantor_Name__c);
                    memberList.add(new CampaignMember(CampaignId = callList.Id, ContactId = cg.Guarantor_Name__c, Status = 'Sent'));
                }
            }

            if (memberList.size() > 0) {
                insert memberList;
            }
        }
    }

    public void finish(Database.BatchableContext bc) {

    }
}