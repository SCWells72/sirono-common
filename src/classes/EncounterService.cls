/**
 * EncounterService with logic for working with Encounter__c object.
 */
public class EncounterService extends AbstractService {
	/**
	 * This method is use to get Encounter Records based on Guarantor Id or Id and Balance is greater than zero.
     * @param String idType - object name for where condition
     * @param String condId - record Id
	 **/
    public static List<Encounter__c> getEncounterRecordsById(String idType, String condId) {
    	List<Encounter__c> encounterList = EncounterDao.getEncounterRecordsById(idType, condId);
        return encounterList;
    }
}