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
    public static Id externalGtRt;

    static {
        rtMap = new Map<String, Id>();

        if (RecordTypeSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Contact']) {
                if (Constants.RECORD_TYPE_GUARANTOR.equalsIgnoreCase(rt.Name)) {
                    guarantorRt = rt.Id;
                } else if (Constants.RECORD_TYPE_PATIENT.equalsIgnoreCase(rt.Name)) {
                    patientRt = rt.Id;
                } else if (Constants.RECORD_TYPE_EXTERNAL_GUARANTOR.equalsIgnoreCase(rt.Name)) {
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
    }
}