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
}