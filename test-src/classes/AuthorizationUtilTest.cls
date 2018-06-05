/*
 * Copyright 2017-present Sirono LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

@IsTest
private class AuthorizationUtilTest {

    private static final String UNAUTHORIZED_PROFILE_NAME = 'Chatter Free User';
    private static final String UNAUTHORIZED_USER_NAME = 'unauthorized@nowhere.com';
    private static final SObjectType TEST_OBJECT_TYPE = Opportunity.SObjectType;

    @TestSetup
    static void setup() {
        // Get a profile that provides very few permissions
        Profile profile = [SELECT Id FROM Profile WHERE Name = :UNAUTHORIZED_PROFILE_NAME LIMIT 1];

        // Create a user in that profile
        User unauthorizedUser = new User(
            ProfileId = profile.Id,
            Username = UNAUTHORIZED_USER_NAME,
            Email = UNAUTHORIZED_USER_NAME,
            Alias = 'unauth',
            FirstName = 'Unauthorized',
            LastName = 'User',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = UserInfo.getLocale(),
            LocaleSidKey = UserInfo.getLocale(),
            TimeZoneSidKey = UserInfo.getTimeZone().getID()
        );
        insert unauthorizedUser;
    }

    private static User getUnuauthorizedUser() {
        return [SELECT Id FROM User WHERE Username = :UNAUTHORIZED_USER_NAME LIMIT 1];
    }

    private static void verifyCheckMethods(Boolean authorized) {
        Assert.equals(authorized, AuthorizationUtil.isAccessible(TEST_OBJECT_TYPE));
        Assert.equals(authorized, AuthorizationUtil.isCreateable(TEST_OBJECT_TYPE));
        Assert.equals(authorized, AuthorizationUtil.isUpdateable(TEST_OBJECT_TYPE));
        Assert.equals(authorized, AuthorizationUtil.isUpsertable(TEST_OBJECT_TYPE));
        Assert.equals(authorized, AuthorizationUtil.isDeletable(TEST_OBJECT_TYPE));
        Assert.equals(authorized, AuthorizationUtil.isUndeletable(TEST_OBJECT_TYPE));
        // TODO: Evidently even the unauthorized user can merge
        //Assert.equals(authorized, AuthorizationUtil.isMergeable(Opportunity.SObjectType));
    }

    private static void verifyAssertMethods(Boolean authorized) {
        try {
            AuthorizationUtil.assertAccessible(TEST_OBJECT_TYPE);
            Assert.isTrue(authorized);
        } catch (AuthorizationException e) {
            Assert.isFalse(authorized);
        }
        try {
            AuthorizationUtil.assertCreateable(TEST_OBJECT_TYPE);
            Assert.isTrue(authorized);
        } catch (AuthorizationException e) {
            Assert.isFalse(authorized);
        }
        try {
            AuthorizationUtil.assertUpdateable(TEST_OBJECT_TYPE);
            Assert.isTrue(authorized);
        } catch (AuthorizationException e) {
            Assert.isFalse(authorized);
        }
        try {
            AuthorizationUtil.assertUpsertable(TEST_OBJECT_TYPE);
            Assert.isTrue(authorized);
        } catch (AuthorizationException e) {
            Assert.isFalse(authorized);
        }
        try {
            AuthorizationUtil.assertDeletable(TEST_OBJECT_TYPE);
            Assert.isTrue(authorized);
        } catch (AuthorizationException e) {
            Assert.isFalse(authorized);
        }
        try {
            AuthorizationUtil.assertUndeletable(TEST_OBJECT_TYPE);
            Assert.isTrue(authorized);
        } catch (AuthorizationException e) {
            Assert.isFalse(authorized);
        }
        // TODO: Evidently even the unauthorized user can merge
//        try {
//            AuthorizationUtil.assertMergeable(Opportunity.SObjectType);
//            Assert.isTrue(authorized);
//        } catch (AuthorizationException e) {
//            Assert.isFalse(authorized);
//        }
    }

    @IsTest
    static void testAuthorizedUser() {
        // The test is running as the admin user and should have carte blanche access
        verifyCheckMethods(true);
        verifyAssertMethods(true);
    }

    @IsTest
    static void testUnauthorizedUser() {
        User unuauthorizedUser = getUnuauthorizedUser();
        System.runAs(unuauthorizedUser) {
            verifyCheckMethods(false);
            verifyAssertMethods(false);
        }
    }
}