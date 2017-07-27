/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Access Guarantor contact data
 * TODO when we create a PatientDao, pull up a virtual ContactDao with common functionality
 * TODO fix our sharing model for Guarantors
 */
public with sharing class GuarantorDao extends AbstractDao {

    public static Contact getGuarantor(String recordId) {
        if (ContactSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            Contact gt = [
                SELECT Id, FirstName, MiddleName, LastName, Suffix, Birthdate,
                    Medical_Record_Number__c, Name,
                    Profile_Pointer_ID__c, MailingStreet,
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
                    Profile_Pointer_ID__c, MailingStreet,
                    MailingCity, MailingState, MailingPostalCode, RecordTypeId
                FROM Contact
                WHERE RecordTypeId = :RecordTypeUtil.guarantorRt
                AND Profile_Pointer_ID__c = :Decimal.valueOf(sironoId)
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
                    Profile_Pointer_ID__c, MailingStreet,
                    MailingCity, MailingState, MailingPostalCode, RecordTypeId, (
                    SELECT Id, Name, Sirono_ID__c, Guarantor__c, Guarantor__r.Name,
                        External_ID__c, Active__c, Reported_Insurance_Balance__c, Reported_Prebill_Balance__c,
                        Reported_Selfpay_Balance__c, Patient__c, Patient__r.Name,
                        Account_Type__c, Date_Of_Service_Start_Date__c, Date_Of_Service_End_Date__c,
                        Balance__c, Invoice__c, Invoice__r.Name, Invoice__r.Invoice_Date__c, Account_Status__c,
                        Provider__c, Provider__r.Name, Location__c, Location__r.Name, Account_Sub_Status__c
                    FROM Charge_Groups__r
                    WHERE Sirono_ID__c != NULL
                    AND Active__c = TRUE
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
            for (Contact c : [
                SELECT Id, Name, FirstName, MiddleName, LastName, Suffix, Birthdate, Salutation,
                    Medical_Record_Number__c, RecordType.DeveloperName, Social_Security_Number__c,
                    Profile_Pointer_ID__c, Patient_Id__c, HomePhone, MobilePhone, OtherPhone,
                    MailingCity, MailingCountry, MailingPostalCode, MailingState, MailingStreet, RecordTypeId, (
                    SELECT Id, Name, Sirono_ID__c, Guarantor__c, Guarantor__r.Name,
                        External_ID__c, Active__c, Reported_Insurance_Balance__c, Reported_Prebill_Balance__c,
                        Reported_Selfpay_Balance__c, Patient__c, Patient__r.Name,
                        Account_Type__c, Date_Of_Service_Start_Date__c, Date_Of_Service_End_Date__c,
                        Balance__c, Invoice__c, Invoice__r.Name, Invoice__r.Invoice_Date__c, Account_Status__c,
                        Account_Sub_Status__c, Provider__c, Provider__r.Name, Location__c, Location__r.Name
                    FROM Charge_Groups__r
                    WHERE Sirono_ID__c != NULL
                    AND Active__c = TRUE
                    AND Account_Status__c = :Constants.ACCT_STATUS_BILLED
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

    /**
     * Get Contacts with Charge Groups filtered by Pre_Collection_Sent__c and contactIds
     *
     * @param Set<Id> contactIds - A set of Contact Ids.
     * @returns List<Contact> - The requested Contacts and all Charge Groups that meet the criteria.
     **/
    public static List<Contact> getGuarantorsWithCG(Set<Id> contactIds) {
        if (ContactSecurityContext.CU_SELECT_CONTEXT.actionAllowed() &&
            ChargeGroupSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            return [
                SELECT Id, Overdue_Balance__c, Delinquent_Balance__c, (
                    SELECT Id, Pre_Collection_Sent__c
                    FROM Charge_Groups__r
                    WHERE Pre_Collection_Sent__c != NULL
                )
                FROM Contact
                WHERE Id IN :contactIds
            ];
        }
        return null;
    }

    /**
     * Get Contacts with Payment Plans filtered by Delinquent_Date__c, Active__c and contactIds
     *
     * @param Set<Id> contactIds - A set of Contact Ids.
     * @returns List<Contact> - The requested Contacts and all Payment Plans that meet the criteria.
     **/
    public static List<Contact> getGuarantorsWithPmtPlan(Set<Id> contactIds) {
        if (ContactSecurityContext.CU_SELECT_CONTEXT.actionAllowed() &&
            PaymentPlanSecurityContext.CLU_SELECT_CONTEXT.actionAllowed()) {
            return [
                SELECT Id, (
                    SELECT Id, Delinquent_Date__c, Active__c
                    FROM Payment_Plans__r
                    WHERE Delinquent_Date__c != NULL
                    OR Active__c = TRUE
                )
                FROM Contact
                WHERE Id IN :contactIds
            ];
        }
        return null;
    }

    /**
     * Get Contacts with Encounters filtered by Liability__c, Date_of_Service__c, Cancelled__c and contactIds
     *
     * @param Set<Id> contactIds - A set of Contact Ids.
     * @returns List<Contact> - The requested Contacts and all Encounters that meet the criteria.
     **/
    public static List<Contact> getGuarantorsWithEncounters(Set<Id> contactIds) {
        if (ContactSecurityContext.CU_SELECT_CONTEXT.actionAllowed() &&
            EncounterSecurityContext.CLU_SELECT_CONTEXT.actionAllowed()) {
            return [
                SELECT Id, (
                    SELECT Id, Date_of_Service__c, Liability__c, Cancelled__c
                    FROM Encounters__r
                    WHERE Liability__c < 100
                    OR Date_of_Service__c != TODAY
                    OR Cancelled__c = FALSE
                )
                FROM Contact
                WHERE Id IN :contactIds
            ];
        }
        return null;
    }

    /**
     * Get Contacts based on filterBy and contactIds
     *
     * @param Set<String> contactIds - A set of Contact Ids.
     * @param String filterBy - That contains filter value.
     * @returns List<Contact> - The requested Contacts that meet the criteria.
     **/
    public static List<Contact> getGuarantorsByFilter(Set<String> contactIds, String filterBy) {
        if (ContactSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
            String queryString = 'SELECT Id, Name, Statement_Preference__c, Overdue_Balance__c, Delinquent_Balance__c, ';
            queryString += 'RecordType.DeveloperName, HomePhone, MobilePhone, OtherPhone ';
            queryString += 'FROM Contact ';
            queryString += 'WHERE Id IN :contactIds ';
            queryString += (filterBy == CaseUtil.Overdue_Bal_GT) ? 'AND Overdue_Balance__c > 0' : '';
            queryString += (filterBy == CaseUtil.Overdue_Bal_LT) ? 'OR Overdue_Balance__c <= 0' : '';
            queryString += (filterBy == CaseUtil.Delinquent_Bal_GT) ? 'AND Delinquent_Balance__c > 0' : '';
            queryString += (filterBy == CaseUtil.Delinquent_Bal_LT) ? 'OR Delinquent_Balance__c < 0' : '';

            return Database.query(queryString);
        }

        return null;
    }

    /**
     * Get Contacts with Phone Types and Numbers filtered by contactIds
     *
     * @param Set<Id> contactIds - A set of Contact Ids.
     * @returns List<Contact> - The requested Contacts that meet the criteria.
     **/
    public static List<Contact> getGuarantorsWithNumbers(Set<Id> contactIds) {
        if (ContactSecurityContext.CTH_SELECT_CONTEXT.actionAllowed()) {
            return [
                SELECT Id, OtherPhone, MobilePhone, HomePhone, Home_Phone_Type__c,
                    Mobile_Phone_Type__c, Other_Phone_Type__c, CTINumber1__c, CTINumber2__c, CTINumber3__c
                FROM Contact
                WHERE Id IN :contactIds
            ];
        }
        return null;
    }

    /**
     * Get query for Contacts based on filterBy and contactIds
     *
     * @returns String - That contains query in a string.
     **/
    public static String getBatchContactsQuery() {
        if (ContactSecurityContext.SB_SELECT_CONTEXT.actionAllowed()) {
            String queryString = 'SELECT Id, FirstName, LastName ';
            queryString += 'FROM Contact ';
            queryString += 'WHERE RecordType.Name = \'Guarantor\' AND ID NOT IN :existingMembers';

            return queryString;
        }

        return null;
    }

    /**
     * Get a query that will return no results for use in batch APEX as the QueryLocator value when you want to get no
     * results.
     *
     * @returns String - A contact query string that will return no results.
     */
    public static String getNoContactsQuery() {
        if (ContactSecurityContext.SB_SELECT_CONTEXT.actionAllowed()) {
            // Limit 0 ensures a zero result response.
            return 'SELECT Id, FirstName, LastName From Contact Limit 0';
        }

        return null;
    }

    /**
     * Get Contacts with Statement filtered by guarantors
     *
     * @param List<Contact> guarantors - A list of Contacts.
     * @returns List<Contact> - The requested Contacts and Statement that meet the criteria.
     **/
    public static List<Contact> getGuarantorsWithStatement(List<Contact> guarantors) {
        if (ContactSecurityContext.CU_SELECT_CONTEXT.actionAllowed() &&
            StatementSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            return [
                SELECT Id, (
                    SELECT Id, Name, Statement_Date__c
                    FROM Statements__r
                    ORDER BY Statement_Date__c DESC
                    LIMIT 1
                )
                FROM Contact
                WHERE Id IN :guarantors
            ];
        }
        return null;
    }

    /**
     * Get Contacts based on contactIds.
     *
     * @param Set<Id> contactIds - A set of Contact Ids.
     * @returns List<Contact> - The requested Contacts that meet the criteria.
     **/
    public static List<Contact> getContactsForLightning(Set<Id> contactIds) {
        return [
            SELECT Id, FirstName, Guarantor__c, Guarantor_Status__c, Invoiced_Balance__c,
                Overdue_Invoices__c, Outstanding_Invoices__c, Delinquent_Invoices__c, Add_to_Payment_Plan__c
            FROM Contact
            WHERE Id IN :contactIds
        ];
    }

    /**
     * Get Contact based on Id.
     *
     * @param Id contactId - That contains Id of Contact.
     * @returns Contact gt - The requested Contact based on Id.
     **/
    public static Contact getContactById(Id contactId) {
        Contact gt = [
            SELECT Id, Profile_Pointer_ID__c
            FROM Contact
            WHERE Id = :contactId
            LIMIT 1
        ];
        return gt;
    }

    /**
     * Get Contacts with Invoice_Offset_Date__c field filtered by contactIds
     *
     * @param Set<Id> contactIds - A set of Contact Ids.
     * @returns List<Contact> - The requested Contacts that meet the criteria.
     **/
    public static List<Contact> getGuarantorsWithInvoiceOffsetDt(Set<Id> contactIds) {
        if (ContactSecurityContext.PPTH_SELECT_CONTEXT.actionAllowed()) {
            return [
                SELECT Id, Invoice_Offset_Date__c
                FROM Contact
                WHERE Id IN :contactIds
            ];
        }
        return null;
    }

    /**
     * Get the Guarantor contact with all active charge groups for Lightning.
     *
     * @param String contactId - That contains Id of Contact.
     * @returns Contact contact - That contains contact details with all active CGs based on contactId.
     **/
    public static Contact getGuarantorWithActiveCGForLightning(String contactId) {
        Contact contact = null;
        for (Contact c : [
            SELECT Id, FirstName, MiddleName, LastName, Suffix, Birthdate,
                Medical_Record_Number__c, Name, Add_to_Payment_Plan__c,
                Non_Payment_Plan_Invoices__c, Profile_Pointer_ID__c, MailingStreet,
                MailingCity, MailingState, MailingPostalCode, (
                SELECT Id, Name, Sirono_ID__c, Guarantor__c, Guarantor__r.Name,
                    External_ID__c, Active__c, Reported_Insurance_Balance__c, Reported_Prebill_Balance__c,
                    Reported_Selfpay_Balance__c, Patient__c, Patient__r.Name,
                    Account_Type__c, Date_Of_Service_Start_Date__c, Date_Of_Service_End_Date__c,
                    Balance__c, Invoice__c, Invoice__r.Name, Invoice__r.Invoice_Date__c, Account_Status__c,
                    Provider__c, Provider__r.Name, Location__c, Location__r.Name, Account_Sub_Status__c
                FROM Charge_Groups__r
                WHERE Sirono_ID__c != NULL
                AND Active__c = TRUE
            )
            FROM Contact
            WHERE Id = :contactId
        ]) {
            contact = c;
        }
        return contact;
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
        if (ContactSecurityContext.SB_SELECT_CONTEXT.actionAllowed() &&
            TaskSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            String queryString = 'SELECT Id, FirstName, LastName, ';
            queryString += '( ';
            queryString += 'SELECT Id, CallDisposition, Five9__Five9Campaign__c, WhatId ';
            queryString += 'FROM Tasks ';
            queryString += (caseIds != null) ? 'WHERE WhatId IN :caseIds AND CallDisposition != null AND WhoId != null ' : 'WHERE CallDisposition IN :callDispositions ';
            queryString += 'AND Five9__Five9Campaign__c IN :five9Campaigns';
            queryString += ') ';
            queryString += 'FROM Contact ';
            queryString += 'WHERE Id IN :contactIds';

            return Database.query(queryString);
        }

        return null;
    }

    /**
     * This method is use to update Contacts.
     *
     * @param List<Contact> contacts - That contains Guarantor/Contact records.
     **/
    public static void updateGuarantors(List<Contact> contacts) {
        if (ContactSecurityContext.CTH_UPDATE_CONTEXT.actionAllowed()) {
            update contacts;
        }
    }

    /**
     * This method is use to update Contacts with Estimate_Balance.
     *
     * @param List<Contact> contacts - That contains Guarantor/Contact records.
     **/
    public static void updateGuarantorsWithEstimateBal(List<Contact> contacts) {
        if (ContactSecurityContext.UPDATE_CONTEXT.actionAllowed()) {
            update contacts;
        }
    }
}