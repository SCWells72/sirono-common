/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Utility methods for aggregating transactions for Services, Adjustments & Payments
 */
public with sharing class TxnAggregationUtils {

    private static String TOTAL = 'Total';
    private static String OBJ = 'obj';

    /**
     * Set the Amount for each of the given Adjustments with the sum of its Transaction's amounts. If there are no
     * transactions, set the amount to 0
     */
    public static void aggregateAdjustmentTxns(Set<Id> ids) {

        if (ids.size() > 0) {
            if (TransactionSecurityContext.SELECT_CONTEXT.actionAllowed()) {
                // Get the SUM of the associated transaction amounts
                AggregateResult[] results = [
                    SELECT Adjustment2__c obj, SUM(Amount__c) Total
                    FROM Transaction__c
                    WHERE Adjustment2__c IN :ids
                    GROUP BY Adjustment2__c
                ];

                Map<Id, Decimal> resultsMap = mapAggregateResults(ids, results);
                updateAdjustments(resultsMap);
            }
        }
    }

    private static void updateAdjustments(Map<Id, Decimal> resultsMap) {
        List<Adjustment__c> adjs = new List<Adjustment__c>();

        for (Id objId : resultsMap.keySet()) {
            System.debug('adjId: ' + objId);
            System.debug('adjTotal: ' + resultsMap.get(objId));

            Adjustment__c adj = new Adjustment__c(Id=(Id) objId);
            adj.Amount__c = -1.0 * resultsMap.get(objId);
            adjs.add(adj);
        }

        AdjustmentDao.updateAll(adjs);
    }

    /**
     * Set the Posted_Amount__c for each of the given Payments with the sum of its Transaction's amounts
     * If it is a PAS payment, also set the Amount__c. If there are no transactions, set the amount to 0.
     */
    public static void aggregatePaymentTxns(Set<Id> ids) {
        //Determine which are Sirono payments
        if (PaymentSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            List<Id> sironoPmtIds = new List<Id>(new Map<Id, Payment__c>([
                SELECT Id
                FROM Payment__c
                WHERE Id IN :ids AND Sirono_Id__c != NULL
            ]).keySet());

            if (sironoPmtIds.size() > 0) {
                Set<Id> idSet = new Set<Id>();
                idSet.addAll(sironoPmtIds);
                aggregatePayments(idSet, false);
            }

            // Any left are PAS payments
            ids.removeAll(sironoPmtIds);
            if (ids.size() > 0) {
                aggregatePayments(ids, true);
            }
        }
    }

    /**
     * Return the SUM of the associated transaction amounts for each payment id. If there are no aggregate results,
     * the amount should be 0
     **/
    private static void aggregatePayments(Set<Id> ids, Boolean isPASPmt) {

        if (ids.size() > 0) {
            if (TransactionSecurityContext.SELECT_CONTEXT_WITH_PAYMENT.actionAllowed()) {
                AggregateResult[] results = [
                    SELECT Payment__c obj, SUM(Amount__c) Total
                    FROM Transaction__c
                    WHERE Payment__c IN :ids
                    GROUP BY Payment__c
                ];

                Map<Id, Decimal> resultsMap = mapAggregateResults(ids, results);
                updatePayments(resultsMap, isPASPmt);
            }
        }
    }

    private static void updatePayments(Map<Id, Decimal> resultsMap, Boolean isPASPmt) {

        List<Payment__c> pmts = new List<Payment__c>();

        for (Id objId : resultsMap.keySet()) {
            System.debug('pmtId: ' + objId);
            System.debug('pmtTotal: ' + resultsMap.get(objId));

            Payment__c pmt = new Payment__c(Id = objId);
            pmt.Posted_Amount__c = -1.0 * resultsMap.get(objId);
            if (isPASPmt) {
                pmt.Amount__c = -1.0 * resultsMap.get(objId);
            }
            pmts.add(pmt);
        }

        // Update the database
        if (pmts.size() > 0) {
            if (PaymentSecurityContext.UPDATE_CONTEXT.actionAllowed()) {
                update pmts;
            }
        }
    }

    /**
     * Set the Amount for each of the given Services with the sum of its Transaction's amounts. If
     * a Service no longer has any transactions, 0 out the amount on it
     */
    public static void aggregateServiceTxns(Set<Id> ids) {

        if (ids.size() > 0) {
            if (TransactionSecurityContext.SELECT_CONTEXT_WITH_SERVICE.actionAllowed()) {
                // Get the SUM of the associated transaction amounts
                AggregateResult[] results = [
                    SELECT Service2__c obj, SUM(Amount__c) Total
                    FROM Transaction__c
                    WHERE Service2__c IN :ids
                    GROUP BY Service2__c
                ];

                Map<Id, Decimal> resultsMap = mapAggregateResults(ids, results);
                updateServices(resultsMap);
            }
        }
    }

    private static void updateServices(Map<Id, Decimal> resultsMap) {
        List<Service2__c> services = new List<Service2__c>();

        for (Id objId : resultsMap.keySet()) {
            System.debug('svcId: ' + objId);
            System.debug('svcTotal: ' + resultsMap.get(objId));

            Service2__c svc = new Service2__c(Id = objId);
            svc.Amount__c = resultsMap.get(objId);
            services.add(svc);
        }

        // Update the database
        if (services.size() > 0) {
            if (ServiceSecurityContext.UPDATE_CONTEXT.actionAllowed()) {
                update services;
            }
        }
    }

    /**
     * Create a map of Id -> Amount from the given AggregateResults. For any id in the id set not present in the
     * results, create a map entry of 0
     */
    private static Map<Id, Decimal> mapAggregateResults(Set<Id> ids, AggregateResult[] results) {
        Map<Id, Decimal> resultsMap = new Map<Id, Decimal>();

        for (AggregateResult ar : results) {
            Id arId = (Id) ar.get(OBJ);
            Decimal amount = (Decimal) ar.get(TOTAL);
            resultsMap.put(arId, amount);
        }

        for (Id objId : ids) {
            if (!resultsMap.containsKey(objId)) {
                resultsMap.put(objId, 0.00);
            }
        }

        return resultsMap;
    }
}