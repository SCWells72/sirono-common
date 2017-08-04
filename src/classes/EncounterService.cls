/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

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

    /**
	 * This method is use to get Encounters based on Guarantor
	 * optional filter limits the returned Encounters to only that subset
	 * optional list of Ids limits the results to those for the given patient Ids.
     * @param Contact - the guarantor to retrieve Encounter__c for
     * @param String paidFilter - filter to return only 'Paid', 'Unpaid' encounters. If null == 'All'
     * @param List<String> patientIds - limit the returned Encounter__c records to those associated with these patients
	 **/
    public static List<Encounter__c> getEncountersByGuarantor(Contact guarantor, String paidFilter, List<String> patientIds) {
        EncounterDao.ElevatedPrivilegesHelper helper = new EncounterDao.ElevatedPrivilegesHelper();
        return helper.getAllEncounters(guarantor, paidFilter, patientIds);
    }

    /**
     * Return the patient MRN and Name for all encounters for the given guarantor
     *
     * @param Contact - the guarantor to retrieve Encounter__c for
     *
     */
    public static List<Encounter__c> getAllPatients(Contact guarantor) {
        return EncounterDao.getAllPatients(guarantor);
    }

    /**
     * This method is used to get a count of Encounters found for the Contact from the
     * provided startDate to now.
     *
     * @param Integer - The number of Encounters.
     **/
    public static Integer getCountByDate(Id guarantorId, Datetime startDate) {
        return EncounterDao.getCountByDate(guarantorId, startDate);
    }

    /**
     * Get a list of encounters for a particular invoice.
     *
     * @param Id contanctId - The Guarantor for the Encounter.
     * @param String invoiceId - The invoiceId associated with the Encounter.
     * @returns List<Encounter__c> - The list of encounters.
     */
    public static List<Encounter__c> getForInvoice(Id contactId, String invoiceId) {
        return EncounterDao.getForInvoice(contactId, invoiceId);
    }
}