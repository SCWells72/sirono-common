/**
 * This class is use to test the logic of SironoSettingsUtil Class.
 **/

@IsTest
private class SironoSettingsUtilTest {
    
    /**
     * This method is used to setup preliminary data to let's all testmethods to execute as expected.
     **/
    @testSetup static void setupSironoSettings(){
        Test.startTest();
        SironoSettingsUtil.initializeSironoSettings();
        Test.stopTest();
        
        // Check system assert.
        Sirono_Settings__c sironoSettings = Sirono_Settings__c.getValues(UserInfo.getOrganizationId());
        System.assertNotEquals(sironoSettings, null, 'Should have failed due to sironoSettings are null.');
    }

    /**
     * This method tests the logic of PaymentPlanSettings are create or not.
     **/
    static testMethod void getPaymentPlanSetting() {
        Test.startTest();
        // call getPaymentPlanSettings method of Sirono Settings Util class.
        Sirono_Settings__c settings = SironoSettingsUtil.getPaymentPlanSettings();
        Test.stopTest();
        
        // Check system assert.
        System.assert(settings != null, 'No settings created in this org');
    }

    /**
     * Coverage the code for the SironoSettingsUtil class and init the variable
     * and call getPaymentPlanSettings Method for default setting
     **/
    static testMethod void getDefaultPaymentPlanSetting() {        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Chatter External User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg1212.com');
        
        Test.startTest();
        Sirono_Settings__c settings;
        System.runAs(u) {
            // call getPaymentPlanSettings method of Sirono Settings Util class.
            settings = SironoSettingsUtil.getPaymentPlanSettings();
        }
        Test.stopTest();
        
        // Check system assert.
        System.assert(settings != null, 'No settings created in this org');
    }

    /**
     * This method tests the logic of getting End Point Url.
     **/
    @isTest
    static void testValidEndpoint() {
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg1212.com');

        System.runAs(u){
            System.assert(SironoSettingsUtil.getServerEndpoint() != null, 'No endpoint for this org');
        }
        Test.stopTest();
    }
    
    /**
     * Check all access rights for a read only User using runAs.
     **/
    @isTest
    static void checkAccessRights() {
        List<SironoSettingsSecurityContext> allContexts = new List<SironoSettingsSecurityContext>{SironoSettingsSecurityContext.CREATE_CONTEXT,
        	SironoSettingsSecurityContext.UPSERT_CONTEXT
        };

        System.runAs(TestUtility.generateReadOnlyUser()) {
            for (SironoSettingsSecurityContext context: allContexts) {
                try {
                    context.actionAllowed();
                    System.assert(false, 'Expected permission to be denied for ' + context);
                } catch (SecurityUtils.SecurityException ex) {
                    System.debug('SecurityException : ' + ex);
                } catch (Exception e) {
                    System.assert(false, 'Expected SecurityUtils.SecurityException to be thrown, but got ' + e);
                }
            }
        }
    }
}