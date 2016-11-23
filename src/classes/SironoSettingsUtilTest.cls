/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 09-01-2016
 * Created by mmartin on 08-22-16.
 */

@IsTest
private class SironoSettingsUtilTest {
    /* Coverage the code for the SironoSettingsUtil class and init the variable,
     * call getSettings,isSandbox and getServerEndpoint Method
     */
    static testMethod void getSetting() {
        //call getSettings method of Sirono Settings Util class.
        SironoSettings__c settings = SironoSettingsUtil.getSettings();
        //Check system assert.
        System.assert(settings != null, 'No settings created in this org');
    }
    /*Coverage the code for the SironoSettingsUtil class and init the variable and call getPaymentPlanSettings Method */
    static testMethod void getPaymentPlanSetting() {
        //call getPaymentPlanSettings method of Sirono Settings Util class.
        Sirono_Settings__c settings = SironoSettingsUtil.getPaymentPlanSettings();
        //Check system assert.
        System.assert(settings != null, 'No settings created in this org');
    }
    /*Coverage the code for the SironoSettingsUtil class and init the variable and call getPaymentPlanSettings Method for default setting */
    static testMethod void getDefaultPaymentPlanSetting() {        
        Profile p = [SELECT Id FROM Profile WHERE Name='Chatter External User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg1212.com');
        Sirono_Settings__c settings;
        System.runAs(u) {
            //call getPaymentPlanSettings method of Sirono Settings Util class.
            settings = SironoSettingsUtil.getPaymentPlanSettings();
        }
        //Check system assert.
        System.assert(settings != null, 'No settings created in this org');
    }

    /* Coverage the code for the AddNote class and init the variable,
     * call doSubmit,getPaymentPlanSettings and isSandbox Method
     */
    static testMethod void getSettingName() {
        //call getSettings method of Sirono Settings Util class.
        SironoSettings__c settings = SironoSettingsUtil.getSettings();
        //Check the setting is sandbox or production.
        String settingsName = SironoSettingsUtil.isSandbox() ? SironoSettingsUtil.sandbox : SironoSettingsUtil.production;
        //Check system assert.
        System.assert(settings.Name.equalsIgnoreCase(settingsName), 'No settings created for this org type');
    }

    @isTest
    static void testValidEndpoint() {

        list<SironoSettings__c> testSironoSettings = TestUtility.generateSironoSettings();
        insert testSironoSettings;

        System.assert(SironoSettingsUtil.getServerEndpoint() != null, 'No valid endpoint for this org');
    }
}