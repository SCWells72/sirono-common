/**
 * InvoiceService
 */

public with sharing class InvoiceService extends AbstractService {

    /**
     * Get the most recent Invoice__c by status.
     *
     * @returns List<Invoice__c> - A list that will contain the most recent Invoice__c with the provided status.
     */
    public static List<Invoice__c> getByStatus(Id guarantorId, String status) {
        return InvoiceDao.getByStatus(guarantorId, status);
    }

    /**
     * Get the details for a particular invoice by id.
     *
     * @param Id contactId - The Guarantor id.
     * @param String invoiceId - The invoice id.
     * @returns List<Invoice__c> - The list of Invoices__c objects.
     */
    public static List<Invoice__c> getInvoiceDetails(Id contactId, String invoiceId) {
        return InvoiceDao.getById(contactId, invoiceId);
    }

    /**
     * Get a list of charge groups ids for a list of invoices.
     *
     * @param List<Invoice__c> - The list of invoices.
     * @returns Set<Id> - The set of charge group ids found for the invoices.
     */
    public static Set<Id> getChargeGroupIds(List<Invoice__c> invoices) {
        Set<Id> chargeGroupIds = new Set<Id>();

        for (Invoice__c invoice: invoices) {
            for (Charge_Group__c cGroup: invoice.Charge_Groups__r) {
                chargeGroupIds.add(cGroup.Id);
            }
        }

        return chargeGroupIds;
    }

    /**
     * Get the list of Invoice__c object for a particular user.
     *
     * @param Id userId - The Guarantor id associated with the invoices.
     * @param Set<String> statuses - An optional set of invoice statuses to filter the result.
     * @param List<String> patients - An optional list of Patient ids used to limit the query.
     * @returns List<Invoice__c> - The list of invoices.
     */
    public static List<Invoice__c> getInvoicesForUser(Id userId, Set<String> statuses, List<String> patients) {
        return InvoiceDao.getInvoicesForUser(userId, statuses, patients);
    }

    /**
     * Get the patient invoices for a users.
     *
     * @param Id userId - The user id.
     * @returns List<Invoice__c> - The list of invoices.
     */
    public static List<Invoice__c> getPatientInvoices(Id userId) {
        return InvoiceDao.getPatientInvoices(userId);
    }

    /**
     * Get the list of charge groups associated with invoices for a user.
     *
     * @param Id userId - The Guarantor id associated with the invoices.
     * @param Set<String> statuses - An optional set of invoice statuses to filter the result.
     * @param List<String> patients - An optional list of Patient ids used to limit the query.
     * @returns List<Charge_Group__c> - The list of invoices.
     */
    public static List<Charge_Group__c> getInvoicedChargeGroups(Id userId, Set<String> statuses, List<String> patients) {
        List<Invoice__c> invoices = getInvoicesForUser(userId, statuses, patients);
        Set<Id> allChargeGroupIds = getChargeGroupIds(invoices);
        List<Charge_Group__c> allChargeGroups = ChargeGroupService.getCGForInvoiceController(allChargeGroupIds, true);

        return allChargeGroups;
    }

}