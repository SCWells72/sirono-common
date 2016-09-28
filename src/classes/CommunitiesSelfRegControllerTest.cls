/* 
 * @author: Sirono
 * @version 1.0.1
 * @Date: 05-03-2016
 * An apex page controller that supports self registration of users in communities that allow self registration
 * 
 * 14/09/2016 commented the code since it is not used into community/site for any business requirement
 */
@IsTest public with sharing class CommunitiesSelfRegControllerTest {
    @IsTest(SeeAllData=true)
    public static void testCommunitiesSelfRegController() {
        CommunitiesSelfRegController controller = new CommunitiesSelfRegController();    //Remove this line when the below code is uncommented
        
        /* CommunitiesSelfRegController controller = new CommunitiesSelfRegController();
        controller.firstName = 'FirstName';
        controller.lastName = 'LastName';
        controller.email = 'test@force.com';
        controller.communityNickname = 'test';
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd1234';
        // registerUser will always return null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);    
        
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd123';
        apexpages.currentPage().getParameters().put('startURL','www.google.com');
        System.assert(controller.registerUser() == null);  
       */
    }

}