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
        return [
                SELECT Id, Sirono_ID__c
                FROM Charge_Group__c
                WHERE Sirono_ID__c IN :sironoIds
        ];
    }

    public static void updateChargeGroups(List<Charge_Group__c> chargeGroups) {
        if (ChargeGroupSecurityContext.UPDATE_CONTEXT.actionAllowed()) {
            UPDATE chargeGroups;
        }
    }
}