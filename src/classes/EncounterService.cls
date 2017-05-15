/**
 * EncounterService with logic for working with Encounter__c object.
 */
public class EncounterService extends AbstractService {
	/**
	 * This method is use to get Encounter Records based on Guarantor Id or Id and Balance is greater than zero.
     * @param String encounterId - encounter record Id
	 **/
    public static List<Encounter__c> getEncounterRecordsById(String encounterId) {
    	List<Encounter__c> encounterList = EncounterDao.getEncounterRecordsById(EncounterDao.IdType.ENCOUNTER, encounterId);
        return encounterList;
    }

    /**
	 * This method is use to get Encounter Records based on Guarantor Id or Id and Balance is greater than zero.
     * @param String guarantorId - guarantor record Id
	 **/
    public static List<Encounter__c> getEncounterRecordsByGuarantorId(String guarantorId) {
    	List<Encounter__c> encounterList = EncounterDao.getEncounterRecordsById(EncounterDao.IdType.GUARANTOR, guarantorId);
        return encounterList;
    }

    /**
     * This method is use to update Billed CG Count in Encounters.
     *
     * @param List<Encounter__c> encounters - That contains list of Encounters.
     **/
    public static void updateBilledCGCount(List<Encounter__c> encounters) {
        EncounterDao.updateBilledCGCount(encounters);
    }
}