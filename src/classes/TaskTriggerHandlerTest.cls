/*
 * @author Sirono
 * @version 1.0.1
 * @date: 05-23-2016
 * @TaskTriggerHandlerTest Test Class for the Code Covrege of TaskTriggerHandler Class.
 * 12-02-2016 Viraj Rana - #133707065: Case to Call Activiy
 * 12-02-2016 Viraj Rana - #132948555: Define Exhausted Effort
 */

@isTest
private class TaskTriggerHandlerTest {
    
    @isTest
    static void myUnitTest() {
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
    @isTest
    static void CaseCovergaeForAssignCaseId() {
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
        
        //Check Case Id assign into Task Object.
        List<Task> lstTask = [Select Id, WhatId from Task where Id =: objTask.Id];
        System.assertEquals(objCase.Id, lstTask[0].WhatId);
    }
    
    //12-02-2016 Viraj Rana: #133707065: Case to Call Activiy and #132948555: Define Exhausted Effort
    @isTest
    static void CaseCovergaeForRetry() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;
        
        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }
        
        //Create Case record.
        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Precollections', guarantorContact.Id);
        objCase.Type = 'Precollections'; 
        insert objCase;
        
        //Create Campaign record.
        Campaign campaign = TestUtility.generateCampaign('PreCollections');
        insert campaign;
        
        //Create Campaign Member Record.
        CampaignMember campaignMember = TestUtility.generateCampaignMember(campaign.Id, guarantorContact.Id);
        campaignMember.Case_ID__c = objCase.Id;
        insert campaignMember;

	//Create Task Record and set CallDisposition value equals to Error Disposition.
	//We assign Error Disposition value here to know This case is closed or not.
        Task objTask = TestUtility.generateTask(guarantorContact.Id);
        objTask.WhoId = guarantorContact.Id;
        objTask.CallDisposition = 'Busy';
        objTask.WhatId = objCase.Id;
        insert objTask;
        
        //Create Task Record and set CallDisposition value equals to retry Disposition.
        Task objTask1 = TestUtility.generateTask(guarantorContact.Id);
        objTask1.WhoId = guarantorContact.Id;
        objTask1.CallDisposition = 'Abandon';
        objTask1.WhatId = objCase.Id;
        insert objTask1;
        
        //Create Task Record and set CallDisposition value equals to retry Disposition.
        //When retry Disposition Count equals to or grether than two at that time this Case is Closed with CASE_REASON_EXHAUSTED Reason.
        Task objTask2 = TestUtility.generateTask(guarantorContact.Id);
        objTask2.WhoId = guarantorContact.Id;
        objTask2.CallDisposition = 'Agent Error';
        objTask2.WhatId = objCase.Id;
        insert objTask2;
        
