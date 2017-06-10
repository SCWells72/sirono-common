/**
 * Database actions for a User.
 */

public with sharing class UserDao extends AbstractDao {

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
            Contact.Profile_Pointer_ID__c
        FROM User
        WHERE Id = :userId
    ];

  }

}