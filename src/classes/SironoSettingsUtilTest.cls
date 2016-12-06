/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 09-01-2016
 * Created by mmartin on 08-22-16.
 */

@IsTest
private class SironoSettingsUtilTest {
    @testSetup static void setupSironoSettings(){
        SironoSettingsUtil.initializeSironoSettings();
    }

    /*Confirm PaymentPlanSettings are created */
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


    @isTest
    static void testValidEndpoint() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg1212.com');

        System.runAs(u){
            System.assert(SironoSettingsUtil.getServerEndpoint() != null, 'No endpoint for this org');
        }
    }
}