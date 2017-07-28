/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Processing to occur when payments are added/updated/deleted
 */
public with sharing class PaymentTriggerHandler {


    public static void afterInsert(List<Payment__c> newList) {
        afterInsertOrDelete(newList);
    }

    /**
     * When a Payment's amount or related Encounter changes, the Encounter's totalPayments needs to be recalculated
     */
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
                } else if (newPmt.Amount__c != oldPmt.Amount__c) {
                    encounterIds.add(newPmt.Encounter__c);
                }
            } else {
                if (oldPmt.Encounter__c != null) {
                    encounterIds.add(oldPmt.Encounter__c);
                }
            }

        }

        if (encounterIds.size() > 0) {
            EncounterUtil.updateTotalPayments(encounterIds);
        }
    }

    public static void afterDelete(List<Payment__c> oldList) {
        afterInsertOrDelete(oldList);
    }

    /**
     * If an inserted or deleted Payment has a related Encounter, calculate the Encounter's totalPayments
     */
    private static void afterInsertOrDelete(List<Payment__c> pmtList) {
        Set<Id> encounterIds = new Set<Id>();
        for (Payment__c pmt : pmtList) {
            if (pmt.Encounter__c != null) {
                encounterIds.add(pmt.Encounter__c);
            }
        }

        if (encounterIds.size() > 0) {
            EncounterUtil.updateTotalPayments(encounterIds);
        }
    }
}