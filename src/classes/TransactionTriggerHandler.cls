/*
*
* When Transactions are inserted, updated or deleted,
* calculate the rollup Amount on their related Service, Payment or Adjustment
*/
public with sharing class TransactionTriggerHandler {

    public static void afterInsert(List<Transaction__c> newList) {
        Set<Id> serviceIds = new Set<Id>();
        for (Transaction__c txn : newList) {
            if (txn.Service__c != null) {
                serviceIds.add(txn.Service__c);
            }
        }

        ServiceUtils.updateAmounts(serviceIds);
    }

    /*
     *  When a transaction is updated, only calculate rollups if the amount or related object changed
     */
    public static void afterUpdate(List<Transaction__c> newList, Map<Id, Transaction__c> oldMap) {

        Set<Id> serviceIds = new Set<Id>();
        for (Transaction__c newTxn : newList) {
            Transaction__c oldTxn = oldMap.get(newTxn.Id);

            if (newTxn.Service__c != null) {
                if (newTxn.Amount__c != oldTxn.Amount__c) {
                    serviceIds.add(newTxn.Service__c);
                }
                // Probably overly cautious with this - I think this case is highly unlikely
                if (newTxn.Service__c != oldTxn.Service__c){
                    serviceIds.add(newTxn.Service__c);
                    serviceIds.add(oldTxn.Service__c);
                }
            }
        }

        ServiceUtils.updateAmounts(serviceIds);

    }

    public static void afterDelete(List<Transaction__c> oldList) {

        Set<Id> serviceIds = new Set<Id>();
        for (Transaction__c txn : oldList) {
            if (txn.Service__c != null) {
                serviceIds.add(txn.Service__c);
            }
        }

        ServiceUtils.updateAmounts(serviceIds);

    }
}