/*
* @author Sirono
* @version 1.0.1
* @Date: 09-01-2016
* Created by mmartin on 08-18-2016.
*/

public with sharing class RecordTypeUtil {
    Public Static Map<String, Id> rtMap = null;

    public static Id guarantorRt;
    public static Id patientRt;
    public static Id staffRt;

    static {
        rtMap = new Map<String, Id>();

        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Contact']) {
            if ('Guarantor'.equalsIgnoreCase(rt.Name)) {
                guarantorRt = rt.id;
            } else if ('Patient'.equalsIgnoreCase(rt.Name)) {
                patientRt = rt.id;
            } else if ('Staff'.equalsIgnoreCase(rt.Name)) {
                staffRt = rt.id;
            }
            rtMap.put(rt.Name, rt.Id);
        }

    }
}