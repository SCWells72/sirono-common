/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 05-03-2016
 * An apex page controller that exposes the site login functionality
 * 
 * 14/09/2016 commented the code since it is not used into community/site for any business requirement 
 */
@IsTest global with sharing class SiteLoginControllerTest {

    @IsTest(SeeAllData=true) 
    global static void testSiteLoginController() {
        SiteLoginController controller = new SiteLoginController();    //Delete this line when the below code is uncommented.
        controller.username = 'test';
        controller.password = 'test';
        /* Instantiate a new controller with all parameters in the page
        SiteLoginController controller = new SiteLoginController ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 
                
        System.assertEquals(controller.login(),null); 
        */
    }

}