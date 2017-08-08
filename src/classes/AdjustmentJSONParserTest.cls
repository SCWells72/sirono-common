/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
public with sharing class AdjustmentJSONParserTest {

    private static final String MOCK_RESPONSE_BODY  = '[{' +
                '   "url": "https://toledo.stage.sirono.com/paystaff/api/adjustments/3151479/", ' +
                '   "chargegroup":"https://toledo.stage.sirono.com/paystaff/api/chargegroups/51724/",' +
                '   "amount":100,' +
                '   "code":"ADM",' +
                '   "description":"BC/BS adjustment",' +
                '   "display_kind":"",' +
                '   "post_date":"2016-10-13"' +
                '}]';

    @IsTest
    public static void testJsonParser() {
        AdjustmentJSONParser parser = new AdjustmentJSONParser(MOCK_RESPONSE_BODY);
        AdjustmentJSONParser.AdjustmentWrapper[] wrappers = parser.parse();

        AdjustmentJSONParser.AdjustmentWrapper wrapper = wrappers[0];
        System.assertNotEquals(wrapper, null);

        System.assertEquals(Decimal.valueOf(3151479l), wrapper.sironoId);
        System.assertEquals(Decimal.valueOf(51724l), wrapper.cgSironoId);
        System.assertEquals('BC/BS adjustment', wrapper.adjustment.Description__c);
        System.assertEquals(1.00, wrapper.adjustment.Amount__c);
    }
}