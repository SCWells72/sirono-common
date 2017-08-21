/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/*
 * Manage creation of/access to Sirono hierarchy custom settings.
 */
public with sharing class SironoSettingsUtil {

    public static String getServerEndpoint() {
        return SironoRestClient.getEndpointString();
    }

    //get settings specific to the user's profileId
    public static Sirono_Settings__c getSironoSettings() {
        if (Test.isRunningTest()) {
            //if there are settings already out there for this user profile, return them
            Sirono_Settings__c sironoSettings = Sirono_Settings__c.getInstance(UserInfo.getProfileId());

            if (sironoSettings == null || sironoSettings.Apikey__c == null) {
                sironoSettings = Sirono_Settings__c.getValues(UserInfo.getOrganizationId());
                if (sironoSettings == null) {
                    sironoSettings = new Sirono_Settings__c();
                    sironoSettings.Apikey__c = 'testAPIKey';
                    sironoSettings.Country_Code__c = 'US';
                    sironoSettings.Format__c = 1;
                }
            }

            return sironoSettings;
        }

        return Sirono_Settings__c.getInstance(UserInfo.getProfileId());
    }
}