/**
 * Utility methods for aggregating transactions for Services, Adjustments & Payments
 */

public with sharing class TxnAggregationUtils {

    private static String TOTAL = 'Total';
    private static String OBJ = 'obj';

    /**
     * Set the Amount for each of the given Adjustments with the sum of its Transaction's amounts
     */
    public static void aggregateAdjustmentTxns(Set<Id> ids) {

        if (ids.size() > 0) {

            // Get the SUM of the associated transaction amounts
            AggregateResult[] results = [
                    SELECT Adjustment__c obj, SUM(Amount__c) Total
                    FROM Transaction__c
                    WHERE Adjustment__c IN :ids
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

    /**
     * Set the Posted_Amount__c for each of the given Payments with the sum of its Transaction's amounts
     * If it is a PAS payment, also set the Amount__c
     */
    public static void aggregatePaymentTxns(Set<Id> ids) {
        //Determine which are Sirono payments
        List<Id> sironoPmtIds = new List<Id>(new Map<Id, Payment__c>([
                SELECT Id
                FROM Payment__c
                WHERE Id IN :ids AND Sirono_ID__c != null]).keySet());

        if (sironoPmtIds.size() > 0) {
            Set<Id> idSet = new Set<Id>();
            idSet.addAll(sironoPmtIds);
            updatePayments(idSet, false);
        }

        // Any left are PAS payments
        ids.removeAll(sironoPmtIds);
        if (ids.size() > 0) {
            updatePayments(ids, true);
        }
    }

    /**
     * Return the SUM of the associated transaction amounts for each payment id
     **/
    private static void updatePayments(Set<id> pmtIds, boolean isPASPmt) {
        AggregateResult[] results = [SELECT Payment__c obj, SUM(Amount__c) Total
                FROM Transaction__c
                WHERE Payment__c IN :pmtIds
                GROUP BY Payment__c
                ];

        if (results.size() > 0) {
            List<Payment__c> pmts = new List<Payment__c>();

            for (AggregateResult ar : results) {
                System.debug('pmtId: ' + ar.get(OBJ));
                System.debug('pmtTotal: ' + ar.get(TOTAL));
                Payment__c pmt = new Payment__c(Id = (Id) ar.get(OBJ));
                pmt.Posted_Amount__c = (Decimal) ar.get(TOTAL);
                if (isPasPmt) {
                    pmt.Amount__c = (Decimal) ar.get(TOTAL);
                }
                pmts.add(pmt);
            }

            // Update the database
            if (pmts.size() > 0) {
                update pmts;
            }
        }
    }


    /**
     * Set the Amount for each of the given Services with the sum of its Transaction's amounts
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
            System.debug('svcTotal: ' + ar.get(TOTAL));
            Service__c svc = new Service__c(Id=(Id) ar.get(OBJ));
            svc.Amount__c = (Decimal) ar.get(TOTAL);
            services.add(svc);
        }

        // Update the database
        if (services.size() > 0) {
            update services;
        }
    }
}