/* 
 * @author Sirono
 * @version 1.0.1
 * @Date: 05-03-2016
 * An apex page controller that exposes the site forgot password functionality
 * 
 * 14/09/2016 commented the code since it is not used into community/site for any business requirement 
 */
@IsTest public with sharing class ForgotPasswordControllerTest {

    @IsTest(SeeAllData=true) public static void testForgotPasswordController() {

        ForgotPasswordController controller = new ForgotPasswordController();    //Delete this line when the below code is uncommented.
        /* Instantiate a new controller with all parameters in the page
    	ForgotPasswordController controller = new ForgotPasswordController();
    	controller.username = 'test@gmail.com';     	
    
    	System.assertEquals(null,controller.forgotPassword()); 
		*/
    }

}