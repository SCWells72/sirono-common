/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
public with sharing class PaymentPlanInformationTest {

    @IsTest
    public static void testEmptyMap() {
        Map<String, Object> emptyMap = new Map<String, Object>();

        Test.startTest();
        PaymentPlanInformation emptyInfo = new PaymentPlanInformation(emptyMap);
        Test.stopTest();

        System.assertNotEquals(null, emptyInfo);
        System.assert(String.isEmpty(emptyInfo.amount), 'Should be empty String for all properties');
        System.assertEquals(0, emptyInfo.chargeGroupIds.size(), 'Should have no charge group ids.');
    }

    @IsTest
    public static void testPopulatedMap() {
        Map<String, Object> populatedMap = new Map<String, Object> {
            PaymentPlanInformation.PLAN_TYPE => Constants.PLANTYPE_AUTO,
            PaymentPlanInformation.PLAN_VALUE => null,
            PaymentPlanInformation.AMOUNT_KEY => '12345',
            PaymentPlanInformation.EXECUTE_ON_DAY => 1,
            PaymentPlanInformation.GUARANTOR_ID => 'abc123wxyz',
            PaymentPlanInformation.CARD_HOLDER_NAME => 'Ima Cardholder',
            PaymentPlanInformation.EXPIRATION_YEAR => 2018,
            PaymentPlanInformation.EXPIRATION_MONTH => 3,
            PaymentPlanInformation.CREDITCARD_NUMBER => '4111111111111111',
            PaymentPlanInformation.CVV_KEY => '123',
            PaymentPlanInformation.STATE_KEY => 'TX',
            PaymentPlanInformation.ZIP_KEY => '78717',
            PaymentPlanInformation.ADDRESS_KEY => '123 St. Road',
            PaymentPlanInformation.CITY_KEY => 'Waco'
        };

        Test.startTest();
        PaymentPlanInformation populatedInfo = new PaymentPlanInformation(populatedMap);
        Test.stopTest();

        System.assertNotEquals(null, populatedInfo, 'Should have an info object.');
        System.assertEquals(populatedInfo.planType, Constants.PLANTYPE_AUTO, 'Should populate plantype.');
        System.assertEquals(populatedInfo.planValue, '', 'Should set empty string for null value.');
        System.assertEquals('2018', populatedInfo.expirationYear, 'Should convert to String.');
        System.assertEquals('3', populatedInfo.expirationMonth, 'Should convert to String.');
        System.assertEquals(0, populatedInfo.chargeGroupIds.size(), 'Should have no charge group ids.');
    }

    @IsTest
    public static void testSingleChargeGroupId() {
        String oneChangeGroup = '123';
        Map<String, Object> cgMap = new Map<String, Object> {
            PaymentPlanInformation.CHARGE_GROUP_IDS => oneChangeGroup
        };

        Test.startTest();
        PaymentPlanInformation cgInfo = new PaymentPlanInformation(cgMap);
        Test.stopTest();

        System.assertNotEquals(null, cgInfo, 'Should create an PPI object.');
        System.assertEquals(1, cgInfo.chargeGroupIds.size(), 'Should have a single CG in list.');
        System.assertEquals(oneChangeGroup, cgInfo.chargeGroupIds.get(0), 'Should equal cg value.');
    }

    @IsTest
    public static void testMultipleChargeGroupId() {
        String manyCGs = '123,456,83ag,1038';
        Map<String, Object> cgMap = new Map<String, Object> {
            PaymentPlanInformation.CHARGE_GROUP_IDS => manyCGs
        };

        Test.startTest();
        PaymentPlanInformation cgInfo = new PaymentPlanInformation(cgMap);
        Test.stopTest();

        System.assertNotEquals(null, cgInfo, 'Should create an PPI object.');
        System.assertEquals(4, cgInfo.chargeGroupIds.size(), 'Should have a single CG in list.');
        System.assertEquals('123', cgInfo.chargeGroupIds.get(0), 'Should equal first cg value.');
        System.assertEquals('1038', cgInfo.chargeGroupIds.get(3), 'Should equal last cg value.');
    }


}