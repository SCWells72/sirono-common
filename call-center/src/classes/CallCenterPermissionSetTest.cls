/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
public with sharing class CallCenterPermissionSetTest {
    private static String CC_USERNAME = 'callcenteruser@runningsometests.org';

    @TestSetup
    public static void createCallCenterUser() {

        String[] psNames = new String[] { Constants.CALL_CENTER_PS, Constants.CALL_CENTER_LOCAL_PS };
        PermissionSet[] psets = [SELECT Id FROM PermissionSet WHERE Name IN :psNames];

        if (psets != null && psets.size() == psNames.size()) {
            User newUser = TestUtility.generateUser('Standard User', null);
            newUser.Username = CC_USERNAME;
            insert newUser;

            TestUtility.assignPermissionSet(Constants.CALL_CENTER_PS, newUser);
            TestUtility.assignPermissionSet(Constants.CALL_CENTER_LOCAL_PS, newUser);
        }
    }

    @IsTest
    public static void testAddDiscount() {

        User[] users = [SELECT Id FROM User WHERE Username = :CC_USERNAME];

        if (!users.isEmpty()) {
            System.runAs(users[0]) {
                AddDiscountTest.webServiceCallout();
            }
        }
    }

    @IsTest
    public static void testCreatePaymentPlan() {
        User[] users = [SELECT Id FROM User WHERE Username = :CC_USERNAME];

        if (!users.isEmpty()) {
            System.runAs(users[0]) {
                AddPaymentPlanVFControllerTest.testCreatePaymentPlan();
            }
        }
    }

    @IsTest
    public static void testPromisePlan() {

        User[] users = [SELECT Id FROM User WHERE Username = :CC_USERNAME];

        if (!users.isEmpty()) {
            System.runAs(users[0]) {
                EditPaymentPlanTest.submitForPromisePlan();
            }
        }
    }

    @IsTest
    public static void testPayEstimate() {
        User[] users = [SELECT Id FROM User WHERE Username = :CC_USERNAME];

        if (!users.isEmpty()) {
            System.runAs(users[0]) {
                PayEstimateVFControllerTest.checkPayEstimateProcess();
            }
        }
    }

    @IsTest
    public static void testPaymentPlanGoodStanding() {
        User[] users = [SELECT Id FROM User WHERE Username = :CC_USERNAME];

        if (!users.isEmpty()) {
            System.runAs(users[0]) {
                PaymentPlanGoodStandingTest.testSuccess();
            }
        }
    }

    @IsTest
    public static void testAddPaymentPlan() {
        User[] users = [SELECT Id FROM User WHERE Username = :CC_USERNAME];

        if (!users.isEmpty()) {
            System.runAs(users[0]) {
                PaymentPlanServiceTest.testAddPaymentPlanForAuto();
            }
        }
    }
}