/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Utility methods for working with custom permissions.
 */
public with sharing class CustomPermissionUtil {

    public static final String ADD_ADJUSTMENT = 'Add_Adjustment';

    private CustomPermissionUtil() {
        // Utility class
    }

    /**
     * Determines whether the current user has the custom permission with the specified name.
     *
     * @param the developer name of the custom permission
     * @return true if the current user has the specified custom permission; false if not
     */
    public static Boolean hasPermission(String permissionName) {
        if (String.isBlank(permissionName)) {
            return false;
        }

        List<CustomPermission> customPermissions = [
            SELECT Id
            FROM CustomPermission
            WHERE DeveloperName = :permissionName
            LIMIT 1
        ];
        if (customPermissions.size() != 1) {
            return false;
        }

        CustomPermission customPermission = customPermissions.get(0);
        List<SetupEntityAccess> setupEntityAccesses = [
            SELECT SetupEntityId
            FROM SetupEntityAccess
            WHERE SetupEntityId = :customPermission.Id
            AND ParentId IN (
                SELECT PermissionSetId
                FROM PermissionSetAssignment
                WHERE AssigneeId = :UserInfo.getUserId()
            )
        ];
        return !setupEntityAccesses.isEmpty();
    }
}