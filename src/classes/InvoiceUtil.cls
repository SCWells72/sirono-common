public with sharing class InvoiceUtil {

    /*
     * Method takes a set of invoice Ids and updates the Invoice Status Index with the MAX Status Index value from
     * related charge groups.
     *
     * @param Set<Id> invoiceIdsFromChargeGroup - invoice Ids from charge groups that have been inserted, updated, deleted
     */

    public static void updateInvoiceStatusIndex(Set<Id> invoiceIdsFromChargeGroup) {
        // Get the max index value from related charge groups and insert into Invoice Status Index field
        if(invoiceIdsFromChargeGroup.size() != 0) {
            AggregateResult[] queryResults = [
                    SELECT Invoice__c, MAX(Sub_Status_Index__c) maxStatusValue
                    FROM Charge_Group__c
                    WHERE Invoice__c IN :invoiceIdsFromChargeGroup
                    AND Active__c = TRUE
                    GROUP BY Invoice__c
            ];

            if(queryResults.size() > 0){
                List<Invoice__c> invoicesToUpdate = new List<Invoice__c>();

                for(AggregateResult qr: queryResults) {
                    Invoice__c tempInvoice = new Invoice__c();

                    system.debug('Updated invoice values >>>>> [Invoice Id]: ' + qr.get('Invoice__c')
                            + '[Max Status Value]: ' + qr.get('maxStatusValue'));
                    tempInvoice.Id = (Id) qr.get('Invoice__c');
                    tempInvoice.Invoice_Status_Index__c = Integer.valueOf(qr.get('maxStatusValue'));

                    invoicesToUpdate.add(tempInvoice);
                }

                update invoicesToUpdate;
            }
        }
    }

    /*
     * Method calculates the balances from related charge groups.
     *
     * @param Set<Id> invoiceIdsFromChargeGroup - invoice Ids from charge groups that have been inserted, update, deleted
     */

    public static void updateInvoiceBalances(Set<Id> invoiceIdsFromChargeGroup) {
        // Sum balances from active charge groups
        if(invoiceIdsFromChargeGroup.size() > 0) {
            AggregateResult[] queryResults = [
                    SELECT Invoice__c, SUM(Balance__c) sumBalances
                    FROM Charge_Group__c
                    WHERE Invoice__c IN :invoiceIdsFromChargeGroup
                    AND Active__c = TRUE
                    GROUP BY Invoice__c
            ];

            if(queryResults.size() > 0){
                Map<Id, Invoice__c> invoicesToUpdate = new Map<Id, Invoice__c>();

                for(AggregateResult qr: queryResults) {
                    Invoice__c tempInvoice = new Invoice__c();

                    system.debug('Updated invoice values >>>>> [Invoice Id]: ' + qr.get('Invoice__c')
                            + '[Invoice Balance]: ' + qr.get('sumBalances'));
                    tempInvoice.Id = (Id) qr.get('Invoice__c');

                    if((Decimal)qr.get('sumBalances') != 0 || (Decimal)qr.get('sumBalances') != null){
                        tempInvoice.Invoice_Balance__c = (Decimal) qr.get('sumBalances');
                    } else {
                        tempInvoice.Invoice_Balance__c = 0.00;
                    }

                    invoicesToUpdate.put(tempInvoice.Id, tempInvoice);
                }

                // Loop through invoice ids from charge group and see if any are missing
                // If so, set the invoice balance to 0 and then add to a list
                for(Id invoiceId: invoiceIdsFromChargeGroup) {
                    if(!invoicesToUpdate.containsKey(invoiceId)) {
                        Invoice__c tempInvoice = new Invoice__c();

                        tempInvoice.Id = invoiceId;
                        tempInvoice.Invoice_Balance__c = 0.00;

                        invoicesToUpdate.put(tempInvoice.Id, tempInvoice);
                    }
                }

                update invoicesToUpdate.values();
            }
        }
    }
}