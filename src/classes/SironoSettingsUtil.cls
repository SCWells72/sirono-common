/*
 * Manage creation of/access to Sirono hierarchy custom settings.
 */

public with sharing class SironoSettingsUtil {

    public static String getServerEndpoint() {
        return SironoRestClient.getEndpointString();
    }
    
    //get settings specific to the user's profileId
    public static Sirono_Settings__c getPaymentPlanSettings(){
        initializeSironoSettings();
        return Sirono_Settings__c.getInstance(UserInfo.getProfileId());
    }

    public static void initializeSironoSettings(){
        Sirono_Settings__c sironoSettings = Sirono_Settings__c.getValues(UserInfo.getOrganizationId());
        if (sironoSettings == null) {
            sironoSettings = new Sirono_Settings__c();

            if (SironoSettingsSecurityContext.CREATE_CONTEXT.actionAllowed()) {
            	INSERT sironoSettings;	
            }

            sironoSettings = Sirono_Settings__c.getOrgDefaults();


            Set<Id> ids = (new Map<Id, Profile>([SELECT Id FROM Profile where name = 'System Administrator' or name = 'Operations Manager'])).keySet();
            for (Id id : ids) {
                sironoSettings = Sirono_Settings__c.getValues(id);
                if (sironoSettings == null) {
                    Sirono_Settings__c PaymentPlanSettings = new Sirono_Settings__c(SetupOwnerId = id);
                    PaymentPlanSettings.Max_Number_Plan_Installments__c = null;
                    PaymentPlanSettings.Min_Installment_Amount__c = 1;
                    PaymentPlanSettings.Min_Number_Plan_Installments__c = null;
                    
                    if (SironoSettingsSecurityContext.CREATE_CONTEXT.actionAllowed()) {
                        INSERT PaymentPlanSettings;
                    }
                }
            }
        }
    }

    //This Method is used to create custom setting.
    public static void generatePhoneNumVerification() {
        initializeSironoSettings();
        Sirono_Settings__c sironoSettings = Sirono_Settings__c.getOrgDefaults();
        if (!'US'.equals(sironoSettings.Country_Code__c)) {
            sironoSettings.Country_Code__c = 'US';
            sironoSettings.Format__c = 1;
            sironoSettings.Apikey__c = 'ac9b158e21153af4959ed5621d3c364c';

            if (SironoSettingsSecurityContext.UPSERT_CONTEXT.actionAllowed()) {
                UPSERT sironoSettings;
            }
        }
    }
}