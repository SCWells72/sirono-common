/*
* @author Sirono 
* @version 1.0.1
* @Date: 06-06-2016
* @ContactTriggerHandler Class used as a ContactTrigger Handler.
* 
* 08-11-2016: Sirono - Tracker # 127517097 For Automatic Early-out Case Closure
*
* 08-11-2016: Sirono - Tracker # 128030957 For Removal from Early-out campaign
*/

public with sharing class ContactTriggerHandler {
	public ContactTriggerHandler() {
    
    }
	/*
    // Call checkCallListRemove method when the contact is inserted.        
    public static void afterInsert(List<Contact> newList) {
        checkCallListRemove(newList, null);
    }

    // Call checkCallListRemove, caseEarlyOutClose methods when the contact is updated.
    public static void afterUpdate(List<Contact> newList, Map<Id, Contact> oldMap) {
        checkCallListRemove(newList, oldMap);
        caseEarlyOutClose(newList, oldMap);
        callPopulateNextPaymentDate(newList, oldMap);
    }

    // Call checkCallListRemove method when the contact is inserted.
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

    /*
     * Call caseEarlyOutClose method when the contact is updated.
     * 
     * 08-11-2016: Sirono - Tracker # 127517097 For Automatic Early-out Case Closure
     *
     * 08-11-2016: Sirono - Tracker # 128030957 For Removal from Early-out campaign
     *
    private static void caseEarlyOutClose(List<Contact> newList, Map<Id, Contact> oldMap) {
        System.debug('In');
        Set<String> contactOverdueSet = new Set<String>();
        Set<String> contactDelinquentSet = new Set<String>();
        for (Contact c : newList) {
            if (c.Overdue_Balance__c != oldMap.get(c.Id).Overdue_Balance__c
                    && c.Overdue_Balance__c >= 0) {
                contactOverdueSet.add(c.Id);
            }
            if (c.Delinquent_Balance__c != oldMap.get(c.Id).Delinquent_Balance__c
                    && c.Delinquent_Balance__c >= 0) {
                contactDelinquentSet.add(c.Id);
            }
        }

        if (contactOverdueSet.size() > 0) {
            CaseUtil.closeEarlyOutAutoCase(contactOverdueSet);
        }
        if (contactDelinquentSet.size() > 0) {
            CaseUtil.closePrecollectionsAutoCase(contactDelinquentSet);
        }
    }
    
    /*
     * 09-26-2016: Viraj Rana - Tracker # 127404425 
     * If contacts Offset is changed then we have to update the next payment date of playment plan object.
     *
    private static void callPopulateNextPaymentDate(List<Contact> newList, Map<Id, Contact> oldMap) {
        Set<String> contactId = new Set<String>();
        for (Contact c : newList) {
            if (c.Invoice_Offset_Date__c != oldMap.get(c.Id).Invoice_Offset_Date__c) {
                contactId.add(c.Id);
            }
        }

        if (contactId.size() > 0) {
            List<test__c> paymentPlan = [
                    Select
                            Id, Guarantor_Name__c, Plan_Type__c,
                            Execute_on_Day__c, NextPaymentDate__c,
                            Skip_Payment_Until__c
                    From Test__c
                    where Guarantor_Name__c in :contactId
            ];
            if (!paymentPlan.IsEmpty()) {
                PaymentPlanTriggerHandler.populateNextPaymentDate(paymentPlan, false);
            }
        }
    }*/
}