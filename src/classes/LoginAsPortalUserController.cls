/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class LoginAsPortalUserController {

    @AuraEnabled
    public static Map<String, String> getLoginAttributes(String contactId) {
        Map<String, String> loginAttributes = new Map<String, String>();

        loginAttributes.put('orgId', UserInfo.getOrganizationId());

        List<Contact> contacts = [SELECT Id, Name FROM Contact WHERE Id = :contactId LIMIT 1];
        Contact contact = (contacts.size() == 1) ? contacts.get(0) : null;
        if (contact == null) {
            throw new AuraHandledException('No contact found for ID ' + contactId + '.');
        }

        List<User> users = [SELECT Id FROM User WHERE ContactId = :contactId AND IsActive = TRUE LIMIT 1];
        User contactUser = (users.size() == 1) ? users.get(0) : null;
        if (contactUser == null) {
            throw new AuraHandledException('No portal user found for contact ' + contact.Name + '.');
        }
        loginAttributes.put('userId', contactUser.Id);

        // TODO: This should be a constant
        List<Network> networks = [SELECT Id FROM Network WHERE Name = 'Guarantor Portal' LIMIT 1];
        Network guarantorPortalNetwork = (networks.size() == 1) ? networks.get(0) : null;
        if (guarantorPortalNetwork == null) {
            throw new AuraHandledException('No network found with name Guarantor Portal.');
        }
        loginAttributes.put('networkId', guarantorPortalNetwork.Id);

        return loginAttributes;
    }
}