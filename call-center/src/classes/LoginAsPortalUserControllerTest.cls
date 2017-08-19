/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
private class LoginAsPortalUserControllerTest {

    @IsTest
    static void testGetLoginAttributes() {

        Id guarantorPortalNetworkId = null;

        if (Schema.getGlobalDescribe().containsKey('network')) {
            User guarantorUser = TestUtility.getGuarantorCommunityUser();

            Test.startTest();
            Map<String, String> loginAttributes = LoginAsPortalUserController.getLoginAttributes(guarantorUser.ContactId);
            Test.stopTest();

            System.assertEquals(UserInfo.getOrganizationId(), loginAttributes.get('orgId'));
            System.assertEquals(guarantorUser.Id, loginAttributes.get('userId'));

            // TODO: The network name should be a constant or come from a custom setting
            List<SObject> networks = Database.query('SELECT Id FROM Network WHERE Name = \'Guarantor Portal\' LIMIT 1');
            guarantorPortalNetworkId = (networks.size() == 1) ? networks.get(0).Id : null;

            System.assertEquals(guarantorPortalNetworkId, loginAttributes.get('networkId'));
        }
    }

    @IsTest
    static void testGetLoginAttributesNoUser() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Test.startTest();
        try {
            LoginAsPortalUserController.getLoginAttributes(guarantorContact.Id);
            System.assert(false, 'Expected to receive an AuraHandledException');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('No portal user found for contact'));
        }
        Test.stopTest();
    }
}
