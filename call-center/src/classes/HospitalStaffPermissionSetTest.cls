/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
public with sharing class HospitalStaffPermissionSetTest {
    private static String HOSPITAL_STAFF_USERNAME = 'hospitalstaff@runningsometests.org';

    @TestSetup
    public static void createCallCenterUser() {

        PermissionSet[] psets = [SELECT Id FROM PermissionSet WHERE Name IN :Constants.PERMISSION_SETS_HOSPITAL_STAFF];

        if (psets != null && psets.size() == Constants.PERMISSION_SETS_HOSPITAL_STAFF.size()) {
            User newUser = TestUtility.generateUser('Standard User', null);
            newUser.Username = HOSPITAL_STAFF_USERNAME;
            insert newUser;

            TestUtility.assignPermissionSets(newUser, Constants.PERMISSION_SETS_HOSPITAL_STAFF);
        }
    }

    @IsTest
    public static void testAddDiscount() {

        User[] users = [SELECT Id FROM User WHERE Username = :HOSPITAL_STAFF_USERNAME];

        if (!users.isEmpty()) {
            System.runAs(users[0]) {
                AddDiscountTest.webServiceCallout();
            }
        }
    }

    @IsTest
    public static void testCreatePaymentPlan() {
        User[] users = [SELECT Id FROM User WHERE Username = :HOSPITAL_STAFF_USERNAME];

        if (!users.isEmpty()) {
            System.runAs(users[0]) {
                AddPaymentPlanVFControllerTest.testCreatePaymentPlan();
            }
        }
    }

    @IsTest
    public static void testPromisePlan() {

        User[] users = [SELECT Id FROM User WHERE Username = :HOSPITAL_STAFF_USERNAME];

        if (!users.isEmpty()) {
            System.runAs(users[0]) {
                EditPaymentPlanTest.submitForPromisePlan();
            }
        }
    }

    @IsTest
    public static void testPayEstimate() {
        User[] users = [SELECT Id FROM User WHERE Username = :HOSPITAL_STAFF_USERNAME];

        if (!users.isEmpty()) {
            System.runAs(users[0]) {
                PayEstimateVFControllerTest.checkPayEstimateProcess();
            }
        }
    }

    @IsTest
    public static void testPaymentPlanGoodStanding() {
        User[] users = [SELECT Id FROM User WHERE Username = :HOSPITAL_STAFF_USERNAME];

        if (!users.isEmpty()) {
            System.runAs(users[0]) {
                PaymentPlanGoodStandingTest.testSuccess();
            }
        }
    }

    @IsTest
    public static void testAddPaymentPlan() {
        PaymentPlanServiceTest.setup();

        User[] users = [SELECT Id FROM User WHERE Username = :HOSPITAL_STAFF_USERNAME];

        if (!users.isEmpty()) {
            System.runAs(users[0]) {
                PaymentPlanServiceTest.testAddPaymentPlanForAuto();
            }
        }
    }
}