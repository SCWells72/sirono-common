/**
 * ChargeGroupService with logic for working with Charge_Group__c object.
 **/

public class ChargeGroupService extends AbstractService {

    /**
     * This method is use to get Billed Charge Groups Count based on Encounter Ids.
     *
     * @param Set<Id> encounterIds - That contains Encounter Ids which are associated in CG(s).
     * @returns List<AggregateResult> - That contains Billed CG Count based on Encounter Ids.
     **/
    public static List<AggregateResult> getBilledCGCountByEncounterIds(Set<Id> encounterIds) {
        return ChargeGroupDao.getBilledCGCountByEncounterIds(encounterIds);
    }
}