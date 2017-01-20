/*
*
* When Transactions are inserted, updated or deleted,
* calculate the rollup Amount on their related Service or Adjustment
*/
public with sharing class TransactionTriggerHandler {

    public static void afterInsert(List<Transaction__c> newList) {
        processInsertsAndDeletes(newList);
    }

    public static void afterDelete(List<Transaction__c> oldList) {
        processInsertsAndDeletes(oldList);
    }

    private static void processInsertsAndDeletes(List<Transaction__c> txnList) {
        Set<Id> serviceIds = new Set<Id>();
        Set<Id> adjIds = new Set<Id>();

        for (Transaction__c txn : txnList) {
            if (txn.Service__c != null) {
                serviceIds.add(txn.Service__c);
            }

            if (txn.Adjustment__c != null) {
                adjIds.add(txn.Adjustment__c);
            }
        }

        TxnAggregationUtils.aggregateServiceTxns(serviceIds);
        TxnAggregationUtils.aggregateAdjTxns(adjIds);
    }

    /*
     *  When a transaction is updated, only calculate rollups if the amount or related object changed
     */
    public static void afterUpdate(List<Transaction__c> newList, Map<Id, Transaction__c> oldMap) {

        Set<Id> serviceIds = new Set<Id>();
        Set<Id> adjIds = new Set<Id>();

        for (Transaction__c newTxn : newList) {
            Transaction__c oldTxn = oldMap.get(newTxn.Id);

            if (newTxn.Service__c != null) {
                // It should be possibile to improve the performance of this by
                // updating only when (newTxn.Amount__c != oldTxn.Amount__c)
                // Perform unconditionally until we iron out all the kinks in the
                // data relationships & informatica jobs
                serviceIds.add(newTxn.Service__c);

                // Probably overly cautious with this - I think this case is highly unlikely
                if (newTxn.Service__c != oldTxn.Service__c){
                    serviceIds.add(newTxn.Service__c);
                    serviceIds.add(oldTxn.Service__c);
                }
            }

            if (newTxn.Adjustment__c != null) {
                // It should be possibile to improve the performance of this by
                // updating only when (newTxn.Amount__c != oldTxn.Amount__c)
                // Perform unconditionally until we iron out all the kinks in the
                // data relationships & informatica jobs
                adjIds.add(newTxn.Adjustment__c);

                // Probably overly cautious with this - I think this case is highly unlikely
                if (newTxn.Adjustment__c != oldTxn.Adjustment__c){
                    adjIds.add(newTxn.Adjustment__c);
                    adjIds.add(newTxn.Adjustment__c);
                }
            }
        }

        TxnAggregationUtils.aggregateServiceTxns(serviceIds);
        TxnAggregationUtils.aggregateAdjTxns(adjIds);
    }
}