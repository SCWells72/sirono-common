/**
 * GuarantorService
 */

public with sharing class GuarantorService extends AbstractService {

    //Get the Guarantor's Profile_Pointer_Id__c from the given contact.
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

    //Cet the Guarantor details string from the given contact.
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
}