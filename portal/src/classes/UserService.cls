/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * UserService
 **/
public with sharing class UserService extends AbstractService {

  /**
   * Get the UserWrapper for the current user.
   *
   * @return UserWrapper - The User.
   */
    public static UserWrapper getCurrentUser() {
        UserWrapper uw = new UserWrapper(UserDao.getUser(UserInfo.getUserId()));
        return uw;
    }
}