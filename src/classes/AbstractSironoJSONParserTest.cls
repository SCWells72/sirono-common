/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
public with sharing class AbstractSironoJSONParserTest {
    /**
     * This method tests the logic of Cent to Dollar Conversion
     **/
    @IsTest
    static void testConvertCentsToDollars() {
        Integer inputCents = 150;

        Test.startTest();
        Decimal outputDollars = AbstractSironoJSONParser.convertToDollars(inputCents);
        Test.stopTest();

        // Check system assert.
        System.assertEquals(1.5, outputDollars, 'Expected 1.5, but got ' + outputDollars);
    }

    /**
     * This method tests the logic of convertToDollarsNegative
     **/
    @IsTest
    static void testConvertToDollarsNegative() {
        Integer inputCents = 156;

        Test.startTest();
        Decimal outputDollars = AbstractSironoJSONParser.convertToDollarsNegative(inputCents);
        Test.stopTest();

        // Check system assert.
        System.assertEquals(-1.56, outputDollars, 'Expected -1.56, but got ' + outputDollars);
    }

    public class JSONTestObj {
        //noinspection ApexUnusedDeclaration
        public String tag;
        //noinspection ApexUnusedDeclaration
        public String tag_date;
    }

    @IsTest
    public static void testEnsureJSONList() {
        String json = '{"Tag": "something", "tag_date": "2016-10-07"}';

        String listJson = AbstractSironoJSONParser.ensureJsonList(json);
        List<JSONTestObj> objs = (List<JSONTestObj>) System.JSON.deserialize(listJson, List<JSONTestObj>.class);
        System.assertEquals(1, objs.size(), 'Expected 1 JSONTestObj in the list');
    }
}