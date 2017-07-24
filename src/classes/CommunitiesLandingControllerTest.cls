/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 **/
@IsTest public with sharing class CommunitiesLandingControllerTest {

    /**
     * This method tests the logic invoke on page load.
     **/
    @IsTest(SeeAllData=true) public static void testCommunitiesLandingController() {
    
        Test.startTest();
        // Instantiate a new controller with all parameters in the page
        CommunitiesLandingController controller = new CommunitiesLandingController();
        controller.forwardToStartPage();
        Test.stopTest();
        
        // Check system assert.
        System.assertNotEquals(controller, null, 'Should we got controller null.');
    }
}