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

}