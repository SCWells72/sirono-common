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

/**
 * Utility class that provides convenient methods for performing CRUD authorization checks and assertions.
 **/
public with sharing class AuthorizationUtil {

    private AuthorizationUtil() {
        // Utility class
    }

    // CRUD check convenience methods

    /**
     * Checks whether the specified object type can be accessed (queried) by the current user.
     *
     * @param sobjectType the sobject type
     *
     * @return <code>true</code> if the sobject type can be accessed; otherwise <code>false</code>
     */
    public static Boolean isAccessible(SObjectType sobjectType) {
        return (sobjectType != null) && sobjectType.getDescribe().isAccessible();
    }

    /**
     * Checks whether the specified object type can be created by the current user.
     *
     * @param sobjectType the sobject type
     *
     * @return <code>true</code> if the sobject type can be created; otherwise <code>false</code>
     */
    public static Boolean isCreateable(SObjectType sobjectType) {
        return (sobjectType != null) && sobjectType.getDescribe().isCreateable();
    }

    /**
     * Checks whether the specified object type can be updated by the current user.
     *
     * @param sobjectType the sobject type
     *
     * @return <code>true</code> if the sobject type can be updated; otherwise <code>false</code>
     */
    public static Boolean isUpdateable(SObjectType sobjectType) {
        return (sobjectType != null) && sobjectType.getDescribe().isUpdateable();
    }

    /**
     * Checks whether the specified object type can be both created and updated by the current user.
     *
     * @param sobjectType the sobject type
     *
     * @return <code>true</code> if the sobject type can be created and updated; otherwise <code>false</code>
     */
    public static Boolean isUpsertable(SObjectType sobjectType) {
        return isCreateable(sobjectType) && isUpdateable(sobjectType);
    }

    /**
     * Checks whether the specified object type can be deleted by the current user.
     *
     * @param sobjectType the sobject type
     *
     * @return <code>true</code> if the sobject type can be deleted; otherwise <code>false</code>
     */
    public static Boolean isDeletable(SObjectType sobjectType) {
        return (sobjectType != null) && sobjectType.getDescribe().isDeletable();
    }

    /**
     * Checks whether the specified object type can be undeleted by the current user.
     *
     * @param sobjectType the sobject type
     *
     * @return <code>true</code> if the sobject type can be undeleted; otherwise <code>false</code>
     */
    public static Boolean isUndeletable(SObjectType sobjectType) {
        return (sobjectType != null) && sobjectType.getDescribe().isUndeletable();
    }

    /**
     * Checks whether the specified object type can be merged by the current user.
     *
     * @param sobjectType the sobject type
     *
     * @return <code>true</code> if the sobject type can be merged; otherwise <code>false</code>
     */
    public static Boolean isMergeable(SObjectType sobjectType) {
        return (sobjectType != null) && sobjectType.getDescribe().isMergeable();
    }

    // CRUD assert convenience methods

    /**
     * Checks whether the specified object type can be accessed (queried) by the current user and throws an
     * <code>AuthorizationException</code> if not.
     *
     * @param sobjectType the sobject type
     */
    public static void assertAccessible(SObjectType sobjectType) {
        if (!isAccessible(sobjectType)) {
            throw new AuthorizationException(UserInfo.getUserName() + ' does not have access rights for ' + getSobjectTypeName(sobjectType));
        }
    }

    /**
     * Checks whether the specified object type can be created by the current user and throws an
     * <code>AuthorizationException</code> if not.
     *
     * @param sobjectType the sobject type
     */
    public static void assertCreateable(SObjectType sobjectType) {
        if (!isCreateable(sobjectType)) {
            throw new AuthorizationException(UserInfo.getUserName() + ' does not have create rights for ' + getSobjectTypeName(sobjectType));
        }
    }

    /**
     * Checks whether the specified object type can be updated by the current user and throws an
     * <code>AuthorizationException</code> if not.
     *
     * @param sobjectType the sobject type
     */
    public static void assertUpdateable(SObjectType sobjectType) {
        if (!isUpdateable(sobjectType)) {
            throw new AuthorizationException(UserInfo.getUserName() + ' does not have update rights for ' + getSobjectTypeName(sobjectType));
        }
    }

    /**
     * Checks whether the specified object type can be both created and updated by the current user and throws an
     * <code>AuthorizationException</code> if not.
     *
     * @param sobjectType the sobject type
     */
    public static void assertUpsertable(SObjectType sobjectType) {
        if (!isUpsertable(sobjectType)) {
            throw new AuthorizationException(UserInfo.getUserName() + ' does not have create and update rights for ' + getSobjectTypeName(sobjectType));
        }
    }

    /**
     * Checks whether the specified object type can be deleted by the current user and throws an
     * <code>AuthorizationException</code> if not.
     *
     * @param sobjectType the sobject type
     */
    public static void assertDeletable(SObjectType sobjectType) {
        if (!isDeletable(sobjectType)) {
            throw new AuthorizationException(UserInfo.getUserName() + ' does not have delete rights for ' + getSobjectTypeName(sobjectType));
        }
    }

    /**
     * Checks whether the specified object type can be undeleted by the current user and throws an
     * <code>AuthorizationException</code> if not.
     *
     * @param sobjectType the sobject type
     */
    public static void assertUndeletable(SObjectType sobjectType) {
        if (!isUndeletable(sobjectType)) {
            throw new AuthorizationException(UserInfo.getUserName() + ' does not have undelete rights for ' + getSobjectTypeName(sobjectType));
        }
    }

    /**
     * Checks whether the specified object type can be merged by the current user and throws an
     * <code>AuthorizationException</code> if not.
     *
     * @param sobjectType the sobject type
     */
    public static void assertMergeable(SObjectType sobjectType) {
        if (!isMergeable(sobjectType)) {
            throw new AuthorizationException(UserInfo.getUserName() + ' does not have merge rights for ' + getSobjectTypeName(sobjectType));
        }
    }

    /**
     * Returns the name of the specified object type.
     *
     * @param sobjectType the object type
     *
     * @return the name of the object type or <code>&lt;unknown&gt;</code> if the object type is <code>null</code>
     */
    private static String getSobjectTypeName(SObjectType sobjectType) {
        return (sobjectType != null) ? sobjectType.getDescribe().getName() : '<unknown>';
    }
}