/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
private class CardInformationTest {

    @IsTest
    public static void testAmountAbove() {
        String ccJsonString = '{"amount":292.0000000000001}';
        String expected = '292.00';

        Test.startTest();
        CardInformation cInfo = (CardInformation) JSON.deserialize(ccJsonString, CardInformation.class);
        Test.stopTest();

        System.assertEquals(expected, cInfo.amount, 'Should round down to .00 cents.');
    }

    @IsTest
    public static void testAmountBelow() {
        String ccJsonString = '{"amount":97.9999999999999}';
        String expected = '98.00';

        Test.startTest();
        CardInformation cInfo = (CardInformation) JSON.deserialize(ccJsonString, CardInformation.class);
        Test.stopTest();

        System.assertEquals(expected, cInfo.amount, 'Should round up to .00 cents.');
    }
}