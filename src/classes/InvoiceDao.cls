/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Invoice DAO
 * TODO sharing model
 */
public with sharing class InvoiceDao extends AbstractDao {

  /**
   * Get an Invoice__c returned as a List with a partical status.
   *
   * @return List<Invoice__c> - A list containing the most recent Invoice if found.
   */
    public static List<Invoice__c> getByStatus(Id guarantorId, String status) {
        if (InvoiceSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            return [
                SELECT
                    Id,
                    Due_Date__c
                FROM Invoice__c
                WHERE Guarantor__c = :guarantorId
                AND Status__c = :status
                ORDER BY CreatedDate
                LIMIT 1
            ];
        }
        return null;
    }

    /**
     * Get the list of Invoice__c objects for a particular invoice id.
     *
     * @param Id contanctId - The guarantor id.
     * @param String invoiceId - The invoice Id.
     * @returns List<Invoice__c> - The list of Invoice__c objects.
     */
    public static List<Invoice__c> getById(Id contactId, String invoiceId) {

        if (InvoiceSecurityContext.DETAIL_CONTEXT.actionAllowed() && ChargeGroupSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            return [
                SELECT Id, Name, Balance__c, Sirono_ID__c, Invoice_Date__c, Invoice_Age__c, Status__c,
                    Due_Date__c, Partial_Payment_Plan__c,Patient__r.Name, Patient__r.Medical_Record_Number__c,
                    Guarantor__r.Overdue_Balance__c, Guarantor__r.Invoiced_Balance__c, Guarantor__r.Due_Balance__c,
                    Guarantor__r.Delinquent_Balance__c,Guarantor__r.Payment_Plan_Balance__c,
                    Guarantor__r.Add_to_Payment_Plan__c, Guarantor__r.Pre_Invoiced_Balance__c, (
                    SELECT Id, Payment_Plan__c, Payment_Plan__r.Active__c, Payment_Plan__r.Installment_Amount__c,
                        Payment_Plan__r.NextPaymentDate__c
                    FROM Charge_Groups__r
                )
                FROM Invoice__c
                WHERE Guarantor__c = :contactId AND Id = :invoiceId
            ];
        }
        return null;
    }

    /**
     * Get the list of Invoice__c object for a particular user.
     *
     * @param Id userId - The Guarantor id associated with the invoices.
     * @param Set<String> statuses - An optional set of invoice statuses to filter the result.
     * @param List<String> patients - An optional list of Patient ids used to limit the query.
     * @returns List<Invoice__C> - The list of invoices.
     */
    public static List<Invoice__c> getInvoicesForUser(Id userId, Set<String> statuses, List<String> patients) {
        // TODO FLS/CRUD
        String query = 'SELECT Id, Name, Balance__c, Patient__r.Name, Patient__r.Medical_Record_Number__c, Sirono_ID__c, Invoice_Date__c, Invoice_Age__c, Status__c, ' +
            'Due_Date__c, Guarantor__r.Overdue_Balance__c, Guarantor__r.Add_to_Payment_Plan__c, Guarantor__r.Invoiced_Balance__c, ' +
            'Guarantor__r.Due_Balance__c, Guarantor__r.Delinquent_Balance__c, Partial_Payment_Plan__c, ' +
            'Guarantor__r.Payment_Plan_Balance__c, Guarantor__r.Pre_Invoiced_Balance__c, ' +
            '(SELECT Id, Payment_Plan__c, Payment_Plan__r.Active__c, Payment_Plan__r.Installment_Amount__c, ' +
            'Payment_Plan__r.NextPaymentDate__c FROM Charge_Groups__r) ' +
            'FROM Invoice__c WHERE Guarantor__c = :userId';

        if (patients != null && patients.size() > 0) {
            query += ' AND Patient__c IN :patients';
        }

        if (statuses != null && statuses.size() != 0) {
            query += ' AND Status__c in :statuses';
        }

        // Add order by clause
        query += ' ORDER BY Invoice_Date__c DESC';

        return Database.query(query);
    }

    /**
     * Get the list of Invoices with patient information for a user.
     *
     * @param Id userId - The user id.
     * @returns List<Invoice__c> The list of invoices for the user.
     */
    public static List<Invoice__c> getPatientInvoices(Id userId) {
        // TODO: FLS CRUD
        return [
            SELECT
                Patient__r.Medical_Record_Number__c,
                Patient__r.Name
            FROM Invoice__c
            WHERE Guarantor__c = :userId
            LIMIT 50000
        ];
    }

}