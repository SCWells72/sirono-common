/**
 * Utility methods for working with Services
 */

public with sharing class ServiceUtils {

    /**
     * update each of the given services with the sum of its tranaction's amounts
     */
    public static void updateAmounts(Set<Id> serviceIds) {

        if (serviceIds.size() > 0) {

            // Get the SUM of the associated transaction amounts
            AggregateResult[] results = [
                    SELECT Service__c svc, SUM(Amount__c) serviceTotal
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
            System.debug('svcId: ' + ar.get('svc'));
            System.debug('serviceTotal: ' + ar.get('serviceTotal'));
            Service__c svc = new Service__c(Id=(Id) ar.get('svc'));
            svc.Amount__c = (Decimal) ar.get('serviceTotal');
            services.add(svc);
        }

        // Update the database
        if (services.size() > 0) {
            update services;
        }
    }
}