/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Test that constructed constants are valid
 */
@IsTest
public with sharing class PortalUIConstantsTest {

    @IsTest
    public static void expYearsTest() {
        Map<String, String> yearMap = PortalUIConstants.getYears();
        System.assert(yearMap.size() == 11, 'Wrong number of years; expected 11, but got ' + yearMap.size());
        System.assert(yearMap.containsKey(String.valueOf(System.today().year())), 'This year not in list');

        System.assert(yearMap.containsKey(String.valueOf(System.today().addYears(10).year())),
            'Year range: ' + String.join(new List<String>(yearMap.keySet()), ', ') + ' is invalid');
        System.assert(!yearMap.containsKey(String.valueOf(System.today().addYears(-1).year())),
            'Year range: ' + String.join(new List<String>(yearMap.keySet()), ', ') + ' is invalid');
    }

    @IsTest
    public static void expMonthsTest() {
        Map<String, String> monthMap = PortalUIConstants.getExpMonths();
        System.assert(monthMap.size() == 12, 'Wrong number of months; expected 12, but got ' + monthMap.size());
    }


    @IsTest
    public static void statesTest() {
        List<String> states = PortalUIConstants.getStates();
        System.assert(states.size() == 50, 'Wrong number of states; expected 50, but got ' + states.size());
    }
}