        //Check System assert.
        List<Case> lstCase = [Select Id, Reason from Case where Id =: objCase.Id];
        System.assertEquals(lstCase[0].Reason, TaskTriggerHandler.CASE_REASON_EXHAUSTED);
    }
    
    //12-02-2016 Viraj Rana: #133707065: Case to Call Activiy and #132948555: Define Exhausted Effort
    @isTest
    static void CaseCovergaeForFinal() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;
        
        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }
        
        //Create Case Record. This case is used to create Task with Final Disposition.
        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Precollections', guarantorContact.Id);
        objCase.Type = 'Precollections'; 
        insert objCase;
        
        //Create Campaign record.
        Campaign campaign = TestUtility.generateCampaign('PreCollections');
        insert campaign;
        
        //Create Campaign Member and assign above Case Id into it.
        CampaignMember campaignMember = TestUtility.generateCampaignMember(campaign.Id, guarantorContact.Id);
        campaignMember.Case_ID__c = objCase.Id;
        insert campaignMember;
        
        //Create Task record with CallDisposition equals to Final Disposition value.
        //Whenever Task is inserted at that time we check Disposition value, If it is same as final then Case closed with "Case Closed - FINAL" Reason.
        Task objTask = TestUtility.generateTask(guarantorContact.Id);
        objTask.WhoId = guarantorContact.Id;
        objTask.CallDisposition = 'Wrong Number';
        objTask.WhatId = objCase.Id;
        insert objTask;
        
        //Check System assert.
        List<Case> lstCase = [Select Id, Reason from Case where Id =: objCase.Id];
        System.assertEquals(lstCase[0].Reason, TaskTriggerHandler.CASE_REASON_FINAL);
    }
    
    //12-02-2016 Viraj Rana: #133707065: Case to Call Activiy and #132948555: Define Exhausted Effort
    @isTest
    static void CaseCovergaeForRemoveCaseInSet() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;
        
        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }
        
        //Create Case object.
        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Precollections', guarantorContact.Id);
        objCase.Type = 'Precollections'; 
        insert objCase;
        
        //Create Campaign Record.
        Campaign campaign = TestUtility.generateCampaign('PreCollections');
        insert campaign;
        
        //Create Campagin Member Record.
        CampaignMember campaignMember = TestUtility.generateCampaignMember(campaign.Id, guarantorContact.Id);
        campaignMember.Case_ID__c = objCase.Id;
        insert campaignMember;
        
        //Create List of Task.
        List<Task> lstTask = new List<Task>();
        
        //Create Task records with CallDisposition equals to retry Dispositions value and add into the List.
        //We need to set Case Id same in all Task Records.
        Task objTask = TestUtility.generateTask(guarantorContact.Id);
        objTask.WhoId = guarantorContact.Id;
        objTask.CallDisposition = 'Abandon';
        objTask.WhatId = objCase.Id;
        lstTask.add(objTask);
        
        //We set CallDisposition equals to retry Dispositions value.
        objTask = TestUtility.generateTask(guarantorContact.Id);
        objTask.WhoId = guarantorContact.Id;
        objTask.CallDisposition = 'Answering Machine';
        objTask.WhatId = objCase.Id;
        lstTask.add(objTask);
        
        //We set CallDisposition equals to Final Dispositions value.
        //We need to check If Any Task is existing with Final Disposition at that time This Case is Closed with CASE_REASON_FINAL.
        objTask = TestUtility.generateTask(guarantorContact.Id);
        objTask.WhoId = guarantorContact.Id;
        objTask.CallDisposition = 'Wrong Number';
        objTask.WhatId = objCase.Id;
        lstTask.add(objTask);
        
        insert lstTask;
        
        //Check System assert.
        List<Case> lstCase = [Select Id, Reason from Case where Id =: objCase.Id];
        System.assertEquals(lstCase[0].Reason, TaskTriggerHandler.CASE_REASON_FINAL);
    }
    
    //12-02-2016 Viraj Rana: #133707065: Case to Call Activiy and #132948555: Define Exhausted Effort
    @isTest
    static void CaseCovergaeForError() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;
        
        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }
        
        //Create Case object.
        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Precollections', guarantorContact.Id);
        objCase.Type = 'Precollections'; 
        insert objCase;
        
        //Create Campaign Record.
        Campaign campaign = TestUtility.generateCampaign('PreCollections');
        insert campaign;
        
        //Create Campagin Member Record.
        CampaignMember campaignMember = TestUtility.generateCampaignMember(campaign.Id, guarantorContact.Id);
        campaignMember.Case_ID__c = objCase.Id;
        insert campaignMember;
        
        List<Task> lstTask = new List<Task>();
        
        //Create Task records with CallDisposition equals to Error Dispositions value and add into the List.
        //We need to set Case Id same in all Task Records.
        //When Error Disposition Count equals to or grether than five at that time this Case is Closed with CASE_REASON_EXHAUSTED Reason.
        Task objTask = TestUtility.generateTask(guarantorContact.Id);
        objTask.WhoId = guarantorContact.Id;
        objTask.CallDisposition = 'Busy';
        objTask.WhatId = objCase.Id;
        lstTask.add(objTask);
                
        objTask = TestUtility.generateTask(guarantorContact.Id);
        objTask.WhoId = guarantorContact.Id;
        objTask.CallDisposition = 'Fax';
        objTask.WhatId = objCase.Id;
        lstTask.add(objTask);
        
        objTask = TestUtility.generateTask(guarantorContact.Id);
        objTask.WhoId = guarantorContact.Id;
        objTask.CallDisposition = 'Line Busy';
        objTask.WhatId = objCase.Id;
        lstTask.add(objTask);
        
        objTask = TestUtility.generateTask(guarantorContact.Id);
        objTask.WhoId = guarantorContact.Id;
        objTask.CallDisposition = 'Busy';
        objTask.WhatId = objCase.Id;
        lstTask.add(objTask);
        
        objTask = TestUtility.generateTask(guarantorContact.Id);
        objTask.WhoId = guarantorContact.Id;
        objTask.CallDisposition = 'No Answer';
        objTask.WhatId = objCase.Id;
        lstTask.add(objTask);
        
        insert lstTask;
        
        //Check System assert.
        List<Case> lstCase = [Select Id, Reason, Status from Case where Id =: objCase.Id];
        System.assertEquals(lstCase[0].Status, TaskTriggerHandler.CASE_STATUS_CLOSED);
    }
}