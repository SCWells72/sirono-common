/**
 * Payment DAO for Encounter__c object SOQL/DML operations
 */
public class EncounterDao {
    public enum IdType {
        GUARANTOR, ENCOUNTER
    }
    
	/**
	 * This method is use to get Encounter Records based on Guarantor Id or Id and Balance is greater than zero.
     * @param IdType objectName - object name for where condition
     * @param String condId - record Id
	 **/
    public static List<Encounter__c> getEncounterRecordsById(IdType objectName, String condId) {
        if (EncounterSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            String queryString = 'SELECT Id, Name, Patient__c, Date_of_Service__c, Procedure__c, Location__c, Patient_Portion__c, Guarantor__c, Balance__c ';
            queryString += ' FROM Encounter__c ';
            queryString += ' WHERE Balance__c > 0 ';
            queryString += (objectName == IdType.GUARANTOR) ? ' AND Guarantor__c = :condId' : ' AND Id = :condId';
            List<Encounter__c> encounterList = Database.query(queryString);
            return encounterList;
        }
        return null;
    }

    /**
     * This method is use to update Billed CG Count in Encounters.
     *
     * @param List<Encounter__c> encounters - That contains list of Encounters.
     **/
    public static void updateBilledCGCount(List<Encounter__c> encounters) {
        if (EncounterSecurityContext.UPDATE_BILLED_CG_COUNT_CONTEXT.actionAllowed()) {
            UPDATE encounters;
        }
    }

    /**
     * Get the number of Encounters for a contact from a startdate to now.
     *
     * @returns Integer - The number of Encounters found.
     */
    public static Integer getCountByDate(Id contactId, DateTime startDate) {
        if (EncounterSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            return [
                SELECT
                    COUNT()
                FROM Encounter__c
                WHERE Guarantor__c = :contactId AND
                CreatedDate >= :startDate
            ];
        }
        return null;
    }
}