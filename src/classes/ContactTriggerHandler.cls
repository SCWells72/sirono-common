public with sharing class ContactTriggerHandler {
    public static void afterInsert(List<Contact> newList) {
        checkCallListRemove(newList, null);
    }

    public static void afterUpdate(List<Contact> newList, Map<Id, Contact> oldMap) {
        checkCallListRemove(newList, oldMap);
    }

    private static void checkCallListRemove(List<Contact> newList, Map<Id, Contact> oldMap) {
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for (Contact c : newList) {
            if (oldMap == null || c.Overdue_Balance__c != oldMap.get(c.Id).Overdue_Balance__c
                    || c.Delinquent_Balance__c != oldMap.get(c.Id).Delinquent_Balance__c) {
                contactMap.put(c.Id, c);
            }
        }

        if (contactMap.keySet().size() > 0) {
            CallListUtilities.PreCollectionCallListRemoval(contactMap.KeySet());
            CallListUtilities.EarlyOutCallListRemoval(contactMap.values());
        }
    }
}