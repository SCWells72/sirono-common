/**
 * Created by mmartin on 8/18/16.
 */

public with sharing class RecordTypeUtil {
    Public Static Map<String, Id> rtMap= null;

    public static Id Guarantor_RT;
    public static Id Patient_RT;
    public static Id Staff_RT;

    static {
        rtMap = new Map<String, Id>();

        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Contact']) {
            if ('Guarantor'.equalsIgnoreCase(rt.Name)) {
                Guarantor_RT = rt.id;
            } else if ('Patient'.equalsIgnoreCase(rt.Name)) {
                Patient_RT = rt.id;
            } else if ('Staff'.equalsIgnoreCase(rt.Name)) {
                Staff_RT = rt.id;
            }
            rtMap.put(rt.Name, rt.Id);
        }

    }
}