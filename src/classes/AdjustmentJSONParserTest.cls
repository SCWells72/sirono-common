/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
public with sharing class AdjustmentJSONParserTest {

    @IsTest
    public static void testJsonParser() {
        AdjustmentJSONParser parser = new AdjustmentJSONParser(AdjustmentJSONParser.testResponse());
        AdjustmentJSONParser.AdjustmentWrapper[] wrappers = parser.parse();

        AdjustmentJSONParser.AdjustmentWrapper wrapper = wrappers[0];
        System.assertNotEquals(wrapper, null);

        System.assertEquals(Decimal.valueOf(3151479l), wrapper.sironoId);
        System.assertEquals(Decimal.valueOf(51724l), wrapper.cgSironoId);
        System.assertEquals('BC/BS adjustment', wrapper.adjustment.Description__c);
        System.assertEquals(1.00, wrapper.adjustment.Amount__c);
    }
}