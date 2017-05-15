/**
 *
 * Database actions for Charge_Group__c objects
 *
 */

public with sharing class ChargeGroupDao extends AbstractDao {

    /**
     * Return the list of Charge_Group__c objects associated with the given sironoIds
     */
    public static List<Charge_Group__c> getBySironoIds(List<Decimal> sironoIds) {
        if (ChargeGroupSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            return [
                    SELECT Id, Sirono_ID__c
                    FROM Charge_Group__c
                    WHERE Sirono_ID__c IN :sironoIds
            ];
        }

        return null;
    }

    /**
     * This method is use to get Billed Charge Groups Count based on Encounter Ids.
     *
     * @param Set<Id> encounterIds - That contains Encounter Ids which are associated in CG(s).
     * @returns List<AggregateResult> - That contains Billed CG Count based on Encounter Ids.
     **/
    public static List<AggregateResult> getBilledCGCountByEncounterIds(Set<Id> encounterIds) {
        if (ChargeGroupSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            return [
                    SELECT Encounter__r.Id encounterId, COUNT(Encounter__c) Total
                    FROM Charge_Group__c
                    WHERE Account_Status__c = :Constants.ACCT_STATUS_BILLED
                    AND Encounter__c IN :encounterIds
                    GROUP BY Encounter__r.Id
            ];
        }

        return null;
    }

    public static void updateChargeGroups(List<Charge_Group__c> chargeGroups) {
        if (ChargeGroupSecurityContext.UPDATE_CONTEXT.actionAllowed()) {
            UPDATE chargeGroups;
        }
    }
}