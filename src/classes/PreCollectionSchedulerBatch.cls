/*
ADDITION: any {Charge Group}.{Pre Collection Sent} = Today and
{Guarantor}.{Overdue Balance} + {Guarantor}.{Delinquent Balance} <= -100 and
{Guarantor}.{Overdue Balance} + {Guarantor}.{Delinquent Balance} > -5000
*/
global with sharing class PreCollectionSchedulerBatch 
    implements Database.Batchable<sObject>, Schedulable, Database.Stateful{ 
    global Campaign callList;
    global Set<Id> existingMembers;
     
    global void execute(SchedulableContext SC) {
         Database.executeBatch(new PreCollectionSchedulerBatch(), 200);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
		for(Campaign cl : [Select Id, Name From Campaign Where Name = 'Pre-collections' and isActive = true]){
	   		callList = cl;
	   	}
	    if(callList != null){
		    existingMembers = new Set<Id>();
		    for(CampaignMember cm : [Select Id, ContactId From CampaignMember 
		    	Where CampaignId = :callList.Id AND ContactId != null]){
		    	existingMembers.add(cm.ContactId);
		    }
		    
		    return Database.getQueryLocator([Select Id, FirstName From Contact 
		    	Where RecordType.Name = 'Guarantor' AND ID NOT IN :existingMembers ]);
	    }else{
	    	return Database.getQueryLocator([Select Id, FirstName From Contact Where RecordType.Name = 'Guarantor-DO-NOT-EXIST']);
	    }
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
         List<Contact> guarantors = (List<Contact>)scope;
         Date dt = System.today();
         if(callList != null){
	         List<CampaignMember> memberList = new List<CampaignMember>();
	         for(Charge_Group__c cg : [Select Id, Name, Guarantor_Name__c, Pre_Collection_Sent__c, 
	         	Guarantor_Name__r.Overdue_Balance__c, Guarantor_Name__r.Delinquent_Balance__c
	         	From Charge_Group__c WHERE Guarantor_Name__c IN :guarantors 
	         		AND Pre_Collection_Sent__c = :dt]){
	         	Double bal = cg.Guarantor_Name__r.Overdue_Balance__c + cg.Guarantor_Name__r.Delinquent_Balance__c;
	         	if(bal <= -100 && bal > -5000 && !existingMembers.contains(cg.Guarantor_Name__c)){
	         		existingMembers.add(cg.Guarantor_Name__c);
	         		memberList.add(new CampaignMember(CampaignId = callList.Id, ContactId = cg.Guarantor_Name__c, Status = 'Sent'));
	         	}
	         }
	         
	         if(memberList.size() > 0){
	         	insert memberList;
	         }
         }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}