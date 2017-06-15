/**
 * Methods for Creating/Updating/Retrieving transaction objects
 */

public with sharing class TransactionDao {

    /**
	 * This method is used to Insert Transaction recorda.
	 * @param List<Transaction__c> Transactions - List of Transaction records for insert
	 **/
    //TODO FLS/Crud
    public static void insertTransactions(List<Transaction__c> transactions) {
        INSERT transactions;
    }
}