@isTest
public with sharing class CallCenterPermissionSetTest {
    private static String CC_USERNAME = 'callcenteruser@runningsometests.org';

    @TestSetup
    public static void createCallCenterUser() {

        String[] psNames = new String[]{Constants.CALL_CENTER_PS, Constants.CALL_CENTER_LOCAL_PS};
        PermissionSet[] psets = [SELECT ID From PermissionSet WHERE Name IN :psNames];

        if (psets != null && psets.size() == psNames.size()) {
            User newUser = TestUtility.generateUser('Standard User', null);
            newUser.Username = CC_USERNAME;
            INSERT newUser;

            TestUtility.assignPermissionSet(Constants.CALL_CENTER_PS, newUser);
            TestUtility.assignPermissionSet(Constants.CALL_CENTER_LOCAL_PS, newUser);
        }
    }

    @isTest
    public static void testAddDiscount() {

        User[] users = [SELECT Id FROM User WHERE Username = :CC_USERNAME];

        if (!users.isEmpty()) {
            System.runAs(users[0]) {
                AddDiscountTest.webServiceCallout();
            }
        }
    }

    @isTest
    public static void testCreatePaymentPlan() {
        User[] users = [SELECT Id FROM User WHERE Username = :CC_USERNAME];

        if (!users.isEmpty()) {
            System.runAs(users[0]) {
                AddPaymentPlanVFControllerTest.testCreatePaymentPlan();
            }
        }
    }

    @isTest
    public static void testPromisePlan() {

        User[] users = [SELECT Id FROM User WHERE Username = :CC_USERNAME];

        if (!users.isEmpty()) {
            System.runAs(users[0]) {
                EditPaymentPlanTest.submitForPromisePlan();
            }
        }
    }

    @isTest
    public static void testPayEstimate() {
        User[] users = [SELECT Id FROM User WHERE Username = :CC_USERNAME];

        if (!users.isEmpty()) {
            System.runAs(users[0]) {
                PayEstimateVFControllerTest.checkPayEstimateProcess();
            }
        }
    }

    @isTest
    public static void testPaymentPlanGoodStanding() {
        User[] users = [SELECT Id FROM User WHERE Username = :CC_USERNAME];

        if (!users.isEmpty()) {
            System.runAs(users[0]) {
                PaymentPlanGoodStandingTest.testSuccess();
            }
        }
    }

    @isTest
    public static void testAddPaymentPlan() {
        User[] users = [SELECT Id FROM User WHERE Username = :CC_USERNAME];

        if (!users.isEmpty()) {
            System.runAs(users[0]) {
                PaymentPlanServiceTest.testAddPaymentPlanForAuto();
            }
        }
    }
}