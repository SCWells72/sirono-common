/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
public with sharing class PortalUIUtilsTest {

    @IsTest
    public static void getCardDateOptions_test() {

        Test.startTest();
        Map<String, Map<String, String>> dateOptions = PortalUIUtils.getCardDateOptions();
        Test.stopTest();

        Set<String> keys = dateOptions.keySet();
        System.assertEquals(2, keys.size(), 'Should have two keys.');

        System.assert(keys.contains(PortalConstants.MONTHS), 'Should have months.');
        System.assert(keys.contains(PortalConstants.YEARS), 'Should have years.');
        Map<String, String> months = dateOptions.get(PortalConstants.MONTHS);
        Map<String, String> years = dateOptions.get(PortalConstants.YEARS);

        System.assertEquals(11, years.size(), 'Should have 11 years.');
        System.assertEquals(12, months.size(), 'Should have 12 months.');

    }
}