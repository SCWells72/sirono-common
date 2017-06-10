/**
 * Invoice DAO
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
          AND Invoice_Status__c = :status
          ORDER BY CreatedDate
          LIMIT 1
      ];
    }
    return null;
  }

}