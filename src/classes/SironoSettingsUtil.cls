/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 09-01-2016
 * Created by mmartin on 08-22-2016.
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
        if (TestUtility.isTest) {
            return false;
        }
        return [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }

    public static String getServerEndpoint() {
        if (isSandbox()) {
            if (endpointUrl == null) {
                String sandboxName = UserInfo.getUserName().substringAfterLast('.').toLowerCase();
                endpointUrl = sandboxUrls.get(sandboxName);
                if (TestUtility.setBlank) {
                    endpointUrl = null;
                }
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
}