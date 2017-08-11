/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
private class CustomPermissionUtilTest {

    @IsTest
    static void testHasPermissionNegative() {
        System.assert(!CustomPermissionUtil.hasPermission(CustomPermissionUtil.ADD_ADJUSTMENT), 'The user should not have the Add Adjustment permission.');
    }

    @IsTest
    static void testHasPermissionPositive() {
        // Get the permission set that grants access to the Add Adjustment custom permission
        List<PermissionSet> permissionSets = [SELECT Id FROM PermissionSet WHERE Name = 'Hospital_Manager' LIMIT 1];
        PermissionSet hospitalManagerPermissionSet = (permissionSets.size() == 1) ? permissionSets.get(0) : null;
        System.assertNotEquals(null, hospitalManagerPermissionSet, 'Expected to find the Hospital Manager permission set.');

        // Assign that permission set to the current user
        PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(
            AssigneeId = UserInfo.getUserId(),
            PermissionSetId = hospitalManagerPermissionSet.Id
        );
        insert permissionSetAssignment;

        // Verify that the user has the permission now
        System.assert(CustomPermissionUtil.hasPermission(CustomPermissionUtil.ADD_ADJUSTMENT), 'The user should have the Add Adjustment permission.');
    }

    @IsTest
    static void testHasPermissionNoPermissionName() {
        System.assert(!CustomPermissionUtil.hasPermission(null), 'Null permission name should have returned false.');
        System.assert(!CustomPermissionUtil.hasPermission(''), 'Empty permission name should have returned false.');
        System.assert(!CustomPermissionUtil.hasPermission(' '), 'Whitespace-only permission name should have returned false.');
    }

    @IsTest
    static void testHasPermissionInvalidPermissionName() {
        System.assert(!CustomPermissionUtil.hasPermission('Invalid_Permission_Name'), 'Invalid permission name should have returned false.');
    }

}