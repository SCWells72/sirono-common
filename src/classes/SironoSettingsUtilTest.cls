/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 09-01-2016
 * Created by mmartin on 08-22-16.
 */

@IsTest
private class SironoSettingsUtilTest {
    static testMethod void testNotNullSironoSettings() {
        SironoSettings__c settings = SironoSettingsUtil.getSettings();
        System.assert(settings != null, 'No settings created in this org');
    }

    static testMethod void testValidOrgSironoSettings() {
        SironoSettings__c settings = SironoSettingsUtil.getSettings();
        String settingsName = SironoSettingsUtil.isSandbox() ? SironoSettingsUtil.sandbox : SironoSettingsUtil.production;
        System.assert(settings.Name.equalsIgnoreCase(settingsName), 'No settings created for this org type');
    }

    static @isTest void main() {
    Test.startTest();
    try{
    TestUtility.setBlank = true;
    SironoSettingsUtil.getServerEndpoint();
}catch(exception ex){
System.assert(String.valueof(ex.getmessage()).Contains('Sirono server is not configured'));
}
Test.stopTest();

//TestUtility.isTest = true;
//SironoSettingsUtil.getServerEndpoint();

}

static @isTest void main1() {
TestUtility.isTest = true;
SironoSettingsUtil.getServerEndpoint();

TestUtility.setBlank = false;
TestUtility.isTest = false;
SironoSettingsUtil.getServerEndpoint();

}
}