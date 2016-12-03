/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 06-06-2016
 * @description Handler Class for EncounterTrigger
*/
public with sharing class EncounterTriggerHandler {
	public EncounterTriggerHandler() {
    
    }
	/*
    //static method invoked when a after insert operation is performed
    public static void afterInsert(List<Encounter__c> newList) {
        checkCallListRemove(newList, null);
        CaseUtil.CreateEncounterAutoCase(newList);
    }

    //static method invoked when a after update operation is performed
    public static void afterUpdate(List<Encounter__c> newList, Map<Id, Encounter__c> oldMap) {
        checkCallListRemove(newList, oldMap);
        CaseUtil.CallCloseEncounterAutoCase(newList, false);
    }

    //METHOD THAT COLLECTS THE ID OF GUARANTOR 
    private static void checkCallListRemove(List<Encounter__c> newList, Map<Id, Encounter__c> oldMap) {
        Set<Id> contactIds = new Set<Id>();
        for (Encounter__c e : newList) {
            if (e.Liability__c > 100 && e.Date_of_Service__c == System.Today()
                    && e.Cancelled__c && e.Patient__c != null &&
                    (oldMap == null || e.Liability__c != oldMap.get(e.Id).Liability__c
                            || e.Date_of_Service__c != oldMap.get(e.Id).Date_of_Service__c
                            || e.Cancelled__c != oldMap.get(e.Id).Cancelled__c
                            || e.Guarantor__c != oldMap.get(e.Id).Guarantor__c)) {
                contactIds.add(e.Guarantor__c);
            }
        }

        if (contactIds.size() > 0) {
            CallListUtilities.PreServiceCallListRemoval(contactIds);
        }
    }*/
}