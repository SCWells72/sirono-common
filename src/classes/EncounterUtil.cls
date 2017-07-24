/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Utility class for setting the Total_Payments and BilledChargeGroupCount
 * These methods are invoked when either a Charge_Group or Payment's Encounter changes
 * TODO: remove without sharing
 */
public with sharing class EncounterUtil {

    private static String ENCOUNTERID = 'encounterId';
    private static String OBJ = 'obj';
    private static String TOTAL = 'Total';

    /**
      * Update the Total_Payments field in the Encounters with the total of
      * all associated Payments
     */
    public static void updateTotalPayments(Set<Id> encounterIds) {
        if (encounterIds.contains(null)) {
            encounterIds.remove(null);
        }

        if (encounterIds.size() == 0) {
            return;
        }

        Map<Id, Encounter__c> encountersToUpdate = new Map<Id, Encounter__c>();
        for (Id id : encounterIds) {
            encountersToUpdate.put(id, new Encounter__c(Id = id, Total_Payments__c = 0));
        }
        if (PaymentSecurityContext.EU_SELECT_CONTEXT.actionAllowed()) {
            // Get the SUM of all the associated payments
            AggregateResult[] results = [
                    SELECT Encounter__c obj, SUM(Amount__c) Total
                    FROM Payment__c
                    WHERE Encounter__c IN :encounterIds
                    GROUP BY Encounter__c
            ];

            for (AggregateResult ar : results) {
                Encounter__c enc = new Encounter__c(Id=(Id)ar.get(OBJ));
                enc.Total_Payments__c = (Decimal) ar.get(TOTAL);

                encountersToUpdate.put(enc.Id, enc);
            }

            if (EncounterSecurityContext.UPDATE_CONTEXT.actionAllowed()) {
                UPDATE encountersToUpdate.values();
            }
            updateAssociatedGuarantors(encounterIds);
        }
    }

    /*
     * Collect the guarantor Id's from the given encounters and set the
     * Estimate_Balance on each guarantor
     */
    private static void updateAssociatedGuarantors(Set<Id> encounterIds) {
        if (EncounterSecurityContext.EU_SELECT_CONTEXT.actionAllowed()) {
            List<Encounter__c> encountersWithGts = [
                    SELECT Id, Guarantor__c
                    FROM Encounter__c
                    WHERE Id IN :encounterIds
                    AND Guarantor__c != null
            ];

            Set<Id> gtIds = new Set<Id>();
            for (Encounter__c encounter: encountersWithGts) {
                gtIds.add(encounter.Guarantor__c);
            }
            updateGTEstimateBalances(gtIds);
        }
    }

    /**
     * Update the Estimate_Balance for each of the given guarantors
     *
     */
    public static void updateGTEstimateBalances(Set<Id> gtIds) {
        if (gtIds.contains(null)) {
            gtIds.remove(null);
        }

        if (gtIds.size() == 0) {
            return;
        }

        if (EncounterSecurityContext.EU_SELECT_CONTEXT_AGG.actionAllowed()) {
            // Get the SUM of the balances of the associated Encounters
            // there are no results for gtIds with no Encounters
            AggregateResult[] results = [
                    SELECT Guarantor__c obj, SUM(Balance__c) Total
                    FROM Encounter__c
                    WHERE Guarantor__c IN :gtIds
                    AND Guarantor__c != null
                    AND Encounter_Substatus__c = :Constants.EN_SUBSTATUS_PAYMENT_DUE
                    GROUP BY Guarantor__c
            ];

            Map<Id, Decimal> resultsMap = new Map<Id, Decimal>();
            for (AggregateResult ar : results) {
                resultsMap.put((Id) ar.get(OBJ), (Decimal)ar.get(TOTAL));
            }

            List<Contact> toUpdate = new List<Contact>();
            for (Id gtId : gtIds) {
                Contact gt = new Contact(Id = gtId);
                gt.RecordTypeId = RecordTypeUtil.guarantorRt;

                if (resultsMap.containsKey(gtId)) {
                    gt.Estimate_Balance__c = resultsMap.get(gtId);
                } else {
                    gt.Estimate_Balance__c = 0;
                }

                toUpdate.add(gt);
            }
            // Update Contacts.
            GuarantorService.updateGuarantorsWithEstimateBal(toUpdate);
        }
    }

    /**
     * Update the Billed_Charge_Group_Count__c field in the Encounters with the number of
     * all associated Charge Groups where Account_Status__c is Billed.
     *
     * @param Set<Id> encounterIds - the encounters to update
     **/
    public static void setBilledCGCount(Set<Id> encounterIds) {
        if (encounterIds.contains(null)) {
            encounterIds.remove(null);
        }

        if (encounterIds.isEmpty()) {
            return;
        }

        Map<Id, Encounter__c> encountersToUpdate = new Map<Id, Encounter__c>();
        for (Id id: encounterIds) {
            encountersToUpdate.put(id, new Encounter__c(Id = id, Billed_Charge_Group_Count__c = 0));
        }

        // Get Billed CG Count based on Encounter Ids. 
        List<AggregateResult> results = ChargeGroupService.getBilledCGCountByEncounterIds(encounterIds);

        for (AggregateResult ar: results) {
            Encounter__c enc = new Encounter__c(Id = (Id) ar.get(ENCOUNTERID));
            enc.Billed_Charge_Group_Count__c = (Integer) ar.get(TOTAL);

            encountersToUpdate.put(enc.Id, enc);
        }

        // Update Encounter records.
        EncounterService.updateBilledCGCount(encountersToUpdate.values());
    }
}