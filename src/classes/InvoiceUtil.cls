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
     * @param Set<Id> invoiceIdsFromChargeGroup - invoice ids from charge groups that have been inserted, updated, deleted
     */
    public static void updateAllSubstatusInvoiceField(Set<Id> invoiceIdsFromChargeGroup) {
        if(invoiceIdsFromChargeGroup.size() > 0) {
            AggregateResult[] queryResults = [
                    SELECT Invoice__c, Account_Sub_Status__c
                    FROM Charge_Group__c
                    WHERE Invoice__c IN :invoiceIdsFromChargeGroup
                    GROUP BY Invoice__c, Account_Sub_Status__c
            ];

            Map<Id, List<String>> idWithStatusValues = new Map<Id, List<String>>();
            // Loop through query results and add status values to map<id, list<string>>
            if(queryResults.size() > 0) {
                for(AggregateResult ar : queryResults) {
                    if(idWithStatusValues.containsKey((Id) ar.get('Invoice__c'))) {
                        List<String> tempList = idWithStatusValues.get((Id) ar.get('Invoice__c'));
                        tempList.add((String) ar.get('Account_Sub_Status__c'));
                        idWithStatusValues.put((Id) ar.get('Invoice__c'), tempList);
                    } else {
                        Id tempId = (Id) ar.get('Invoice__c');
                        List<String> tempList = new List<String>();
                        tempList.add((String) ar.get('Account_Sub_Status__c'));
                        idWithStatusValues.put(tempId, tempList);
                    }
                }
            }

            // Loop through map with list of strings and join the list and put into new map<id, string>
            Map<Id, Invoice__c> invoicesToUpdate = new Map<Id, Invoice__c>();

            for(Id invoiceId : idWithStatusValues.keySet()) {
                List<String> tempList = idWithStatusValues.get(invoiceId);
                Invoice__c invoice = new Invoice__c();
                String concatString = String.join(tempList, ', ');
                invoice.All_Substatus__c = concatString;
                invoicesToUpdate.put(invoiceId, invoice);
            }

            // Update the All_Sub_Status field with the concatenated string
            update invoicesToUpdate.values();
        }
    }
}