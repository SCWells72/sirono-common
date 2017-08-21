/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

// TODO: The email address for the created users
String emailAddress = 'scott.wells@sirono.com';

// TODO: Something unique to make usernames unique, e.g., dev, qa, or your initials
//String uniquifier = 'dev';
//String uniquifier = 'qa';
String uniquifier = 'scw';

// Get info about the profile and permission sets for portal users
Profile customerCommunityLoginUserProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];

Map<String, PermissionSet> permissionSetsByName = new Map<String, PermissionSet>();
for (PermissionSet permissionSet : [SELECT Id, Name FROM PermissionSet]) {
    permissionSetsByName.put(permissionSet.Name, permissionSet);
}
PermissionSet guarantorPermissionSet = permissionSetsByName.get('Guarantor');
PermissionSet guarantorLocalPermissionSet = permissionSetsByName.get('Guarantor_Local');

// Deactivate and unlink all existing portal users
/*
List<User> existingPortalUsers = [
    SELECT Id, CommunityNickname, IsActive, IsPortalEnabled
    FROM User
    WHERE ProfileId = :customerCommunityLoginUserProfile.Id
    AND IsActive = TRUE
];
if (!existingPortalUsers.isEmpty()) {
    for (User existingPortalUser : existingPortalUsers) {
        existingPortalUser.CommunityNickname = existingPortalUser.CommunityNickname + '.' + System.now().getTime();
        existingPortalUser.IsActive = false;
        existingPortalUser.IsPortalEnabled = false;
    }
    List<Database.SaveResult> saveResults = Database.update(existingPortalUsers, false);
    for (Database.SaveResult saveResult : saveResults) {
        if (!saveResult.isSuccess()) {
            System.debug(LoggingLevel.ERROR, JSON.serializePretty(saveResult.getErrors()));
        }
    }
}
*/

// Create a new portal user for each contact
List<Contact> guarantorContacts = [
    SELECT Id, FirstName, LastName, Name, Profile_Pointer_Id__c
    FROM Contact
    WHERE Profile_Pointer_Id__c <> NULL
    ORDER BY Name
];
if (!guarantorContacts.isEmpty()) {
    // Find any existing users for these contacts
    System.debug('Searching for existing portal users for ' + guarantorContacts.size() + ' Guarantor contacts.');
    Set<Id> guarantorContactIds = new Set<Id>();
    for (Contact guarantorContact : guarantorContacts) {
        guarantorContactIds.add(guarantorContact.Id);
    }

    Map<Id, User> portalUsersByGuarantorContactId = new Map<Id, User>();
    List<User> existingUsers = [
        SELECT Id, ContactId, Contact.Name, Contact.Profile_Pointer_Id__c, Username
        FROM User
        WHERE ProfileId = :customerCommunityLoginUserProfile.Id
        AND ContactId IN :guarantorContactIds
        AND IsActive = TRUE
    ];
    System.debug('Found ' + existingUsers.size() + ' existing portal users.');
    for (User existingUser : existingUsers) {
        System.debug('Found existing user ' + existingUser.Username + ' for Guarantor contact ' + existingUser.Contact.Name + ' (' + existingUser.Contact.Profile_Pointer_Id__c + ').');
        portalUsersByGuarantorContactId.put(existingUser.ContactId, existingUser);
    }

    // Now either create or update a user for each contact
    List<User> portalUsers = new List<User>();
    for (Contact guarantorContact : guarantorContacts) {
        User portalUser = portalUsersByGuarantorContactId.get(guarantorContact.Id);
        if (portalUser == null) {
            System.debug('Creating a new portal user for contact ' + guarantorContact.Name + ' (' + guarantorContact.Profile_Pointer_Id__c + ').');
            portalUser = new User();
            portalUser.ContactId = guarantorContact.Id;
        } else {
            System.debug('Updating an existing portal user for contact ' + guarantorContact.Name + ' (' + guarantorContact.Profile_Pointer_Id__c + ').');
        }

        String alias = String.valueOf((Integer) guarantorContact.Profile_Pointer_Id__c);
        String nickname = guarantorContact.FirstName.toLowerCase() + '.' + guarantorContact.LastName.toLowerCase() + '.' + alias;

        portalUser.ProfileId = customerCommunityLoginUserProfile.Id;
        portalUser.Username = nickname + '@' + uniquifier + '.sirono.com';
        portalUser.Email = emailAddress;
        portalUser.Alias = alias;
        portalUser.CommunityNickname = nickname;
        portalUser.FirstName = guarantorContact.FirstName;
        portalUser.LastName = guarantorContact.LastName;
        portalUser.EmailEncodingKey = 'UTF-8';
        portalUser.LanguageLocaleKey = 'en_US';
        portalUser.LocaleSidKey = 'en_US';
        portalUser.TimeZoneSidKey = 'America/Chicago';

        portalUsers.add(portalUser);
    }
    if (!portalUsers.isEmpty()) {
        System.debug('Upserting ' + portalUsers.size() + ' portal users for ' + guarantorContacts.size() + ' Guarantor contacts.');
        List<Database.UpsertResult> upsertResults = Database.upsert(portalUsers, false);
        for (Database.UpsertResult upsertResult : upsertResults) {
            if (!upsertResult.isSuccess()) {
                System.debug(LoggingLevel.ERROR, JSON.serializePretty(upsertResult.getErrors()));
            }
        }

        // Assign the Guarantor permission sets to the users
        System.debug('Assigning the Guarantor permission sets to the portal users.');
        List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
        for (User portalUser : portalUsers) {
            permissionSetAssignments.add(new PermissionSetAssignment(
                AssigneeId = portalUser.Id,
                PermissionSetId = guarantorPermissionSet.Id
            ));
            permissionSetAssignments.add(new PermissionSetAssignment(
                AssigneeId = portalUser.Id,
                PermissionSetId = guarantorLocalPermissionSet.Id
            ));
        }
        List<Database.SaveResult> saveResults = Database.insert(permissionSetAssignments, false);
        for (Database.SaveResult saveResult : saveResults) {
            if (!saveResult.isSuccess()) {
                if ((saveResult.getErrors().size() == 1) && (saveResult.getErrors().get(0).getStatusCode() == StatusCode.DUPLICATE_VALUE)) {
                    continue;
                } else {
                    System.debug(LoggingLevel.ERROR, JSON.serializePretty(saveResult.getErrors()));
                }
            }
        }
    }
}
