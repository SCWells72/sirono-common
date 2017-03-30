/**
 * This class tests methods implemented in ForgotPasswordController class.
 **/

@IsTest public with sharing class ForgotPasswordControllerTest {

    /**
     * This method checks logic implemented for Forgot Password.
     **/
    @IsTest(SeeAllData=true) public static void testForgotPasswordController() {

        Test.startTest();
        ForgotPasswordController controller = new ForgotPasswordController();
        Test.stopTest();

        // Check system assert, controller should not be null.
        System.assertNotEquals(controller, null, 'Should we got controller null');
    }
}