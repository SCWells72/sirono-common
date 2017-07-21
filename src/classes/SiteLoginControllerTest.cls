/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * An apex page controller that exposes the site login functionality
 */
@IsTest global with sharing class SiteLoginControllerTest {

    @IsTest(SeeAllData=true) 
    global static void testSiteLoginController() {
        SiteLoginController controller = new SiteLoginController();    //Delete this line when the below code is uncommented.
        controller.username = 'test';
        controller.password = 'test';

        System.assertEquals(controller.login(), null);
        /* Instantiate a new controller with all parameters in the page
        SiteLoginController controller = new SiteLoginController ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 

        System.assertEquals(controller.login(),null); 
        */
    }

}