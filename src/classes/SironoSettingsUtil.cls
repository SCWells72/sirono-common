/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 09-01-2016
 * Created by mmartin on 08-22-2016.
 * 10-03-2016: Viraj Rana - Tracker #127404553: Validate PaymentPlan against custom settings to get payment plan settings from Hierarchy custom settings.
 */

public with sharing class SironoSettingsUtil {

    private static Map<String, String> sandboxUrls;
    static {
        sandboxUrls = new Map<String, String>();
        sandboxUrls.put('dev', 'https://toledo.stage.sirono.com');
        sandboxUrls.put('qa', 'https://training.sirono.com');
        sandboxUrls.put('demo', 'https://sf-demo.sirono.com');
        sandboxUrls.put('portal', 'https://sf-portal.sirono.com');
    }

    public static Boolean isSandbox() {
        return [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }

    public static String getSandboxName(){
        return userinfo.getUserName().substringAfterLast('.').toLowerCase();
    }

    public static String getServerEndpoint() {
        initializeSironoSettings();
        //always return the org default
        return Sirono_Settings__c.getOrgDefaults().Server_Endpoint_URL__c;
    }

    private static String getSandboxURL() {
        if (isSandbox()) {
            String sandboxURL = sandboxUrls.get(getSandboxName());

            // Return the dev endpoint for any unknown sandbox
            if (String.isEmpty(sandboxURL)) {
                sandboxURL = sandboxUrls.get('dev');
            }
            return sandboxURL;

        } else {
            return null;
        }
    }
    
    //10-03-2016: Viraj Rana - Tracker #127404553: Validate PaymentPlan against custom settings to get payment plan settings from Hierarchy custom settings.
    public static Sirono_Settings__c getPaymentPlanSettings(){
        initializeSironoSettings();
        return Sirono_Settings__c.getInstance(UserInfo.getProfileId());
    }

    public static void initializeSironoSettings(){
        Sirono_Settings__c sironoSettings = Sirono_Settings__c.getValues(UserInfo.getOrganizationId());
        if (sironoSettings == null) {
            sironoSettings = new Sirono_Settings__c();
            if (isSandbox()) {
                sironoSettings.Server_Endpoint_URL__c = getSandboxURL();
            }
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
    
    //12-06-2016 Viraj Rana: #127517419: Phone Number Verification
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