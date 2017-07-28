/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Handler class for EncounterTrigger
 */
public with sharing class EncounterTriggerHandler {

    /*
     * After Inserting an encounter, perform the following:
     *   Check whether or not the guarantor can be removed from a call list
     *   Create an Encounter Auto Case for the encounter
     *   Calculate the Estimate_Balance for any guarantor associated with the Encounter
     */
    public static void afterInsert(List<Encounter__c> newList) {
        checkCallListRemove(newList, null);
        CaseUtil.createEncounterAutoCase(newList);
        updateEstimateBalances(newList);
    }

    /*
     * After Updating an encounter, perform the following:
     *   Check whether or not the guarantor can be removed from a call list
     *   Close Encounter Auto Case and Remove the Campaign member from Campaign
     *   If the guarantor associated with the encounter changed, recalculate the Estimate_Balance for both
     */
    public static void afterUpdate(List<Encounter__c> newList, Map<Id, Encounter__c> oldMap) {
        checkCallListRemove(newList, oldMap);
        CaseUtil.callCloseEncounterAutoCase(newList, false);
        checkEstimateBalanceRecalc(newList, oldMap);
    }

    /*
     * After deleting an encounter, perform the following:
     *   For any guarantor formerly associated with the encounter, recalculate their Estimate_Balance
     */
    public static void afterDelete(List<Encounter__c> oldList) {
        updateEstimateBalances(oldList);
    }

    //METHOD THAT COLLECTS THE ID OF GUARANTOR 
    private static void checkCallListRemove(List<Encounter__c> newList, Map<Id, Encounter__c> oldMap) {
        Set<Id> contactIds = new Set<Id>();
        for (Encounter__c e : newList) {
            if (e.Liability__c > 100 && e.Date_of_Service__c == System.today()
                && e.Cancelled__c && e.Patient__c != null &&
                (oldMap == null || e.Liability__c != oldMap.get(e.Id).Liability__c
                    || e.Date_of_Service__c != oldMap.get(e.Id).Date_of_Service__c
                    || e.Cancelled__c != oldMap.get(e.Id).Cancelled__c
                    || e.Guarantor__c != oldMap.get(e.Id).Guarantor__c)) {
                contactIds.add(e.Guarantor__c);
            }
        }

        if (contactIds.size() > 0) {
            CallListUtilities.preServiceCallListRemoval(contactIds);
        }
    }

    /**
     * If the Guarantor associated with a given Encounter has changed, recalculate the balances
     * for the old and new Guarantors
     */
    private static void checkEstimateBalanceRecalc(List<Encounter__c> encounters, Map<Id, Encounter__c> oldMap) {
        Set<Id> contactIds = new Set<Id>();
        for (Encounter__c e : encounters) {
            if (e.Guarantor__c != null) {
                if (e.Guarantor__c != oldMap.get(e.Id).Guarantor__c) {
                    contactIds.add(e.Guarantor__c);
                    if (oldMap.get(e.Id).Guarantor__c != null) {
                        contactIds.add(oldMap.get(e.Id).Guarantor__c);
                    }
                } else {
                    if (e.Encounter_Substatus__c != oldMap.get(e.Id).Encounter_Substatus__c) {
                        contactIds.add(e.Guarantor__c);
                    }
                }
            } else {
                if (oldMap.get(e.Id).Guarantor__c != null) {
                    contactIds.add(oldMap.get(e.Id).Guarantor__c);
                }
            }
        }

        if (contactIds.size() > 0) {
            EncounterUtil.updateGTEstimateBalances(contactIds);
        }
    }

    /**
     * If a given Encounter is associated with a Guarantor, calculate the Estimate_Balance
     * for the Guarantors
     */
    private static void updateEstimateBalances(List<Encounter__c> encounters) {
        Set<Id> ids = new Set<Id>();
        for (Encounter__c encounter : encounters) {
            if (encounter.Guarantor__c != null) {
                ids.add(encounter.Guarantor__c);
            }
        }

        EncounterUtil.updateGTEstimateBalances(ids);
    }
}