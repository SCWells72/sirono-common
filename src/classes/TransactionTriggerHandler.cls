/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * When Transactions are inserted, updated or deleted,
 * calculate the rollup Amount on their related Service, Adjustment or Payment
 */
public with sharing class TransactionTriggerHandler {


    public static void afterInsert(List<Transaction__c> newList) {
        processInsertsAndDeletes(newList);
    }

    public static void afterDelete(List<Transaction__c> oldList) {
        processInsertsAndDeletes(oldList);
    }

    private static void processInsertsAndDeletes(List<Transaction__c> txnList) {
        Set<Id> svcIds = new Set<Id>();
        Set<Id> adjIds = new Set<Id>();
        Set<Id> pmtIds = new Set<Id>();

        for (Transaction__c txn : txnList) {
            if (txn.Service2__c != null) {
                svcIds.add(txn.Service2__c);
            }

            if (txn.Adjustment__c != null) {
                adjIds.add(txn.Adjustment__c);
            }


            if (txn.Payment__c != null) {
                pmtIds.add(txn.Payment__c);
            }
        }

        TxnAggregationUtils.aggregateServiceTxns(svcIds);
        TxnAggregationUtils.aggregateAdjustmentTxns(adjIds);
        TxnAggregationUtils.aggregatePaymentTxns(pmtIds);
    }

    /*
     *  When a transaction is updated, only calculate rollups if the amount or related object changed
     */
    public static void afterUpdate(List<Transaction__c> newList, Map<Id, Transaction__c> oldMap) {

        Set<Id> svcIds = new Set<Id>();
        Set<Id> adjIds = new Set<Id>();
        Set<Id> pmtIds = new Set<Id>();

        for (Transaction__c newTxn : newList) {
            // It should be possible to improve the performance by
            // updating only when (newTxn.Amount__c != oldTxn.Amount__c)
            // Perform unconditionally until we iron out all the kinks in the
            // data relationships & informatica jobs
            if (newTxn.Service2__c != null) {
                svcIds.add(newTxn.Service2__c);
            }

            if (newTxn.Adjustment__c != null) {
                adjIds.add(newTxn.Adjustment__c);
            }

            if (newTxn.Payment__c != null) {
                pmtIds.add(newTxn.Payment__c);
            }

            // Check against the old id is probably overly cautious - highly unlikely
            Id newId = getRelatedObjectId(newTxn);
            Transaction__c oldTxn = oldMap.get(newTxn.Id);
            Id oldId = getRelatedObjectId(oldTxn);

            if (newId != oldId) {
                if (oldTxn.Payment__c != null) {
                    pmtIds.add(oldTxn.Payment__c);
                } else if (oldTxn.Adjustment__c != null) {
                    adjIds.add(oldTxn.Adjustment__c);
                } else if (oldTxn.Service2__c != null) {
                    svcIds.add(oldTxn.Service2__c);
                }
            }
        }

        TxnAggregationUtils.aggregateServiceTxns(svcIds);
        TxnAggregationUtils.aggregateAdjustmentTxns(adjIds);
        TxnAggregationUtils.aggregatePaymentTxns(pmtIds);
    }

    private static Id getRelatedObjectId(Transaction__c txn) {
        if (txn.Service2__c != null) {
            return txn.Service2__c;
        }

        if (txn.Payment__c != null) {
            return txn.Payment__c ;
        }

        return txn.Adjustment__c;

    }
}