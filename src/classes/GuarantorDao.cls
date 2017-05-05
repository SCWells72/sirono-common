/**
 * Access Guarantor contact data
 * TODO when we create a PatientDao, pull up a virtual ContactDao with common functionality
 */

public with sharing class GuarantorDao extends AbstractDao {

    public static Contact getGuarantor(String recordId) {
        if (ContactSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            Contact gt = [
                    SELECT Id, FirstName, MiddleName, LastName, Suffix, Birthdate,
                            Medical_Record_Number__c, Name,
                            Profile_Pointer_Id__c, MailingStreet,
                            MailingCity, MailingState, MailingPostalCode, RecordTypeId
                    FROM Contact
                    WHERE Id = :recordId AND RecordTypeId = :RecordTypeUtil.guarantorRt
                    LIMIT 1
            ];
            return gt;
        }
        return null;
    }

    public static Contact getGuarantorBySironoId(String sironoId) {
        if (ContactSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            Contact gt = [
                    SELECT Id, FirstName, MiddleName, LastName, Suffix, Birthdate,
                            Medical_Record_Number__c, Name,
                            Profile_Pointer_Id__c, MailingStreet,
                            MailingCity, MailingState, MailingPostalCode, RecordTypeId
                    FROM Contact
                    WHERE RecordTypeId = :RecordTypeUtil.guarantorRt
                    AND Profile_Pointer_Id__c = :Decimal.valueOf(sironoId)
                    LIMIT 1
            ];
            return gt;
        }
        return null;
    }

    //get the Guarantor contact with all active charge groups
    public static Contact getGuarantorWithActiveCG(String contactId) {
        Contact ob = null;
        if (ContactSecurityContext.SELECT_CONTEXT.actionAllowed() &&
                ChargeGroupSecurityContext.GD_SELECT_CONTEXT.actionAllowed()) {
            for (Contact c : [
                    SELECT Id, FirstName, MiddleName, LastName, Suffix, Birthdate,
                            Medical_Record_Number__c, Name,
                            Profile_Pointer_Id__c, MailingStreet,
                            MailingCity, MailingState, MailingPostalCode, RecordTypeId,
                    (
                            SELECT Id, Name, Sirono_ID__c, Guarantor__c, Guarantor__r.Name,
                                    External_ID__c, Active__c, Reported_Insurance_Balance__c, Reported_Prebill_Balance__c,
                                    Reported_Selfpay_Balance__c, Patient__c, Patient__r.Name,
                                    Account_Type__c, Date_Of_Service_Start_Date__c, Date_Of_Service_End_Date__c,
                                    Balance__c, Invoice__c, Invoice__r.Name, Invoice__r.Invoice_Date__c, Account_Status__c,
                                    Provider__c, Provider__r.Name, Location__c, Location__r.Name, Account_Sub_Status__c
                            FROM Charge_Groups__r
                            WHERE Sirono_ID__c != null
                            AND Active__c = true
                    )
                    FROM Contact
                    WHERE Id = :contactId
            ]) {
                ob = c;
            }
        }
        return ob;
    }

    /**
     * Get Contact details with active Charge Groups filtered by Account Sub Status
     *
     * @param String contactId - The Contact RecordId.
     * @param Set<String> cgSubStatusFilters - A set of CG Account Sub Statuses.
     * @returns Contact contact - The requested Contact and all active Charge Groups that meet the criteria
     **/
    public static Contact getGuarantorFilterCGByAcctSubStatus(String contactId, Set<String> cgSubStatusFilters) {
        Contact contact = null;
        if (ContactSecurityContext.SELECT_CONTEXT.actionAllowed() &&
                ChargeGroupSecurityContext.GD_SELECT_CONTEXT.actionAllowed()) {
            for (Contact c: [
                    SELECT Id, Name, FirstName, MiddleName, LastName, Suffix, Birthdate, Salutation,
                            Medical_Record_Number__c, RecordType.DeveloperName, Social_Security_Number__c,
                            Profile_Pointer_Id__c, Patient_Id__c, HomePhone, MobilePhone, OtherPhone,
                            MailingCity, MailingCountry, MailingPostalCode, MailingState, MailingStreet, RecordTypeId,
                        (
                            SELECT Id, Name, Sirono_ID__c, Guarantor__c, Guarantor__r.Name,
                                    External_ID__c, Active__c, Reported_Insurance_Balance__c, Reported_Prebill_Balance__c,
                                    Reported_Selfpay_Balance__c, Patient__c, Patient__r.Name,
                                    Account_Type__c, Date_Of_Service_Start_Date__c, Date_Of_Service_End_Date__c,
                                    Balance__c, Invoice__c, Invoice__r.Name, Invoice__r.Invoice_Date__c, Account_Status__c,
                                    Account_Sub_Status__c, Provider__c, Provider__r.Name, Location__c, Location__r.Name
                            FROM Charge_Groups__r
                            WHERE Sirono_ID__c != null
                            AND Active__c = true
                            AND Account_Status__c = 'Billed'
                            AND Account_Sub_Status__c IN :cgSubStatusFilters
							AND Balance__c != 0
                        )
                    FROM Contact
                    WHERE Id = :contactId
            ]) {
                contact = c;
            }
        }
        return contact;
    }
}