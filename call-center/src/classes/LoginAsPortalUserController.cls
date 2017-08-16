/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class LoginAsPortalUserController {

    /**
     * Builds and returns a map of login attributes for logging in as the portal user.
     *
     * @param contactId the ID of the contact associated with the user for which a login should occur
     * @return a map of login attributes that can be used to impersonate the specified contact's user
     */
    @AuraEnabled
    public static Map<String, String> getLoginAttributes(String contactId) {
        Map<String, String> loginAttributes = new Map<String, String>();

        loginAttributes.put('orgId', UserInfo.getOrganizationId());

        List<Contact> contacts = [SELECT Id, Name FROM Contact WHERE Id = :contactId LIMIT 1];
        Contact contact = (contacts.size() == 1) ? contacts.get(0) : null;
        if (contact == null) {
            throw LightningUtil.newAuraHandledException('No contact found for ID ' + contactId + '.');
        }

        List<User> users = [SELECT Id FROM User WHERE ContactId = :contactId AND IsActive = TRUE LIMIT 1];
        User contactUser = (users.size() == 1) ? users.get(0) : null;
        if (contactUser == null) {
            throw LightningUtil.newAuraHandledException('No portal user found for contact ' + contact.Name + '.');
        }
        loginAttributes.put('userId', contactUser.Id);

        Id guarantorPortalNetworkId = null;
        if (Schema.getGlobalDescribe().containsKey('network')) {
            // TODO: The network name should be a constant
            List<SObject> networks = Database.query('SELECT Id FROM Network WHERE Name = \'Guarantor Portal\' LIMIT 1');
            guarantorPortalNetworkId = (networks.size() == 1) ? networks.get(0).Id : null;
        }

        if (guarantorPortalNetworkId == null) {
            throw new AuraHandledException('No network found with name Guarantor Portal.');
        }
        loginAttributes.put('networkId', guarantorPortalNetworkId);

        return loginAttributes;
    }
}