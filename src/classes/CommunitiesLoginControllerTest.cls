/*
 * @author: Sirono
 * @version 1.0.1
 * @Date: 05-03-2016
 * An apex page controller that exposes the site login functionality
*/
@IsTest global with sharing class CommunitiesLoginControllerTest {

    @IsTest(SeeAllData=true)
    global static void testCommunitiesLoginController() {
        CommunitiesLoginController controller = new CommunitiesLoginController();
        System.assertEquals(null, controller.forwardToAuthPage());
    }

}