/**
 * This class tests methods implemented in MyProfilePageController class.
 **/

@IsTest public with sharing class MyProfilePageControllerTest {

    /**
     * This method checks logic for save profile.
     **/
    @IsTest(SeeAllData=true) static void testSave() {
        Test.startTest();
        MyProfilePageController controller = new MyProfilePageController();
        Test.stopTest();

        // Check system assert, controller should not be null.
        System.assertNotEquals(controller, null, 'We should get controller null');
    }
}
