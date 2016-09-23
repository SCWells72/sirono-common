/**
 * Created by mmartin on 8/22/16.
 */

public with sharing class SironoSettingsUtil {

    enum ORG_TYPE {
        SANDBOX, PRODUCTION
    }
    public static String SANDBOX = 'Sandbox';
    public static String PRODUCTION = 'Production';

    private static String ENDPOINT_URL;

    private static Map<String, String> SANDBOX_URLS;
    static {
        SANDBOX_URLS = new Map<String, String>();
        SANDBOX_URLS.put('dev', 'https://toledo.stage.sirono.com');
        SANDBOX_URLS.put('sandboxmm', 'https://toledo.stage.sirono.com');
        SANDBOX_URLS.put('cloudcoop', 'https://toledo.stage.sirono.com');
        SANDBOX_URLS.put('qa', 'https://training.sirono.com');
        SANDBOX_URLS.put('demo', 'https://training.sirono.com');
    }

    public static Boolean isSandbox() {
        return [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }

    public static String getServerEndpoint() {
        if (isSandbox()) {
            if (ENDPOINT_URL == null) {
                String sandboxName = UserInfo.getUserName().substringAfterLast('.').toLowerCase();
                ENDPOINT_URL = SANDBOX_URLS.get(sandboxName);
                if (ENDPOINT_URL == null) {
                    throw new CalloutException('Sirono server is not configured');
                }
            }
            return ENDPOINT_URL;
        } else {
            return Label.PayStaffEndPointURL;
        }
    }

    public static SironoSettings__c getSettings() {
        SironoSettings__c settings = SironoSettings__c.getInstance(isSandbox() ? SANDBOX : PRODUCTION);
        if (settings == null) {
            settings = new SironoSettings__c();
            settings.Name = isSandbox() ? SANDBOX : PRODUCTION;
            insert settings;
            settings = SironoSettings__c.getInstance(isSandbox() ? SANDBOX : PRODUCTION);
        }

        return settings;
    }
}