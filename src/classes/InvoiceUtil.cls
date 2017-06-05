//TODO remove without sharing
public without sharing class InvoiceUtil {

    /*
     * Method takes a set of invoice Ids and updates the Invoice Status Index with the MAX Status Index value from
     * related charge groups.
     *
     * @param Set<Id> invoiceIdsFromChargeGroup - invoice Ids from charge groups that have been inserted, updated, or deleted
     */

    public static void updateInvoiceStatusIndex(Set<Id> chargeGroupInvoiceIds) {
        // Get the max index value from related charge groups and insert into Invoice Status Index field
        if(chargeGroupInvoiceIds.size() != 0) {
            // Instantiate an Id, Invoice map to hold temp invoices and field values to update
            Map<Id, Invoice__c> invoicesToUpdate = new Map<Id, Invoice__c>();

            for (Id invoiceId: chargeGroupInvoiceIds) {
                Invoice__c tempInvoice = new Invoice__c();
                tempInvoice.Id = invoiceId;
                tempInvoice.Invoice_Status_Index__c = 0;

                invoicesToUpdate.put(invoiceId, tempInvoice);
            }

            //TODO: This query should move into ChargeGroupDao class.
            if (ChargeGroupSecurityContext.IU_SELECT_CONTEXT.actionAllowed()) {
                AggregateResult[] queryResults = [
                        SELECT Invoice__c, MAX(Sub_Status_Index__c) maxStatusValue
                        FROM Charge_Group__c
                        WHERE Invoice__c IN :chargeGroupInvoiceIds
                        AND Active__c = TRUE
                        GROUP BY Invoice__c
                ];

                if(queryResults.size() > 0) {
                    for(AggregateResult qr: queryResults) {
                        system.debug('Updated invoice values >>>>> [Invoice Id]: ' + qr.get('Invoice__c')
                                + '[Max Status Value]: ' + qr.get('maxStatusValue'));

                        // Update the Invoice Status Index field directly within the map, else the field remains 0
                        invoicesToUpdate.get((Id) qr.get('Invoice__c')).Invoice_Status_Index__c = Integer.valueOf(qr.get('maxStatusValue'));
                    }
                }
                if (InvoiceSecurityContext.UPDATE_CONTEXT.actionAllowed()) {
                    UPDATE invoicesToUpdate.values();
                }
            }
        }
    }

    /*
     * Method takes a set of Invoice Ids from updated charge group records and selects a distinct list of substatus
     * values from related charge groups. It then concatenates those values and inserts the values into the All_Substatus__c
     * field on the Invoice object.
     *
     * @param Set<Id> invoiceIdsFromChargeGroup - invoice ids from charge groups that have been inserted, updated, or deleted
     */
    public static void updateAllSubstatusInvoiceField(Set<Id> chargeGroupInvoiceIds) {
        if (chargeGroupInvoiceIds.size() > 0) {
            //TODO: This query should move into ChargeGroupDao class.
            if (ChargeGroupSecurityContext.IU_SELECT_CONTEXT.actionAllowed()) {
                // Query for distinct Invoice/Account Substatus values using group by
                AggregateResult[] queryResults = [
                        SELECT Invoice__c, Account_Sub_Status__c
                        FROM Charge_Group__c
                        WHERE Invoice__c IN :chargeGroupInvoiceIds
                        GROUP BY Invoice__c, Account_Sub_Status__c
                ];

                // idWithStatusValuesMap includes Invoices that will need to be updated
                Map<Id, Invoice__c> idWithStatusValuesMap = new Map<Id, Invoice__c>();

                // Loop through each invoice Id in the invoiceIdSet and add each associated Substatus value to a list
                // Concatnate the substatus list and assign to Invoice__c.All_Substatus__c
                for (Id invoiceId : chargeGroupInvoiceIds) {
                    List<String> tempStatusList = new List<String>();
                    Invoice__c tempInvoice = new Invoice__c();

                    for (AggregateResult ar : queryResults) {
                        if ((Id) ar.get('Invoice__c') == invoiceId) {
                            tempStatusList.add((String) ar.get('Account_Sub_Status__c'));
                            system.debug('>>>>> Adding Acct Substatus to list: ' + ar.get('Account_Sub_Status__c') + ' for ' +
                                    'invoice Id: ' + invoiceId);
                        }
                    }

                    String concatStatusValues = String.join(tempStatusList, ',');
                    tempInvoice.All_Substatus__c = concatStatusValues;
                    tempInvoice.Id = invoiceId;

                    idWithStatusValuesMap.put(invoiceId, tempInvoice);
                }
                if (InvoiceSecurityContext.UPDATE_ALL_SUBSTATUS_CONTEXT.actionAllowed()) {
                    UPDATE idWithStatusValuesMap.values();
                }
            }
        }
    }

    /*
     * Method calculates the balances from related charge groups.
     *
     * @param Set<Id> invoiceIdsFromChargeGroup - invoice Ids from charge groups that have been inserted, update, deleted
     */

    public static void updateInvoiceBalances(Set<Id> chargeGroupInvoiceIds) {
        // Sum balances from active charge groups
        if (chargeGroupInvoiceIds.size() > 0) {
            // Instantiate map that is accessed by if and else blocks
            Map<Id, Invoice__c> invoicesToUpdate = new Map<Id, Invoice__c>();

            for (Id invoiceId: chargeGroupInvoiceIds) {
                Invoice__c tempInvoice = new Invoice__c();
                tempInvoice.Id = invoiceId;
                tempInvoice.Invoice_Balance__c = 0.00;
                invoicesToUpdate.put(invoiceId, tempInvoice);
            }

            //TODO: This query should move into ChargeGroupDao class.
            if (ChargeGroupSecurityContext.IU_SELECT_CONTEXT.actionAllowed()) {
                AggregateResult[] queryResults = [
                        SELECT Invoice__c, SUM(Balance__c) sumBalances
                        FROM Charge_Group__c
                        WHERE Invoice__c IN :chargeGroupInvoiceIds
                        AND Active__c = TRUE
                        GROUP BY Invoice__c
                ];

                if (queryResults.size() > 0) {
                    for (AggregateResult qr: queryResults) {
                        system.debug('Updated invoice values >>>>> [Invoice Id]: ' + qr.get('Invoice__c')
                                + '[Invoice Balance]: ' + qr.get('sumBalances'));

                        if ((Decimal) qr.get('sumBalances') != 0 || (Decimal) qr.get('sumBalances') != null) {
                            // Update the Invoice Balance field directly within the map, else the balance will remain 0.00
                            invoicesToUpdate.get((Id) qr.get('Invoice__c')).Invoice_Balance__c = (Decimal) qr.get('sumBalances');
                        }
                    }
                }
                if (InvoiceSecurityContext.UPDATE_BALANCE_CONTEXT.actionAllowed()) {
                    UPDATE invoicesToUpdate.values();
                }
            }
        }
    }
}