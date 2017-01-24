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

        if (encounterIds.size() == 0) {
            return;
        }

        // Get the SUM of all the associated payments
        AggregateResult[] results = [
                SELECT Encounter__c obj, SUM(Amount__c) Total
                FROM Payment__c
                WHERE Encounter__c IN :encounterIds
                GROUP BY Encounter__c
        ];

        if (results.size() > 0) {
            List<Encounter__c> encountersToUpdate = new List<Encounter__c>();
            for (AggregateResult ar : results) {
                Encounter__c enc = new Encounter__c(Id=(Id)ar.get(OBJ));
                enc.Total_Payments__c = (Decimal) ar.get(TOTAL);

                encountersToUpdate.add(enc);
            }

            UPDATE encountersToUpdate;
        }
    }

    /**
      * Determine which of the given Encounters have associated
      * Charge_Groups and set Has_ChargeGroup flag accordingly.
     */
    public static void setHasChargeGroup(Set<Id> encounterIds) {
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

        UPDATE encountersToUpdate;
    }
}