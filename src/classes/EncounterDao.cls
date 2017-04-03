/**
 * Payment DAO for Encounter__c object SOQL/DML operations
 */
public class EncounterDao {
    public enum ConditionObject {
        GUARANTOR, ENCOUNTER
    }
    
	/**
	 * This method is use to get Encounter Records based on Guarantor Id or Id and Balance is greater than zero.
     * @param ConditionObject objectName - object name for where condition
     * @param String condId - record Id
	 **/
    public static List<Encounter__c> getEncounterRecordsById(ConditionObject objectName, String condId) {
    	String queryString = 'SELECT Id, Name, Patient__c, Date_of_Service__c, Procedure__c, Location__c,Patient_Portion__c, Guarantor__c, Balance__c ';
    	queryString += ' FROM Encounter__c ';
    	queryString += ' WHERE Balance__c > 0 ';
    	queryString += (objectName == ConditionObject.GUARANTOR) ? ' AND Guarantor__c = :condId' : ' AND Id = :condId';
    	List<Encounter__c> encounterList = Database.query(queryString);
        return encounterList;
    }
}