/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Access Contact Data.
 * This class is use to get Contact related details (Not based on record types).
 **/
public with sharing class ContactDao extends AbstractDao {

    /**
     * Get Contact details filtered by Id.
     *
     * @param String contactId - That contains Contact Id.
     * @returns Contact ob - That contains Contact details.
     **/
    public static Contact getContactDetails(String contactId) {
        Contact ob = null;
        if (ContactSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            for (Contact c : [
                SELECT Id, FirstName, MiddleName, LastName, Name, Suffix, Birthdate, Social_Security_Number__c,
                    Medical_Record_Number__c, RecordType.DeveloperName, HomePhone, MobilePhone, OtherPhone, Salutation,
                    MailingCity, MailingCountry, MailingPostalCode, MailingState, MailingStreet,
                    Profile_Pointer_ID__c
                FROM Contact
                WHERE Id = :contactId
            ]) {
                ob = c;
            }
        }
        return ob;
    }
}