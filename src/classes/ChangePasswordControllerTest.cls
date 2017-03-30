/**
 * This class is use to test the logic of ChangePasswordController Class.
 **/

@IsTest public with sharing class ChangePasswordControllerTest {

    /**
     * This method checks logic for Change the Password.
     **/
    @IsTest(SeeAllData=true) public static void testChangePasswordController() {

        Test.startTest();
        ChangePasswordController controller = new ChangePasswordController();    //Delete this line when the below code is uncommented.
        Test.stopTest();

        // Check system assert.
        System.assertNotEquals(controller, null, 'Should we got controller null.');
    }
}