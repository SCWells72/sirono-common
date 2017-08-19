/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Database actions for a User.
 */
public with sharing class UserDao {

  /**
   * Get a user by userId.
   *
   * @param Id userId - The user Id of the user to retrieve.
   * @returns User - The user.
   */
    public static User getUser(String userId) {
        //TODO: SecurityContext
        return [
            SELECT
                Id,
                ContactId,
                Contact.FirstName,
                Contact.sPRS__Guarantor_Id__c
            FROM User
            WHERE Id = :userId
        ];

    }

}