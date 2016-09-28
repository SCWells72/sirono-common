/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 05-03-2016
 * Class containing tests for SiteRegisterController
 * 
 * 14/09/2016 commented the code since it is not used into community/site for any business requirement 
 */
@IsTest public with sharing class SiteRegisterControllerTest {

    @IsTest(SeeAllData=true) static void testRegistration() {
        SiteRegisterController controller = new SiteRegisterController();   //Delete this line when the below code is uncommented.
       /* SiteRegisterController controller = new SiteRegisterController();
        controller.username = 'test@force.com';
        controller.email = 'test@force.com';
        controller.communityNickname = 'test';
        // registerUser will always return null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);    
        
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd123';
        System.assert(controller.registerUser() == null);  
        
    }
*/
    }
}