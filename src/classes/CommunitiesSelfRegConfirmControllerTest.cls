/*
 * @author: Sirono
 * @version 1.0.1
 * @Date: 05-03-2016
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 * 
 * 14/09/2016 commented the code since it is not used into community/site for any business requirement 
*/
@IsTest public with sharing class CommunitiesSelfRegConfirmControllerTest {
    @IsTest(SeeAllData=true) public static void testCommunitiesSelfRegConfirmController() {
        // Instantiate a new controller with all parameters in the page
        CommunitiesSelfRegConfirmController controller = new CommunitiesSelfRegConfirmController();
    }

}