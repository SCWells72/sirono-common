/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 06-02-2016
ADDITION: {Encounter}.{Estimated Patient Balance} > 100 and
{Encounter}.{Date of Service} > Today and
{Encounter}.{Date of Service} - 14 <= Today and
{Encounter}.{Cancelled} = FALSE
*/
public with sharing class PreServiceSchedulerBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    public Campaign callList;
    public Set<Id> existingMembers;

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new PreServiceSchedulerBatch(), 200);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        //Sirono : 08-30-2016 - #128375287 Update Salesforce Campaign Names
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'PreService'
        });
        string preService = mapCampaignMapping.get('PreService');

        if (CampaignSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            for (Campaign cl: [
                    SELECT Id, Name
                    FROM Campaign
                    WHERE Name = :preService AND isActive = true
            ]) {
                callList = cl;
            }
        }

        if (callList != null) {
            existingMembers = new Set<Id>();
            if (CmpnMemberSecurityContext.SELECT_CONTEXT.actionAllowed()) {
                for (CampaignMember cm: [
                    SELECT Id, ContactId
                    FROM CampaignMember
                    WHERE CampaignId = :callList.Id AND ContactId != null
                ]) {
                    existingMembers.add(cm.ContactId);
                }
            }

            if (ContactSecurityContext.SB_SELECT_CONTEXT.actionAllowed()) {
                return Database.getQueryLocator([
                    SELECT Id, FirstName, LastName
                    FROM Contact
                    WHERE RecordType.Name = 'Guarantor' AND ID NOT IN :existingMembers
                ]);
            }
        } else {
            if (ContactSecurityContext.SB_SELECT_CONTEXT.actionAllowed()) {
                return Database.getQueryLocator([
                     SELECT Id, FirstName
                     FROM Contact
                     WHERE RecordType.Name = 'Guarantor-DO-NOT-EXIST'
                ]);
            }
        }
        return null;
    }

    //adding new campaign members
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<Contact> guarantors = (List<Contact>) scope;
        Date dt14 = System.today().addDays(14);
        Date dt = System.today();
        if (callList != null) {
            List<CampaignMember> memberList = new List<CampaignMember>();
            if (EncounterSecurityContext.PSS_SELECT_CONTEXT.actionAllowed()) {
                for (Encounter__c ps: [
                        SELECT Id, Name, Guarantor__c, Liability__c, Date_of_Service__c
                        FROM Encounter__c
                        WHERE Patient__r.Guarantor__c IN :guarantors
                        AND Date_of_Service__c > :dt AND Date_of_Service__c <= :dt14
                        AND Liability__c > :100 AND Cancelled__c = false
                ]) {
                    /*if(!existingMembers.contains(ps.Patient__r.Guarantor__c)){
                        existingMembers.add(ps.Patient__r.Guarantor__c);
                        memberList.add(new CampaignMember(CampaignId = callList.Id, ContactId = ps.Patient__r.Guarantor__c, Status = 'Sent'));
                   }*/
                    System.debug('ps' + ps);
                    System.debug('existingMembers' + existingMembers);

                    if (!existingMembers.contains(ps.Guarantor__c)) {
                        existingMembers.add(ps.Guarantor__c);
                        memberList.add(new CampaignMember(CampaignId = callList.Id, ContactId = ps.Guarantor__c, Status = 'Sent'));
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