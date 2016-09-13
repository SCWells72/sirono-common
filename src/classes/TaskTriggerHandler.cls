public with sharing class TaskTriggerHandler {
	public static void afterInsert(List<Task> newList){
		removeFromCallList(newList, null);
	}
	
	public static void afterUpdate(List<Task> newList, Map<Id,Task> oldMap){
		removeFromCallList(newList, oldMap);
	}
	
	private static Map<String, String> callListNameMap {
		get{
			if(callListNameMap == null){
				callListNameMap = new Map<String, String>();
				for(Campaign cm : [Select Id, Name, IsActive From Campaign Where isActive = true]){
					callListNameMap.put(cm.Name, String.valueOf(cm.Id));
				}
			}
			return callListNameMap;
		}
		set;
	}
	
	private static void removeFromCallList(List<Task> newList, Map<Id,Task> oldMap){
		Set<Id> contactIds = new Set<Id>();
		for(Task t : newList){
			if(t.CallDisposition != null && t.WhoId != null && String.valueOf(t.WhoId).startsWith('003')
				&& (t.CallDisposition.trim().equalsIgnoreCase('Final')
					|| t.CallDisposition.trim().equalsIgnoreCase('Retry')
					|| t.CallDisposition.trim().equalsIgnoreCase('Error'))
				&& (oldMap == null || t.CallDisposition != oldMap.get(t.Id).CallDisposition) ){
				contactIds.add(t.WhoId);
			}
		}
		
		if(contactIds.size() > 0){
			Map<String, ActivityCounterWrapper> counterMap = new Map<String, ActivityCounterWrapper>();
			Map<String, CampaignMember> cmMap = new Map<String, CampaignMember>();
			for(CampaignMember cm : [Select Id, ContactId, CampaignId From CampaignMember 
				Where ContactId IN :contactIds AND CampaignId IN :callListNameMap.values()]){
				String keyStr = String.valueOf(cm.ContactId).substring(0,15)+'-'+String.valueOf(cm.CampaignId).substring(0,15);
				cmMap.put(keyStr, cm);
			}
			
			for(Contact c : [Select Id, FirstName, LastName, 
				(Select Id, CallDisposition, Five9__Five9Campaign__c From Tasks 
					WHERE Five9__Five9Campaign__c != null AND Five9__Five9Campaign__c IN :callListNameMap.KeySet()
					AND CallDisposition IN ('Final','Retry','Error'))
				From Contact Where Id IN :contactIds]){
				for(Task t : c.Tasks){
					if(callListNameMap.containsKey(t.Five9__Five9Campaign__c)){
						String keyStr = String.valueOf(c.Id).substring(0,15)+'-'
							+callListNameMap.get(t.Five9__Five9Campaign__c).substring(0,15);
						if(!counterMap.containsKey(keyStr)){
							counterMap.put(keyStr,new ActivityCounterWrapper(c.Id, callListNameMap.get(t.Five9__Five9Campaign__c)));
						}
						if(t.CallDisposition.trim().equalsIgnoreCase('Final')){
							counterMap.get(keyStr).finalCount++;
						}
						if(t.CallDisposition.trim().equalsIgnoreCase('Retry')){
							counterMap.get(keyStr).retryCount++;
						}
						if(t.CallDisposition.trim().equalsIgnoreCase('Error')){
							counterMap.get(keyStr).errorCount++;
						}
					}
				}
			}
			
			List<CampaignMember> cmListToRemove = new List<CampaignMember>();
			for(String keyStr : counterMap.keySet()){
				ActivityCounterWrapper acw = counterMap.get(keyStr);
				if((acw.finalCount == 1 || acw.retryCount == 2 || acw.errorCount == 5) && cmMap.containsKey(keyStr)){
					cmListToRemove.add(cmMap.get(keyStr));
				}
			}
			
			if(cmListToRemove.size() > 0){
				delete cmListToRemove;
			}
		}
	}
	
	public class ActivityCounterWrapper {
		public String contactId {get; set;}
		public String campaignId {get; set;}
		public Integer finalCount {get; set;}
		public Integer retryCount {get; set;}
		public Integer errorCount {get; set;}
		
		public ActivityCounterWrapper(String conId, String campId){
			this.contactId = conId;
			this.campaignId = campId;
			this.finalCount = 0;
			this.retryCount = 0;
			this.errorCount = 0;
		}
	}
}