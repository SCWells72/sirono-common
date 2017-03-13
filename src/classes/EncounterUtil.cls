/**
  * Utility class for setting the fields used in Encounter Balance calculation:
  * Total_Payments and Has_Chargegroup
  *
  * Balance calculation is: IF(Has_Chargegroup, 0, Patient_Portion - Total_Payments)
  *
  * These methods are invoked when either a Charge_Group or Payment's Encounter changes
 */
public with sharing class EncounterUtil {

    private static String TOTAL = 'Total';
    private static String OBJ = 'obj';

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

    /**
      * Determine which of the given Encounters have associated
      * Charge_Groups and set Has_ChargeGroup flag accordingly.
     */
    public static void setHasChargeGroup(Set<Id> encounterIds) {
        if (encounterIds.contains(null)) {
            encounterIds.remove(null);
        }

        if (encounterIds.size() == 0) {
            return;
        }

        List<Charge_Group__c> cgsWithEncounters = [
                SELECT Id, Encounter__c
                FROM Charge_Group__c
                WHERE Encounter__c IN :encounterIds
                AND Encounter__c != null
        ];

        Set<Id> hasChargeGroup = new Set<Id>();
        for (Charge_Group__c cg : cgsWithEncounters) {
            hasChargeGroup.add(cg.Encounter__c);
        }

        encounterIds.removeAll(hasChargeGroup);

        if (encounterIds.size() > 0) {
            setHasChargeGroupFlag(encounterIds, false);
        }

        if (hasChargeGroup.size() > 0) {
            setHasChargeGroupFlag(hasChargeGroup, true);
        }

        encounterIds.addAll(hasChargeGroup);
        updateAssociatedGuarantors(encounterIds);
    }

    /*
     * Set the Has_Chargegroup__c flag on the given encounters to the given boolean value
     */
    private static void setHasChargeGroupFlag(Set<Id> encounterIds, boolean flagValue) {
        if (encounterIds.size() == 0) {
            return;
        }

        List<Encounter__c> encountersToUpdate = new List<Encounter__c>();
        for (Id id : encounterIds) {
            Encounter__c enc = new Encounter__c(Id=id);
            enc.Has_Chargegroup__c = flagValue;
            encountersToUpdate.add(enc);
        }
	if (EncounterSecurityContext.UPDATE_HAS_CHARGEGROUP_CONTEXT.actionAllowed()) {
	    UPDATE encountersToUpdate;
	}
    }

    /*
     * Collect the guarantor Id's from the given encounters and set the
     * Estimate_Balance on each guarantor
     */
    private static void updateAssociatedGuarantors(Set<Id> encounterIds) {
        List<Encounter__c> encountersWithGts = [
                SELECT Id, Guarantor__c
                FROM Encounter__c
                WHERE Id IN :encounterIds
                AND Guarantor__c != null
        ];

        Set<Id> gtIds = new Set<Id>();
        for (Encounter__c encounter : encountersWithGts) {
            gtIds.add(encounter.Guarantor__c);
        }
        updateGTEstimateBalances(gtIds);
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

        // Get the SUM of the balances of the associated Encounters
        // there are no results for gtIds with no Encounters
        AggregateResult[] results = [
                SELECT Guarantor__c obj, SUM(Balance__c) Total
                FROM Encounter__c
                WHERE Guarantor__c IN :gtIds
                AND Guarantor__c != null
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
	if (ContactSecurityContext.UPDATE_CONTEXT.actionAllowed()) {
	    UPDATE toUpdate;
	}
    }
}