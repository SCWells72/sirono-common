/**
 * Created by mmartin on 8/22/16.
 */

@IsTest
private class SironoSettingsUtilTest {
    static testMethod void testNotNullSironoSettings() {
        SironoSettings__c settings = SironoSettingsUtil.getSettings();
        System.assert(settings != null, 'No settings created in this org');
    }

    static testMethod void testValidOrgSironoSettings() {
        SironoSettings__c settings = SironoSettingsUtil.getSettings();
        String settingsName = SironoSettingsUtil.isSandbox() ? SironoSettingsUtil.SANDBOX: SironoSettingsUtil.PRODUCTION;
        System.assert(settings.Name.equalsIgnoreCase(settingsName), 'No settings created for this org type');
    }
}