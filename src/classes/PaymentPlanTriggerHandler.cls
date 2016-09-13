public with sharing class PaymentPlanTriggerHandler {
	public static void afterInsert(List<test__c> newList){
		checkCallListRemove(newList, null);
	}
	
	public static void afterUpdate(List<test__c> newList, Map<Id, test__c> oldMap){
		checkCallListRemove(newList, oldMap);
	}
	
	private static void checkCallListRemove(List<test__c> newList, Map<Id, test__c> oldMap){
		Set<Id> contactIds = new Set<Id>();
		for(test__c pp : newList){
			if(!pp.Active__c && pp.Delinquent_Date__c == null && pp.Guarantor_Name__c != null &&
			(oldMap == null || pp.Delinquent_Date__c != oldMap.get(pp.Id).Delinquent_Date__c
				|| pp.Active__c != oldMap.get(pp.Id).Active__c
				|| pp.Guarantor_Name__c != oldMap.get(pp.Id).Guarantor_Name__c)){
				contactIds.add(pp.Guarantor_Name__c);	
			}
		}
		
		if(contactIds.size() > 0){
			CallListUtilities.DelinquentPaymentPlanCallListRemoval(contactIds);
		}
	}
}