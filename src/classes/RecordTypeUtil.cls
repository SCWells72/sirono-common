/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

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
            for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Contact']) {
                if ('Guarantor'.equalsIgnoreCase(rt.Name)) {
                    guarantorRt = rt.Id;
                } else if ('Patient'.equalsIgnoreCase(rt.Name)) {
                    patientRt = rt.Id;
                } else if ('Staff'.equalsIgnoreCase(rt.Name)) {
                    staffRt = rt.Id;
                }
                rtMap.put(rt.Name, rt.Id);
            }

            for (RecordType rt : [
                SELECT Id, Name
                FROM RecordType
                WHERE SobjectType = 'Case'
                AND DeveloperName = 'Automated_Cases'
            ]) {
                automatedCaseRt = rt.Id;
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
            SELECT Id, Name
            FROM RecordType
            WHERE SobjectType = :Payment_Method__c.class.getName()
        ]) {
            recordTypeMap.put(recordType.Name, recordType.Id);
        }

        System.assert(recordTypeMap.size() != 0);
        return recordTypeMap;
    }

}