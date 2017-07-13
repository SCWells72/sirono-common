/*
* RecordType constants
*/

public with sharing class RecordTypeUtil {
    public static Map<String, Id> rtMap = null;

    public static Id automatedCaseRt;
    public static Id guarantorRt;
    public static Id patientRt;
    public static Id staffRt;

    static {
        rtMap = new Map<String, Id>();

        if (RecordTypeSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            for (RecordType rt: [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Contact']) {
                if ('Guarantor'.equalsIgnoreCase(rt.Name)) {
                    guarantorRt = rt.id;
                } else if ('Patient'.equalsIgnoreCase(rt.Name)) {
                    patientRt = rt.id;
                } else if ('Staff'.equalsIgnoreCase(rt.Name)) {
                    staffRt = rt.id;
                }
                rtMap.put(rt.Name, rt.Id);
            }

            for (RecordType rt: [
                    SELECT Id, Name
                    FROM RecordType
                    WHERE sObjectType = 'Case'
                    AND DeveloperName = 'Automated_Cases'
            ]) {
                automatedCaseRt = rt.id;
            }
        }


    }

     /**
     * Get the record types for Payment_Method__c.
     *
     * @return Map<String, String> - The keys are the record type names and the value is the id.
     */
    public static Map<String, String> getPayMethodRecordTypes() {
        Map<String, String> recordTypeMap = new Map<String, String>();
        for (RecordType recordType : [
            Select Id, Name
            From RecordType
            Where sObjectType = :Payment_Method__c.class.getName()
        ]) {
            recordTypeMap.put(recordType.Name, recordType.Id);
        }

        System.assert(recordTypeMap.size() != 0);
        return recordTypeMap;
    }

}