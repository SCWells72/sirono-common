/*
 * Manage creation of/access to Sirono hierarchy custom settings.
 */

public with sharing class SironoSettingsUtil {

    public static String getServerEndpoint() {
        return SironoRestClient.getEndpointString();
    }

    //get settings specific to the user's profileId
    public static Sirono_Settings__c getPaymentPlanSettings() {
        if (Test.isRunningTest()) {
            //if there are settings already out there for this user profile, return them
            Sirono_Settings__c sironoSettings = Sirono_Settings__c.getInstance(UserInfo.getProfileId());

            if (sironoSettings == null || sironoSettings.Apikey__c == null) {
                sironoSettings = Sirono_Settings__c.getValues(UserInfo.getOrganizationId());
                if (sironoSettings == null) {
                    sironoSettings = new Sirono_Settings__c();
                    setNamespacePrefixes(sironoSettings);

                    sironoSettings.Apikey__c = 'testAPIKey';
                    sironoSettings.Country_Code__c = 'US';
                    sironoSettings.Format__c = 1;
                    sironoSettings.Max_Number_Plan_Installments__c = 24;
                    sironoSettings.Min_Installment_Amount__c = 25.00;
                    sironoSettings.Min_Number_Plan_Installments__c = 1;
                }

                Set<Id> ids = (new Map<Id, Profile>([SELECT Id FROM Profile WHERE name = 'System Administrator' OR name = 'Operations Manager'])).keySet();
                //Assume that if the user is one of these, we want the profile-specific settings
                if (ids.contains(UserInfo.getProfileId())) {
                    sironoSettings.Min_Installment_Amount__c = 1;
                }
            }

            return sironoSettings;
        }

        return Sirono_Settings__c.getInstance(UserInfo.getProfileId());
    }

    public static void setNamespacePrefixes(Sirono_Settings__c sironoSettings) {
        //This gives '' in any development org and 'ns' within the package
        sironoSettings.NS_Prefix__c = SironoSettingsUtil.class.getName().substringBefore('SironoSettingsUtil').substringBefore('.');
        //Getting a single token which can be used to qualify Apex Classes
        sironoSettings.NS_Dot_Prefix__c = SironoSettingsUtil.class.getName().substringBefore('SironoSettingsUtil');
        //Single token to qualify Salesforce Objects, fields & pages
        sironoSettings.NS_Bar_Prefix__c = SObjectType.Charge_Group__c.Name.substringBefore('Charge_Group__c');
    }

    public static String getBusinessHoursId() {
        Sirono_Settings__c sironoSettings = Sirono_Settings__c.getInstance();
        setProcessBuilderIds(sironoSettings);
        return sironoSettings.Business_Hours_Id__c;
    }

    /**
     * Queries and populates the IDs used in Process Builder flows in the specified settings object.
     *
     * @param sironoSettings the settings object
     */
    public static void setProcessBuilderIds(Sirono_Settings__c sironoSettings) {
        if (sironoSettings != null) {
            Boolean updateRequired = false;

            if (String.isBlank(sironoSettings.Business_Hours_Id__c)) {
                // Query the default business hours
                List<BusinessHours> businessHours = [
                    SELECT Id
                    FROM BusinessHours
                    WHERE Name = 'Default'
                    LIMIT 1
                ];
                if (!businessHours.isEmpty()) {
                    sironoSettings.Business_Hours_Id__c = businessHours[0].Id;
                    updateRequired = true;
                }
            }

            if (String.isBlank(sironoSettings.Automated_Case_Record_Type_Id__c)) {
                // Grab the automated case record type ID
                sironoSettings.Automated_Case_Record_Type_Id__c = RecordTypeUtil.automatedCaseRt;
                updateRequired = true;
            }

            if (updateRequired) {
                upsert sironoSettings;
            }
        }
    }
}