/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

void deleteData(List<SObject> records) {
    if ((records != null) && !records.isEmpty()) {
        SObject firstRecord = records[0];
        SObjectType objectType = firstRecord.getSObjectType();
        System.debug('Deleting ' + records.size() + ' ' + objectType.getDescribe().getLabelPlural() + '.');

        List<Database.DeleteResult> deleteResults = new List<Database.DeleteResult>();
        try {
            deleteResults = Database.delete(records, false);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        System.debug('deleteResults count:' + deleteResults.size());
        Integer numSuccesses = 0, numFailures = 0;
        List<Id> successIds = new List<Id>();
        List<Database.Error> errors = new List<Database.Error>();

        for (Database.DeleteResult deleteResult : deleteResults) {
            if (deleteResult.isSuccess()) {
                numSuccesses++;
                successIds.add(deleteResult.getId());
            } else {
                numFailures++;
                errors.addAll(deleteResult.getErrors());
            }
        }

        if (!successIds.isEmpty()) {
            Database.emptyRecycleBin(successIds);
        }

        System.debug('Completed with ' + numSuccesses + ' successes and ' + numFailures + ' failures.');
        for (Database.Error error : errors) {
            System.debug('* ' + error.getStatusCode() + ' - ' + error.getMessage() + ' { ' + String.join(error.getFields(), ', ') + ' }');
        }
    }
}

// We don't load Encounters right now, so we're deleting the children of rather than Contact in order not to lose the Encounters.
// Otherwise we could delete a slightly smaller dataset: Contact, Case, Coverage, Encounter, Location, Payment, Payment Method, Payor, Provider and Service Rollup
//deleteData([SELECT Id FROM Charge_Group__c LIMIT 10000]);
//deleteData([SELECT Id FROM Payor__c LIMIT 10000]);
//deleteData([SELECT Id FROM Adjustment__c LIMIT 10000]);

//TODO Services need to be done alone and in 2 passes
//deleteData([SELECT Id FROM Service2__c LIMIT 5000]);

deleteData([SELECT Id FROM Payment__c LIMIT 10000]);
//deleteData([SELECT Id FROM Payment_Method__c LIMIT 10000]);
//deleteData([SELECT Id FROM Invoice__c LIMIT 10000]);
//deleteData([SELECT Id FROM Statement__c LIMIT 10000]);
//deleteData([SELECT Id FROM Location__c LIMIT 10000]);
//deleteData([SELECT Id FROM Coverage__c LIMIT 10000]);
//deleteData([SELECT Id FROM Case LIMIT 10000]);

String[] objNames = new String[]{'Charge_Group__c', 'Payor__c', 'Adjustment__c', 'Service2__c',
    'Payment__c', 'Payment_Method__c', 'Invoice__c', 'Statement__c', 'Location__c', 'Coverage__c', 'Case'
};

for (String objName : objNames) {
    Integer count = Database.countQuery('SELECT count() FROM '+objName);
    System.debug(count + ' '+objName);
}