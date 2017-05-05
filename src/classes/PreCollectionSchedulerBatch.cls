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

        if (CampaignSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            for (Campaign cl: [SELECT  Id, Name FROM Campaign WHERE Name = :preCollection AND isActive = true]) {
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
            if (ContactSecurityContext.SB_SELECT_CONTEXT.actionAllowed()) {
                return Database.getQueryLocator([SELECT Id, FirstName FROM Contact WHERE RecordType.Name = 'Guarantor' AND ID NOT IN :existingMembers]);
            }
        } else {
            if (ContactSecurityContext.SB_SELECT_CONTEXT.actionAllowed()) {
                return Database.getQueryLocator([SELECT Id, FirstName FROM Contact WHERE RecordType.Name = 'Guarantor-DO-NOT-EXIST']);
            }
        }
        return null;
    }

    //adding new campaign members
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<Contact> guarantors = (List<Contact>) scope;
        Date dt = System.today();
        if (callList != null) {
            List<CampaignMember> memberList = new List<CampaignMember>();
            if (ChargeGroupSecurityContext.SELECT_CONTEXT.actionAllowed()) {
                for (Charge_Group__c cg: [
                        SELECT Id, Name, Guarantor__c, Pre_Collection_Sent__c, Guarantor__r.Overdue_Balance__c, Guarantor__r.Delinquent_Balance__c
                        FROM Charge_Group__c
                        WHERE Guarantor__c IN :guarantors AND Pre_Collection_Sent__c = :dt
                ]) {
                    Double bal = cg.Guarantor__r.Overdue_Balance__c + cg.Guarantor__r.Delinquent_Balance__c;
                    System.debug('bal' + bal);
                    if (bal <= -100 && bal > -5000 && !existingMembers.contains(cg.Guarantor__c)) {
                        existingMembers.add(cg.Guarantor__c);
                        memberList.add(new CampaignMember(CampaignId = callList.Id, ContactId = cg.Guarantor__c, Status = 'Sent'));
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