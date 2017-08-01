/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
public with sharing class AbstractSironoJSONParserTest {
    /**
     * This method tests the logic of Cent to Dollar Conversion
     **/
    @isTest
    static void testConvertCentsToDollarsRounded() {
        Decimal inputCents = 150;

        Test.startTest();
        Decimal outputDollars = AbstractSironoJSONParser.convertToDollars(inputCents);
        Test.stopTest();

        // Check system assert.
        System.assert('1.5'.equals(outputDollars.format()), 'Expected 1.5, but got ' + outputDollars);
    }

    @isTest
    static void testConvertStringCentsToDollars() {
        Integer inputCents = 150;

        Test.startTest();
        Decimal outputDollars = AbstractSironoJSONParser.convertToDollars(Decimal.valueOf(inputCents.format()));
        Test.stopTest();

        // Check system assert.
        System.assert('1.5'.equals(outputDollars.format()), 'Expected 1.5, but got ' + outputDollars);
    }

    public class JSONTestObj {
        //noinspection ApexUnusedDeclaration
        public String tag;
        //noinspection ApexUnusedDeclaration
        public String tag_date;
    }

    @isTest
    public static void testEnsureJSONList() {
        String json = '{"Tag": "something", "tag_date": "2016-10-07"}';

        String listJson = AbstractSironoJSONParser.ensureJsonList(json);
        List<JSONTestObj> objs = (List<JSONTestObj>) System.JSON.deserialize(listJson, List<JSONTestObj>.class);
        System.assert(objs.size() == 1, 'Expected 1 JSONTestObj in the list');
    }
}