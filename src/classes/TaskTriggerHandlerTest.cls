/*
 * @author Sirono
 * @version 1.0.1
 * @date: 05-23-2016
 * @TaskTriggerHandlerTest Test Class for the Code Covrege of TaskTriggerHandler Class.
 * 12-02-2016 Viraj Rana - #133707065: Case to Call Activiy
 */

@isTest
private class TaskTriggerHandlerTest {

    static testMethod void myUnitTest() {
        TestUtility objTestUtility = new TestUtility();

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

        update taskListToInsert;
    }
    
    //12-02-2016 Viraj Rana: #133707065: Case to Call Activiy and #132948555: Define Exhausted Effort
    static testMethod void CaseCovergaeForAssignCaseId() {
        TestUtility objTestUtility = new TestUtility();
                
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;
        
        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }
        
        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Precollections', guarantorContact.Id);
        objCase.Type = 'Precollections'; 
        insert objCase;
        
        Campaign campaign = TestUtility.generateCampaign('PreCollections');
        insert campaign;
        
        CampaignMember campaignMember = TestUtility.generateCampaignMember(campaign.Id, guarantorContact.Id);
        campaignMember.Case_ID__c = objCase.Id;
        insert campaignMember;
        
        Task objTask = TestUtility.generateTask(guarantorContact.Id);
        objTask.WhoId = guarantorContact.Id;
        objTask.Five9__Five9Campaign__c = 'OB PreCollections';
        objTask.CallDisposition = 'Dial Error';
        insert objTask;
        
        Task objTask1 = TestUtility.generateTask(guarantorContact.Id);
        objTask1.WhoId = guarantorContact.Id;
        objTask1.Five9__Five9Campaign__c = 'IB Precollections';
        objTask1.CallDisposition = 'Successful Call';
        insert objTask1;
    }
}