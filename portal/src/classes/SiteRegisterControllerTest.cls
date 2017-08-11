/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This class tests methods implemented in SiteRegisterController class.
 **/
@IsTest public with sharing class SiteRegisterControllerTest {

    /**
     * This method checks logic for Registration process.
     **/
    @IsTest(SeeAllData=true) static void testRegistration() {

        Test.startTest();
        SiteRegisterController controller = new SiteRegisterController();
        Test.stopTest();

        // Check system assert, controller should not be null.
        System.assertNotEquals(controller, null, 'Should we got controller null');
    }
}
