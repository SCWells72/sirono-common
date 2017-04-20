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
}