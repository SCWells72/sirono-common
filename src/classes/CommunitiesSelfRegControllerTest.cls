/**
 * An apex page controller that supports self registration of users in communities that allow self registration
 **/
 
@IsTest public with sharing class CommunitiesSelfRegControllerTest {

    /**
     * This method tests the logic of CommunitiesSelfRegController.
     **/
    @IsTest(SeeAllData=true)
    public static void testCommunitiesSelfRegController() {
    
        Test.startTest();
        CommunitiesSelfRegController controller = new CommunitiesSelfRegController();    //Remove this line when the below code is uncommented
        Test.stopTest();
        
        // Check system assert.
        System.assertNotEquals(controller, null, 'Should we got controller null.');
    }

}