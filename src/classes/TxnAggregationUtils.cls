/**
 * Utility methods for aggregating transactions for Services, Adjustments & Payments
 */

public with sharing class TxnAggregationUtils {

    private static String TOTAL = 'Total';
    private static String OBJ = 'obj';

    /**
     * update each of the given services with the sum of its tranaction's amounts
     */
    public static void aggregateServiceTxns(Set<Id> serviceIds) {

        if (serviceIds.size() > 0) {

            // Get the SUM of the associated transaction amounts
            AggregateResult[] results = [
                    SELECT Service__c obj, SUM(Amount__c) Total
                    FROM Transaction__c
                    WHERE Service__c IN :serviceIds
                    GROUP BY Service__c
            ];

            if (results.size() > 0) {
                updateServices(results);
            }
        }
    }

    private static void updateServices(AggregateResult[] results) {
        List<Service__c> services = new List<Service__c>();

        for (AggregateResult ar : results) {
            System.debug('svcId: ' + ar.get(OBJ));
            System.debug('serviceTotal: ' + ar.get(TOTAL));
            Service__c svc = new Service__c(Id=(Id) ar.get(OBJ));
            svc.Amount__c = (Decimal) ar.get(TOTAL);
            services.add(svc);
        }

        // Update the database
        if (services.size() > 0) {
            update services;
        }
    }

    public static void aggregateAdjTxns(Set<Id> adjIds) {

        if (adjIds.size() > 0) {

            // Get the SUM of the associated transaction amounts
            AggregateResult[] results = [
                    SELECT Adjustment__c obj, SUM(Amount__c) Total
                    FROM Transaction__c
                    WHERE Adjustment__c IN :adjIds
                    GROUP BY Adjustment__c
            ];

            if (results.size() > 0) {
                updateAdjustments(results);
            }
        }
    }

    private static void updateAdjustments(AggregateResult[] results) {
        List<Payment_Adjustments__c> adjs = new List<Payment_Adjustments__c>();

        for (AggregateResult ar : results) {
            System.debug('adjId: ' + ar.get(OBJ));
            System.debug('adjTotal: ' + ar.get(TOTAL));
            Payment_Adjustments__c adj = new Payment_Adjustments__c(Id=(Id) ar.get(OBJ));
            adj.Amount__c = (Decimal) ar.get(TOTAL);
            adjs.add(adj);
        }

        // Update the database
        if (adjs.size() > 0) {
            update adjs;
        }
    }
}