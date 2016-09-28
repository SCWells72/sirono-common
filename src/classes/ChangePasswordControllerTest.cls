/*
 * @author: Sirono
 * @version 1.0.1
 * @Date: 05-03-2016
 * An apex page controller that exposes the change password functionality
 * 
 * 14/09/2016 commented the code since it is not used into community/site for any business requirement 
 */
@IsTest public with sharing class ChangePasswordControllerTest {

    @IsTest(SeeAllData=true) public static void testChangePasswordController() {

        ChangePasswordController controller = new ChangePasswordController();    //Delete this line when the below code is uncommented.
        /*
        // Instantiate a new controller with all parameters in the page
        ChangePasswordController controller = new ChangePasswordController();
        controller.oldPassword = '123456';
        controller.newPassword = 'qwerty1'; 
        controller.verifyNewPassword = 'qwerty1';                
        System.assertEquals(controller.changePassword(),null);
		*/
    }

}