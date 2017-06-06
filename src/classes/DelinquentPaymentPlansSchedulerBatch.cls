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
    public Campaign callList;
    public Set<Id> existingMembers;

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new DelinquentPaymentPlansSchedulerBatch(), 200);
    }

    public Database.QueryLocator start(Database.BatchableContext sc) {
        //Sirono : 08-30-2016 - #128375287 Update Salesforce Campaign Names
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Delinquent'
        });
        string delinquent = mapCampaignMapping.get('Delinquent');

        if (CampaignSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            for (Campaign cl: [SELECT Id, Name
                               FROM Campaign
                               WHERE Name = :delinquent
                               AND isActive = true
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

            return Database.getQueryLocator(GuarantorService.getContactsByRecordType());
        } else {
            return Database.getQueryLocator(GuarantorService.getContactsNoResults());
        }
        return null;
    }
    //Checks if the members exist if not Creates new Campaign members
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<Contact> guarantors = (List<Contact>) scope;
        Date dt = System.today().addDays(-10);
        if (callList != null) {
            List<CampaignMember> memberList = new List<CampaignMember>();
            if (PaymentPlanSecurityContext.DPPSB_SELECT_CONTEXT.actionAllowed()) {
                for (Payment_Plan__c pp: [
                        SELECT Id, Name, Guarantor__c, Delinquent_Date__c, Remaining_Balance__c, Active__c
                        FROM Payment_Plan__c
                        WHERE Guarantor__c IN :guarantors
                        AND Delinquent_Date__c = :dt
                        AND Remaining_Balance__c < :-100 AND Active__c = true
                ]) {
                    if (!existingMembers.contains(pp.Guarantor__c)) {
                        existingMembers.add(pp.Guarantor__c);
                        memberList.add(new CampaignMember(CampaignId = callList.Id,
                                ContactId = pp.Guarantor__c, Status = 'Sent'));
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