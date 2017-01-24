/**
 * Created by mmartin on 1/23/17.
 */

public with sharing class PaymentTriggerHandler {

    public static void afterInsert(List<Payment__c> newList) {
        Set<Id> encounterIds = new Set<Id>();
        for (Payment__c pmt : newList) {
            if (pmt.Encounter__c != null) {
                encounterIds.add(pmt.Encounter__c);
            }
        }

        if (encounterIds.size() > 0) {
            EncounterUtil.updatePaymentsTotal(encounterIds);
        }
    }

    public static void afterUpdate(List<Payment__c> newList, Map<Id, Payment__c> oldMap) {
        Set<Id> encounterIds = new Set<Id>();
        for (Payment__c newPmt : newList) {
            Payment__c oldPmt = oldMap.get(newPmt.Id);

            if (newPmt.Encounter__c != null) {
                if (newPmt.Encounter__c != oldPmt.Encounter__c) {
                    encounterIds.add(newPmt.Encounter__c);
                    if (oldPmt.Encounter__c != null) {
                        encounterIds.add(oldPmt.Encounter__c);
                    }
                }
            } else {
                if (oldPmt.Encounter__c != null) {
                    encounterIds.add(oldPmt.Encounter__c);
                }
            }

        }

        if (encounterIds.size() > 0) {
            EncounterUtil.updatePaymentsTotal(encounterIds);
        }
    }

    public static void afterDelete(List<Payment__c> oldList) {
        Set<Id> encounterIds = new Set<Id>();
        for (Payment__c pmt : oldList) {
            if (pmt.Encounter__c != null) {
                encounterIds.add(pmt.Encounter__c);
            }
        }

        if (encounterIds.size() > 0) {
            EncounterUtil.updatePaymentsTotal(encounterIds);
        }
    }
}