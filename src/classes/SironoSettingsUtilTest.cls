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

    /* Coverage the code for the AddNote class and init the variable,
     * call doSubmit,getPaymentPlanSettings and isSandbox Method
     */
    static testMethod void getSettingName() {
        //call getSettings method of Sirono Settings Util class.
        SironoSettings__c settings = SironoSettingsUtil.getSettings();
        
        //Check the setting is sandbox or production.
        String settingsName = SironoSettingsUtil.isSandbox() ? SironoSettingsUtil.sandbox: SironoSettingsUtil.production;
        
        //Check system assert.
        System.assert(settings.Name.equalsIgnoreCase(settingsName), 'No settings created for this org type');
    }

    @isTest
    static void testValidEndpoint() {
        System.assert(SironoSettingsUtil.getServerEndpoint() != null, 'No valid endpoint for this org');
    }
}