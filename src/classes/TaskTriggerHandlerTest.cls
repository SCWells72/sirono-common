/*
 * @author Sirono
 * @version 1.0.1
 * @date: 05-23-2016
 * @TaskTriggerHandlerTest Test Class for the Code Covrege of TaskTriggerHandler Class.
 */

@isTest
private class TaskTriggerHandlerTest {

    static testMethod void myUnitTest() {
         TaskTriggerHandler obj = new TaskTriggerHandler();
		/*TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Campaign campaign = TestUtility.generateCampaign('Pre-collection');
        insert campaign;

        CampaignMember campaignMember = TestUtility.generateCampaignMember(campaign.Id, guarantorContact.Id);
        insert campaignMember;
     
        List<Task> taskListToInsert = new List<Task>();
        Task objTask = TestUtility.generateTask(guarantorContact.Id);
        objTask.CallDisposition = 'Final';
        taskListToInsert.add(objTask);

        objTask = TestUtility.generateTask(guarantorContact.Id);
        objTask.CallDisposition = 'Retry';
        taskListToInsert.add(objTask);

        objTask = TestUtility.generateTask(guarantorContact.Id);
        objTask.CallDisposition = 'Error';
        taskListToInsert.add(objTask);

        List<CampaignMember> lstCampaignMember = [Select id from CampaignMember];
        System.assertEquals(1, lstCampaignMember.Size());

        insert taskListToInsert;
        lstCampaignMember = [Select id from CampaignMember];
        System.assertEquals(0, lstCampaignMember.Size());

        update taskListToInsert;*/
    }
}