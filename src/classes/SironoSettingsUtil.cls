/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 09-01-2016
 * Created by mmartin on 08-22-2016.
 * 10-03-2016: Viraj Rana - Tracker #127404553: Validate PaymentPlan against custom settings to get payment plan settings from Hierarchy custom settings.
 */

public with sharing class SironoSettingsUtil {

    enum orgType {
        sandbox, production
    }
    public static String sandbox = 'Sandbox';
    public static String production = 'Production';

    private static String endpointUrl;

    private static Map<String, String> sandboxUrls;
    static {
        sandboxUrls = new Map<String, String>();
        sandboxUrls.put('dev', 'https://toledo.stage.sirono.com');
        sandboxUrls.put('sandboxmm', 'https://toledo.stage.sirono.com');
        sandboxUrls.put('cloudcoop', 'https://toledo.stage.sirono.com');
        sandboxUrls.put('qa', 'https://training.sirono.com');
        sandboxUrls.put('demo', 'https://training.sirono.com');
    }

    public static Boolean isSandbox() {
        return [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }

    public static String getServerEndpoint() {
        if (isSandbox()) {
            if (endpointUrl == null) {
                String sandboxName = UserInfo.getUserName().substringAfterLast('.').toLowerCase();
                endpointUrl = sandboxUrls.get(sandboxName);
                                
                if (endpointUrl == null) {

                    throw new CalloutException('Sirono server is not configured');

                }
            }
            return endpointUrl;
        } else {
            return Label.PayStaffEndPointURL;
        }
    }

    public static SironoSettings__c getSettings() {
        SironoSettings__c settings = SironoSettings__c.getInstance(isSandbox() ? sandbox : production);
        if (settings == null) {
            settings = new SironoSettings__c();
            settings.Name = isSandbox() ? sandbox : production;
            insert settings;
            settings = SironoSettings__c.getInstance(isSandbox() ? sandbox : production);
        }

        return settings;
    }
    
    //10-03-2016: Viraj Rana - Tracker #127404553: Validate PaymentPlan against custom settings to get payment plan settings from Hierarchy custom settings.
    public static Sirono_Settings__c getPaymentPlanSettings(){
        
        Sirono_Settings__c sironoSettings = new Sirono_Settings__c();
        Id profileId = userinfo.getProfileId();
        
        sironoSettings = Sirono_Settings__c.getValues(profileId);
        
        if (sironoSettings == null) {
            //Check Profile Id for Operations Manager or System Administrator.
            List<profile> lstProfile = [select Id, name from profile where name = 'System Administrator' or name = 'Operations Manager'];
            set<Id> setProfileId = new set<Id>();
            if (lstProfile.size() > 0) {
                for (profile p : lstProfile) {
                    setProfileId.add(p.Id);
                }
            }
            if (!setProfileId.contains(profileId)) {
                sironoSettings = Sirono_Settings__c.getOrgDefaults();
            } else {
                //Create Custom Setting record for Operations Manager or System Administrator profile.
                Sirono_Settings__c PaymentPlanSettings = new Sirono_Settings__c(SetupOwnerId = profileId);
                PaymentPlanSettings.Max_Number_Plan_Installments__c = null;
                PaymentPlanSettings.Min_Installment_Amount__c = 1;
                PaymentPlanSettings.Min_Number_Plan_Installments__c = null;
                insert PaymentPlanSettings;
                
                sironoSettings = Sirono_Settings__c.getValues(profileId);
            }
        }
        
        return sironoSettings;
    }    
}