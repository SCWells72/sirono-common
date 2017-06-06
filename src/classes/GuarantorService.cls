/**
 * GuarantorService
 **/
public with sharing class GuarantorService extends AbstractService {
    /**
     * Get the Guarantor's Profile_Pointer_Id__c from the given contact.
     * @param Contact contact - the Guarantor Contact
     * @returns String - the guarantor's sironoId
     * @throws SironoServiceException if the contact doesn't exist
     **/
    public static String getGuarantorSironoId(Contact contact) {
        String guarantorId = '';
        if (contact == null) {
            throw new SironoServiceException('Invalid request - Contact required to retrieve SironoId');
        }
        if (contact.Profile_Pointer_Id__c != null) {
            return contact.Profile_Pointer_Id__c.toPlainString();
        } else {
            Contact gt = GuarantorDao.getGuarantor(contact.Id);
            if (gt != null) {
                guarantorId = gt.Profile_Pointer_ID__c.toPlainString();
            } else {
                throw new SironoServiceException('Guarantor not found');
            }
        }
        return guarantorId;
    }

    /**
     * Get the Guarantor details string from the given contact.
     *
     * @param Contact gc - a Guarantor Contact TODO (Is this applicable to any Sirono Contact?)
     * @returns String - a formatted string of the Guarantor's PII
     **/
    public static String buildGuarantorDetailString(Contact gc) {
        String details = '';
        details = gc.FirstName + (gc.MiddleName != null ? ' ' + gc.MiddleName : '')
                + (gc.LastName != null ? ' ' + gc.LastName : '')
                + (gc.Suffix != null ? ' ' + gc.Suffix : '')
                + ' (DOB: ' + (gc.Birthdate != null ? gc.Birthdate.format() : '')
                + ', MRN: ' + (gc.Medical_Record_Number__c != null ? gc.Medical_Record_Number__c : '')
                + ')';

        return details;
    }

    public static Contact getGuarantorFilterCGByAcctSubStatus(String guarantorRecordId){
        return GuarantorDao.getGuarantorFilterCGByAcctSubStatus(guarantorRecordId, Constants.CGConstraints);
    }

    /**
     * Get Contact details with active Charge Groups filtered by Account Sub Status
     *
     * @param String contactId - The Contact RecordId.
     * @param Set<String> cgSubStatusFilters - A set of CG Account Sub Statuses.
     * @returns Contact contact - The requested Contact and all active Charge Groups that meet the criteria
     **/
    public static Contact getGuarantorFilterCGByAcctSubStatus(String contactId, Set<String> cgSubStatusFilters) {
        return GuarantorDao.getGuarantorFilterCGByAcctSubStatus(contactId, cgSubStatusFilters);
    }

    /**
     * Get Guarantor Contact by sirono Id
     *
     * @param String guarantor's sirono Id
     * @return Contact - the requested Contact
     **/
    public static Contact getGuarantorBySironoId(String sironoId) {
        return GuarantorDao.getGuarantorBySironoId(sironoId);
    }

    /**
     * Get Guarantor Contact by record Id
     *
     * @param String guarantor's record Id
     * @return Contact - the requested Contact
     **/
    public static Contact getGuarantor(String recordId) {
        return GuarantorDao.getGuarantor(recordId);
    }

    /**
     * Get Guarantor Contact by record Id and all it's active charge groups
     *
     * @param String guarantor's record Id
     * @return Contact - the requested Contact
     **/
    public static Contact getGuarantorWithActiveCG(String recordId) {
        return GuarantorDao.getGuarantorWithActiveCG(recordId);
    }

    /**
     * Get Contacts with Charge Groups filtered by Pre_Collection_Sent__c and contactIds
     *
     * @param Set<Id> contactIds - A set of Contact Ids.
     * @returns List<Contact> - The requested Contacts and all Charge Groups that meet the criteria.
     **/
    public static List<Contact> getGuarantorsWithCG(Set<Id> contactIds) {
        return GuarantorDao.getGuarantorsWithCG(contactIds);
    }

    /**
     * Get Contacts with Payment Plans filtered by Delinquent_Date__c, Active__c and contactIds
     *
     * @param Set<Id> contactIds - A set of Contact Ids.
     * @returns List<Contact> - The requested Contacts and all Payment Plans that meet the criteria.
     **/
    public static List<Contact> getGuarantorsWithPmtPlan(Set<Id> contactIds) {
        return GuarantorDao.getGuarantorsWithPmtPlan(contactIds);
    }

    /**
     * Get Contacts with Encounters filtered by Liability__c, Date_of_Service__c, Cancelled__c and contactIds
     *
     * @param Set<Id> contactIds - A set of Contact Ids.
     * @returns List<Contact> - The requested Contacts and all Encounters that meet the criteria.
     **/
    public static List<Contact> getGuarantorsWithEncounters(Set<Id> contactIds) {
        return GuarantorDao.getGuarantorsWithEncounters(contactIds);
    }

    /**
     * Get Contacts based on filterBy and contactIds
     *
     * @param Set<String> contactIds - A set of Contact Ids.
     * @param String filterBy - That contains filter value.
     * @returns List<Contact> - The requested Contacts that meet the criteria.
     **/
    public static List<Contact> getGuarantorsByFilter(Set<String> contactIds, String filterBy) {
        return GuarantorDao.getGuarantorsByFilter(contactIds, filterBy);
    }

    /**
     * Get Contacts based on filterBy and contactIds
     *
     * @param Set<Id> contactIds - A set of Contact Ids.
     * @param String filterBy - That contains filter value.
     * @returns List<Contact> - The requested Contacts that meet the criteria.
     **/
    public static List<Contact> getGuarantorsByFilter(Set<Id> contactIds, String filterBy) {
        // Convert the set of Ids into a Set of Strings.
        Set<String> stringIds = (Set<String>)JSON.deserialize(JSON.serialize(contactIds), Set<String>.class);
        return GuarantorDao.getGuarantorsByFilter(stringIds, filterBy);
    }

    /**
     * Get Contacts with Phone Types and Numbers filtered by contactIds
     *
     * @param Set<Id> contactIds - A set of Contact Ids.
     * @returns List<Contact> - The requested Contacts that meet the criteria.
     **/
    public static List<Contact> getGuarantorsWithNumbers(Set<Id> contactIds) {
        return GuarantorDao.getGuarantorsWithNumbers(contactIds);
    }

    /**
     * Get Contacts based on filterBy and contactIds
     *
     * @returns String - That contains query in a string.
     **/
    public static String getContactsByRecordType() {
        return GuarantorDao.getContactsByRecordType();
    }

    /**
     * Get a queryString that will result in no results.
     *
     * @returns String - A query string that will result in zero records.
     */
    public static String getConactsNoResults() {
        return GuarantorDao.getContactsNoResults();
    }

    /**
     * Get Contacts with Statement filtered by guarantors
     *
     * @param List<Contact> guarantors - A list of Contacts.
     * @returns List<Contact> - The requested Contacts and Statement that meet the criteria.
     **/
    public static List<Contact> getGuarantorsWithStatement(List<Contact> guarantors) {
        return GuarantorDao.getGuarantorsWithStatement(guarantors);
    }

    /**
     * Get Contacts based on contactIds.
     *
     * @param Set<Id> contactIds - A set of Contact Ids.
     * @returns List<Contact> - The requested Contacts that meet the criteria.
     **/
    public static List<Contact> getContactsForLightning(Set<Id> contactIds) {
        return GuarantorDao.getContactsForLightning(contactIds);
    }

    /**
     * Get Contact based on Id.
     *
     * @param Id contactId - That contains Id of Contact.
     * @returns Contact - The requested Contact based on Id.
     **/
    public static Contact getContactById(Id contactId) {
        return GuarantorDao.getContactById(contactId);
    }

    /**
     * Get Contacts with Invoice_Offset_Date__c field filtered by contactIds
     *
     * @param Set<Id> contactIds - A set of Contact Ids.
     * @returns List<Contact> - The requested Contacts that meet the criteria.
     **/
    public static List<Contact> getGuarantorsWithInvoiceOffsetDt(Set<Id> contactIds) {
        return GuarantorDao.getGuarantorsWithInvoiceOffsetDt(contactIds);
    }

    /**
     * Get the Guarantor contact with all active charge groups for Lightning.
     *
     * @param String contactId - That contains Id of Contact.
     * @returns Contact contact - That contains contact details with all active CGs based on contactId.
     **/
    public static Contact getGuarantorWithActiveCGForLightning(String contactId) {
        return GuarantorDao.getGuarantorWithActiveCGForLightning(contactId);
    }

    /**
     * Get Contacts with Task based on contactIds, caseIds, five9Campaigns and callDispositions
     *
     * @param Set<Id> contactIds - A set of Contact Ids.
     * @param Set<Id> caseIds - A set of Case Ids.
     * @param Set<String> five9Campaigns - That contains five9Campaign names.
     * @param Set<String> callDispositions - That contains call disposition values.
     * @returns List<Contact> - The requested Contacts with Task that meet the criteria.
     **/
    public static List<Contact> getGuarantorsWithTask(Set<Id> contactIds, Set<Id> caseIds, Set<String> five9Campaigns, Set<String> callDispositions) {
        return GuarantorDao.getGuarantorsWithTask(contactIds, caseIds, five9Campaigns, callDispositions);
    }

    /**
     * This method is use to update Contacts.
     *
     * @param List<Contact> contacts - That contains Guarantor/Contact records.
     **/
    public static void updateGuarantors(List<Contact> contacts) {
        GuarantorDao.updateGuarantors(contacts);
    }

    /**
     * This method is use to update Contacts with Estimate_Balance.
     *
     * @param List<Contact> contacts - That contains Guarantor/Contact records.
     **/
    public static void updateGuarantorsWithEstimateBal(List<Contact> contacts) {
        GuarantorDao.updateGuarantorsWithEstimateBal(contacts);
    }
}