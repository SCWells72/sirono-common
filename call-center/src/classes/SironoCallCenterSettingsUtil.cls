/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

global with sharing class SironoCallCenterSettingsUtil {
    /**
     * Provides access to the configurable call center settings object. All access should be driven through this
     * method instead of direct access to the custom setting to ensure that it's properly initialized.
     *
     * @returns the call center settings
     */
    global static Sirono_Call_Center_Settings__c getSironoCallCenterSettings() {
        Sirono_Call_Center_Settings__c sironoCallCenterSettings = Sirono_Call_Center_Settings__c.getOrgDefaults();
        if (sironoCallCenterSettings.Id == null) {
            sironoCallCenterSettings.Auto_Create_Overdue_Cases__c = true;
            sironoCallCenterSettings.Auto_Create_Precollection_Cases__c = true;
            sironoCallCenterSettings.Auto_Create_Payment_Plan_Error_Cases__c = true;
            sironoCallCenterSettings.Max_Number_Plan_Installments__c = 24;
            sironoCallCenterSettings.Min_Installment_Amount__c = 25.00;
            sironoCallCenterSettings.Min_Number_Plan_Installments__c = 1;

            //Assume that if the user is an admin, we want the profile-specific settings
            Set<Id> profileIds = (new Map<Id, Profile>([
                SELECT Id
                FROM Profile
                WHERE Name = 'System Administrator'
            ])).keySet();
            if (profileIds.contains(UserInfo.getProfileId())) {
                sironoCallCenterSettings.Min_Installment_Amount__c = 1.00;
            }

            insert sironoCallCenterSettings;
        }
        return sironoCallCenterSettings;
    }
}