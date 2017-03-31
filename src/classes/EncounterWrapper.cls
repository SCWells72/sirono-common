/**
 * This Wrapper class is use to check how many Encounters select or which encounter select for Payment Process.
 **/
public class EncounterWrapper {
	public Encounter__c en {get; set;}
	public Boolean isSelected {get; set;}

	/**
	 * This method is use to get Encounter Records based on Guarantor Id or Id and Balance is greater than zero.
	 * These records add into List of Encounter Wrapper Class.
	 * @param String idType - object name for where condition
	 * @param String condId - record Id
	 * @return List<EncounterWrapper> - list of encounter wrapper records
	 **/
	public static List<EncounterWrapper> getEncounterRecords(String idType, String condId) {
		List<EncounterWrapper> encounters = new List<EncounterWrapper>();
		List<Encounter__c> encounterList = EncounterService.getEncounterRecordsById(idType, condId);
		for (Encounter__c en : encounterList) {
		    encounters.add(new EncounterWrapper(en, false));
		}
		return encounters;
	}

	/**
	 * Constructor of Wrapper Class.
	 *
	 * @param Encounter__c en - encounter record
	 * @param Boolean isSelected - check if record is selected or not
	 **/
	public EncounterWrapper(Encounter__c en, Boolean isSelected) {
		this.en = en;
		this.isSelected = isSelected;
	}
}