public with sharing class InvoiceUtil {

    /*
     * Method takes a set of invoice Ids and updates the Invoice Status Index with the MAX Status Index value from
     * related charge groups.
     *
     * @param Set<Id> invoiceIdsFromChargeGroup - invoice Ids from charge groups that have been inserted, updated, or deleted
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

            if(queryResults.size() > 0) {
                List<Invoice__c> invoicesToUpdate = new List<Invoice__c>();

                for(AggregateResult qr : queryResults) {
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
     * Method takes a set of Invoice Ids from updated charge group records and selects a distinct list of substatus
     * values from related charge groups. It then concatenates those values and inserts the values into the All_Substatus__c
     * field on the Invoice object.
     *
     * @param Set<Id> invoiceIdsFromChargeGroup - invoice ids from charge groups that have been inserted, updated, or deleted
     */
    public static void updateAllSubstatusInvoiceField(Set<Id> chargeGroupInvoiceIds) {
        if(chargeGroupInvoiceIds.size() > 0) {
            // Query for distinct Invoice/Account Substatus values using group by
            AggregateResult[] queryResults = [
                    SELECT Invoice__c, Account_Sub_Status__c
                    FROM Charge_Group__c
                    WHERE Invoice__c IN :chargeGroupInvoiceIds
                    GROUP BY Invoice__c, Account_Sub_Status__c
            ];

            // Put invoice ids into a set to get a list of distinct Ids to loop through
            Set<Id> invoiceIdSet = new Set<Id>();

            for (AggregateResult ar : queryResults) {
                invoiceIdSet.add((Id) ar.get('Invoice__c'));
            }

            // idWithStatusValuesMap includes Invoices that will need to be updated
            Map<Id, Invoice__c> idWithStatusValuesMap = new Map<Id, Invoice__c>();

            // Loop through each invoice Id in the invoiceIdSet and add each associated Substatus value to a list
            // Concatnate the substatus list and assign to Invoice__c.All_Substatus__c
            for (Id invoiceId : invoiceIdSet) {
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

            update idWithStatusValuesMap.values();
        }
    }
}