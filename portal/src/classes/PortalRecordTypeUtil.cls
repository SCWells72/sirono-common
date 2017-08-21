/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/*
* RecordType constants
*/
public with sharing class PortalRecordTypeUtil {
    public static Map<String, Id> rtMap = null;

    public static Id automatedCaseRt;
    public static Id guarantorRt;
    public static Id patientRt;
    public static Id externalGtRt;

    static {
        rtMap = new Map<String, Id>();

        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Contact']) {
            if (PortalConstants.RECORD_TYPE_GUARANTOR.equalsIgnoreCase(rt.Name)) {
                guarantorRt = rt.Id;
            } else if (PortalConstants.RECORD_TYPE_PATIENT.equalsIgnoreCase(rt.Name)) {
                patientRt = rt.Id;
            } else if (PortalConstants.RECORD_TYPE_EXTERNAL_GUARANTOR.equalsIgnoreCase(rt.Name)) {
                externalGtRt = rt.Id;
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
            WHERE SobjectType = :sPRS__Payment_Method__c.class.getName()
        ]) {
            recordTypeMap.put(recordType.Name, recordType.Id);
        }

        System.assert(recordTypeMap.size() != 0);
        return recordTypeMap;
    }
}