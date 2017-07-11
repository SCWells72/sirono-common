/**
 * Created by swells on 7/11/2017.
 */

public with sharing class ProcessBuilderTestUtil {

    private ProcessBuilderTestUtil()
    {
        // Utility class
    }

    public static void populateSironoSettings() {
        Sirono_Settings__c settings = Sirono_Settings__c.getInstance();

        List<BusinessHours> businessHours = [
            SELECT Id
            FROM BusinessHours
            WHERE Name = 'Default'
            LIMIT 1
        ];
        if (!businessHours.isEmpty()) {
            settings.Business_Hours_Id__c = businessHours[0].Id;
        }

        List<RecordType> recordTypes = [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = :Case.SObjectType.getDescribe().getName()
            AND Name = 'Automated Cases'
            LIMIT 1
        ];
        if (!recordTypes.isEmpty()) {
            settings.Automated_Case_Record_Type_Id__c = recordTypes[0].Id;
        }

        upsert settings;
    }
}