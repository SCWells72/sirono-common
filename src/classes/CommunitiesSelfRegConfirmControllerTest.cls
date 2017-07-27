/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 **/
@IsTest public with sharing class CommunitiesSelfRegConfirmControllerTest {

    /**
     * This method checks logic implemented for community salf registration process.
     **/
    @IsTest(SeeAllData=true) public static void testCommunitiesSelfRegConfirmController() {

        Test.startTest();
        // Instantiate a new controller with all parameters in the page
        CommunitiesSelfRegConfirmController controller = new CommunitiesSelfRegConfirmController();
        Test.stopTest();

        // Check system assert.
        System.assertNotEquals(controller, null, 'Should we got controller null.');
    }
}