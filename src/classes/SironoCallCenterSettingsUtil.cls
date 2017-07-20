/**
 * Created by swells on 7/20/2017.
 */

public with sharing class SironoCallCenterSettingsUtil {

    public static Sirono_Call_Center_Settings__c getSironoCallCenterSettings() {
        Sirono_Call_Center_Settings__c sironoCallCenterSettings = Sirono_Call_Center_Settings__c.getOrgDefaults();
        if (Test.isRunningTest()) {
            sironoCallCenterSettings.Auto_Create_Overdue_Cases__c = true;
            sironoCallCenterSettings.Auto_Create_Precollection_Cases__c = true;
            sironoCallCenterSettings.Auto_Create_Payment_Plan_Error_Cases__c = true;
        }
        return sironoCallCenterSettings;
    }
}