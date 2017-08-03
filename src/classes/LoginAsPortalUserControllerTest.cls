/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
private class LoginAsPortalUserControllerTest {

    @IsTest
    static void testGetLoginAttributes() {
        User guarantorUser = TestUtility.getGuarantorCommunityUser();

        Test.startTest();
        Map<String, String> loginAttributes = LoginAsPortalUserController.getLoginAttributes(guarantorUser.ContactId);
        Test.stopTest();

        System.assertEquals(UserInfo.getOrganizationId(), loginAttributes.get('orgId'));
        System.assertEquals(guarantorUser.Id, loginAttributes.get('userId'));
        List<Network> networks = [SELECT Id FROM Network WHERE Name = 'Guarantor Portal' LIMIT 1];
        Network guarantorPortalNetwork = (networks.size() == 1) ? networks.get(0) : null;
        System.assertEquals(guarantorPortalNetwork.Id, loginAttributes.get('networkId'));
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
            System.assertNotEquals(null, e.getMessage(), 'AuraHandledException should contain a mesasage');
        }
        Test.stopTest();
    }
}
