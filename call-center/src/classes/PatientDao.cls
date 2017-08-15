/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Access Patient Contact Data.
 * This class is use to get Patient Contact related details.
 **/
public with sharing class PatientDao extends AbstractDao {

    /**
     * Get Patient Contact details filtered by Id.
     *
     * @param String recordId - That contains Contact Id.
     * @returns Contact pc - That contains Patient Contact details.
     **/
    public static Contact getPatientContact(String recordId) {
        if (ContactSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            Contact pc = [
                SELECT Id, FirstName, MiddleName, LastName, Suffix, Birthdate,
                    Medical_Record_Number__c, Name,
                    Patient_Id__c, MailingStreet,
                    MailingCity, MailingState, MailingPostalCode, RecordTypeId
                FROM Contact
                WHERE Id = :recordId AND RecordTypeId = :RecordTypeUtil.patientRt
                LIMIT 1
            ];
            return pc;
        }
        return null;
    }

    /**
     * Get Contact details with active Charge Groups filtered by Account Sub Status
     *
     * @param String contactId - The Contact RecordId.
     * @param Set<String> cgSubStatusFilters - A set of CG Account Sub Statuses.
     * @returns Contact contact - The requested Contact and all active Charge Groups that meet the criteria
     **/
    public static Contact getPatientFilterCGByAcctSubStatus(String contactId, Set<String> cgSubStatusFilters) {
        Contact contact = null;
        if (ContactSecurityContext.SELECT_CONTEXT.actionAllowed() &&
            ChargeGroupSecurityContext.GD_SELECT_CONTEXT.actionAllowed()) {
            for (Contact c : [
                SELECT Id, FirstName, MiddleName, LastName, Suffix, Birthdate,
                    Medical_Record_Number__c, RecordType.DeveloperName,
                    Profile_Pointer_Id__c, Patient_Id__c, (
                    SELECT Id, Name, Sirono_Id__c, Guarantor__c, Guarantor__r.Name,
                        External_Id__c, Active__c, Reported_Insurance_Balance__c, Reported_Prebill_Balance__c,
                        Reported_Selfpay_Balance__c, Patient__c, Patient__r.Name,
                        Account_Type__c, Date_Of_Service_Start_Date__c, Date_Of_Service_End_Date__c,
                        Balance__c, Invoice__c, Invoice__r.Name, Invoice__r.Date__c, Account_Status__c,
                        Account_Sub_Status__c, Provider__c, Provider__r.Name, Location__c, Location__r.Name
                    FROM Charge_Groups_Patient__r
                    WHERE Sirono_Id__c != NULL AND Active__c = TRUE AND Account_Status__c = :Constants.ACCT_STATUS_BILLED
                    AND Account_Sub_Status__c IN :cgSubStatusFilters
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