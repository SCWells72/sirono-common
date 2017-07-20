/**
 * Created by swells on 7/20/2017.
 */

public with sharing class SironoCallCenterSettingsUtil {
    /**
     * Provides access to the configurable call center settings object. All access should be driven through this
     * method instead of direct access to the custom setting to ensure that it's properly initialized.
     *
     * @returns the call center settings
     */
    public static Sirono_Call_Center_Settings__c getSironoCallCenterSettings() {
        Sirono_Call_Center_Settings__c sironoCallCenterSettings = Sirono_Call_Center_Settings__c.getOrgDefaults();
        if (sironoCallCenterSettings.Id == null) {
            sironoCallCenterSettings.Auto_Create_Overdue_Cases__c = true;
            sironoCallCenterSettings.Auto_Create_Precollection_Cases__c = true;
            sironoCallCenterSettings.Auto_Create_Payment_Plan_Error_Cases__c = true;
            insert sironoCallCenterSettings;
        }
        return sironoCallCenterSettings;
    }
}