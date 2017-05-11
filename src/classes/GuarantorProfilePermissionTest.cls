/**
 * Created by mmartin on 5/10/17.
 */

@isTest
public with sharing class GuarantorProfilePermissionTest {

    private static final String TEST_USERNAME = 'testGTUser_' + System.now().millisecond() + '_@test.io';
    private static final String TEST_ADMIN_USERNAME = System.now().millisecond() + 'test2@test.com';

    @isTest
    // If I create the user in a setup method I cannot retrieve it in the test.
    // If everything is done in one method, the user can be retrieved. Go figure.
    // Verify that the user can read the sirono server NamedCredentials
    public static void readNamedCredentialsTest() {

        UserRole portalRole = [Select Id From UserRole Where DeveloperName = 'CEO' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAdminUser = new User(
                UserRoleId = portalRole.Id,
                ProfileId = profile1.Id,
                Username = TEST_ADMIN_USERNAME,
                Alias = 'batman',
                Email = 'bruce.wayne@wayneenterprises.com',
                EmailEncodingKey = 'UTF-8',
                Firstname = 'Bruce',
                Lastname = 'Wayne',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago'
        );


        Account a = null;
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            //Create portal account owner
            Database.insert(portalAdminUser);
            //Create account
            a = new Account(Name = 'TestAccount', OwnerId = portalAdminUser.Id);
            Database.insert(a);
        }

        System.runAs(portalAdminUser) {
            //Create Guarantor Contact record
            Contact gt = TestUtility.generateGuarantorContact();
            gt.Profile_Pointer_Id__c = 999;
            gt.AccountId = a.Id;
            gt.OwnerId = portalAdminUser.Id;
            Database.insert(gt);

            UserRole gr = [
                    SELECT Id, DeveloperName, PortalRole
                    FROM UserRole
                    WHERE DeveloperName = 'MakanaHealthCustomerUser'
                    LIMIT 1
            ];

            User usr = TestUtility.generateUser(Constants.GUARANTOR_PORTAL_PROFILE, gt.Id);
            usr.Username = TEST_USERNAME;
            usr.PortalRole = gr.PortalRole;

            INSERT usr;

            usr = null;
            usr = [
                    SELECT Alias, Email, EmailEncodingKey, LastName, LanguageLocaleKey,
                            LocaleSidKey, ProfileId, ContactId,
                            TimeZoneSidKey, Username
                    FROM User
                    WHERE Username = :TEST_USERNAME
                    LIMIT 1
            ];

            System.assertNotEquals(usr, null, 'User with username: ' + TEST_USERNAME + ' not found');

            System.runAs(usr) {
                Profile prof = [Select Id, Name from Profile where Id = :UserInfo.getProfileId()];
                System.debug('Reading as User: ' + UserInfo.getUserId() + ' with profile: ' + prof);

                String endpointURL = SironoRestClient.getEndpointString();
                System.assertNotEquals(endpointURL, null, 'Expected endpointURL string but got null');
            }
        }
    }
}