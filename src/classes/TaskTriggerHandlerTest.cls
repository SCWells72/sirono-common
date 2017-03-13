/**
 * @author Sirono
 * @version 1.0.1
 * @date: 05-23-2016
 * @TaskTriggerHandlerTest Test Class for the Code Covrege of TaskTriggerHandler Class.
 * 12-02-2016 Viraj Rana - #133707065: Case to Call Activiy
 * 12-02-2016 Viraj Rana - #132948555: Define Exhausted Effort
 **/

@isTest
private class TaskTriggerHandlerTest {
    
    /**
     * This test method test the Campagin Member removed or not based on Task record.
     * This method also test Call Hour of Day of the Task. When Task is created/updated at that time based on date it's calculate
     *	Hours.
     **/
    @isTest    
    static void testRemoveCampaignMember() {
    	// Create Guarantor Contact Record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

	// Create Campaign Record.
        Campaign campaign = TestUtility.generateCampaign('Pre-collection');
        insert campaign;

	// Create Campaign Member Record.
        CampaignMember campaignMember = TestUtility.generateCampaignMember(campaign.Id, guarantorContact.Id);
        insert campaignMember;
     
     	// Create Tasks Records.
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

        Test.startTest();
        // Check system assert.
        List<CampaignMember> lstCampaignMember = [Select id from CampaignMember];
        System.assertEquals(1, lstCampaignMember.Size());

        insert taskListToInsert;
        // Check system assert.
        lstCampaignMember = [Select id from CampaignMember];
        System.assertEquals(0, lstCampaignMember.Size());
        
        update taskListToInsert[0];
        // Check system assert.
        List<Task> lstTask = [Select Id, Hours_of_Day__c from Task where Id =: taskListToInsert[0].Id];
        System.assertnotEquals(lstTask[0].Hours_of_Day__c, null);
        Test.stopTest();
    }
    
    //12-02-2016 Viraj Rana: #133707065: Case to Call Activiy and #132948555: Define Exhausted Effort
    @isTest
    static void caseCovergaeForAssignCaseId() {
        // Create Guarantor Contact Record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;
        
        // Get Record Type Id. 
        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }
        
        // Create Case Record.
        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Precollections', guarantorContact.Id);
        objCase.Type = 'Precollections'; 
        insert objCase;
        
        // Create Campaign Record.
        Campaign campaign = TestUtility.generateCampaign('PreCollections');
        insert campaign;
        
        // Create Campaign Member Record.
        CampaignMember campaignMember = TestUtility.generateCampaignMember(campaign.Id, guarantorContact.Id);
        campaignMember.Case_ID__c = objCase.Id;
        insert campaignMember;
        
        Test.startTest();
        // Create Task Records.
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
        Test.stopTest();
        
        //Check Case Id assign into Task Object.
        List<Task> lstTask = [Select Id, WhatId from Task where Id =: objTask.Id];
        System.assertEquals(objCase.Id, lstTask[0].WhatId);
    }
    
    /** 12-02-2016 Viraj Rana: #133707065: Case to Call Activiy and #132948555: Define Exhausted Effort
     * This method Test the code with Retry Disposition value.
     * If two or more than two Task contains Retry Disposition Values at that time Case closed with Exhausted.
     **/
    @isTest
    static void caseCovergaeForRetry() {
        // Create Guarantor Contact Record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;
        
        // Get Record Type Id. 
        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }
        
        // Create Case record.
        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Precollections', guarantorContact.Id);
        objCase.Type = 'Precollections'; 
        insert objCase;
        
        // Create Campaign record.
        Campaign campaign = TestUtility.generateCampaign('PreCollections');
        insert campaign;
        
        // Create Campaign Member Record.
        CampaignMember campaignMember = TestUtility.generateCampaignMember(campaign.Id, guarantorContact.Id);
        campaignMember.Case_ID__c = objCase.Id;
        insert campaignMember;
        
        Test.startTest();
        // Get Value for Error Disposition from Custom Meta Data.
        List<Exhausted_Criteria__mdt> lstExhaustedCriteria = 
        	[SELECT MasterLabel, Disposition_Type__c FROM Exhausted_Criteria__mdt WHERE Disposition_Type__c = :TaskTriggerHandler.ERROR_DISPOSITION limit 1];

	// Create Task Record and set CallDisposition value equals to Error Disposition.
	// We assign Error Disposition value here to know This case is closed or not.
        Task objTask = TestUtility.generateTask(guarantorContact.Id, objCase.Id, lstExhaustedCriteria[0].MasterLabel);        
        insert objTask;
        
        // Check System assert. Case is not Closed.
        List<Case> lstCase = [Select Id, Reason, Status from Case where Id =: objCase.Id];
        System.assertNotEquals(lstCase[0].Status, TaskTriggerHandler.CASE_STATUS_CLOSED);
        
        // Get Value for Retry Disposition from Custom Meta Data.
        lstExhaustedCriteria = 
        	[SELECT MasterLabel, Disposition_Type__c FROM Exhausted_Criteria__mdt WHERE Disposition_Type__c = :TaskTriggerHandler.RETRY_DISPOSITION limit 1];
        
        // Create Task Record and set CallDisposition value equals to retry Disposition.
        Task objTask1 = TestUtility.generateTask(guarantorContact.Id, objCase.Id, lstExhaustedCriteria[0].MasterLabel);
        insert objTask1;
        
        // Check System assert. Case is not Closed with Exhausted Reason.
        lstCase = [Select Id, Reason from Case where Id =: objCase.Id];
        System.assertNotEquals(lstCase[0].Reason, TaskTriggerHandler.CASE_REASON_EXHAUSTED);
        
        // Create Task Record and set CallDisposition value equals to retry Disposition.
        // When retry Disposition Count equals to or grether than two at that time this Case is Closed with CASE_REASON_EXHAUSTED Reason.
        Task objTask2 = TestUtility.generateTask(guarantorContact.Id, objCase.Id, lstExhaustedCriteria[0].MasterLabel);
        insert objTask2;
        Test.stopTest();
        
        // Check System assert. Case is Closed with Exhausted Reason.
        lstCase = [Select Id, Reason from Case where Id =: objCase.Id];
        System.assertEquals(lstCase[0].Reason, TaskTriggerHandler.CASE_REASON_EXHAUSTED);
    }
    
    //12-02-2016 Viraj Rana: #133707065: Case to Call Activiy and #132948555: Define Exhausted Effort
    @isTest
    static void caseCovergaeForFinal() {
        // Create Guarantor Contact Record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;
        
        // Get Record Type Id. 
        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }
        
        // Create Case Record. This case is used to create Task with Final Disposition.
        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Precollections', guarantorContact.Id);
        objCase.Type = 'Precollections'; 
        insert objCase;
        
        // Create Campaign record.
        Campaign campaign = TestUtility.generateCampaign('PreCollections');
        insert campaign;
        
        // Create Campaign Member and assign above Case Id into it.
        CampaignMember campaignMember = TestUtility.generateCampaignMember(campaign.Id, guarantorContact.Id);
        campaignMember.Case_ID__c = objCase.Id;
        insert campaignMember;
        
        Test.startTest();
        // Get Value for Retry Disposition from Custom Meta Data.
        List<Exhausted_Criteria__mdt> lstExhaustedCriteria = 
        	[SELECT MasterLabel, Disposition_Type__c FROM Exhausted_Criteria__mdt WHERE Disposition_Type__c = :TaskTriggerHandler.FINAL_DISPOSITION limit 1];
        
        // Create Task record with CallDisposition equals to Final Disposition value.
        // Whenever Task is inserted at that time we check Disposition value, If it is same as final then Case closed with "Case Closed - FINAL" Reason.
        Task objTask = TestUtility.generateTask(guarantorContact.Id, objCase.Id, lstExhaustedCriteria[0].MasterLabel);
        insert objTask;
        Test.stopTest();
        
        // Check System assert.
        List<Case> lstCase = [Select Id, Reason from Case where Id =: objCase.Id];
        System.assertEquals(lstCase[0].Reason, TaskTriggerHandler.CASE_REASON_FINAL);
    }
    
    /** 12-02-2016 Viraj Rana: #133707065: Case to Call Activiy and #132948555: Define Exhausted Effort
     * This method test the code When Task have two Retry Disposition Value and one Final Disposition Value,
     * 	at that time Case should be Closed with Final Reason.  
     **/
    @isTest
    static void retryWithFinalDisposition() {
        // Create Guarantor Contact Record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;
        
        // Get Record Type Id. 
        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }
        
        // Create Case object.
        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Precollections', guarantorContact.Id);
        objCase.Type = 'Precollections'; 
        insert objCase;
        
        // Create Campaign Record.
        Campaign campaign = TestUtility.generateCampaign('PreCollections');
        insert campaign;
        
        // Create Campagin Member Record.
        CampaignMember campaignMember = TestUtility.generateCampaignMember(campaign.Id, guarantorContact.Id);
        campaignMember.Case_ID__c = objCase.Id;
        insert campaignMember;
        
        Test.startTest();
        // Create List of Task.
        List<Task> lstTask = new List<Task>();
        
        // Get Value for Retry Disposition from Custom Meta Data.
        List<Exhausted_Criteria__mdt> lstExhaustedCriteria = 
        	[SELECT MasterLabel, Disposition_Type__c FROM Exhausted_Criteria__mdt WHERE Disposition_Type__c = :TaskTriggerHandler.RETRY_DISPOSITION limit 1];
        
        // Create Task records with CallDisposition equals to retry Dispositions value and add into the List.
        // We need to set Case Id same in all Task Records.
        Task objTask = TestUtility.generateTask(guarantorContact.Id, objCase.Id, lstExhaustedCriteria[0].MasterLabel);
        lstTask.add(objTask);
        
        // We set CallDisposition equals to retry Dispositions value.
        objTask = TestUtility.generateTask(guarantorContact.Id, objCase.Id, lstExhaustedCriteria[0].MasterLabel);
        lstTask.add(objTask);
        
        // Get Value for Final Disposition from Custom Meta Data.
        lstExhaustedCriteria = 
        	[SELECT MasterLabel, Disposition_Type__c FROM Exhausted_Criteria__mdt WHERE Disposition_Type__c = :TaskTriggerHandler.FINAL_DISPOSITION limit 1];
        
        // We set CallDisposition equals to Final Dispositions value.
        // We need to check If Any Task is existing with Final Disposition at that time This Case is Closed with CASE_REASON_FINAL.
        objTask = TestUtility.generateTask(guarantorContact.Id, objCase.Id, lstExhaustedCriteria[0].MasterLabel);
        lstTask.add(objTask);
        
        insert lstTask;
        Test.stopTest();
        
        // Check System assert.
        List<Case> lstCase = [Select Id, Reason from Case where Id =: objCase.Id];
        System.assertEquals(lstCase[0].Reason, TaskTriggerHandler.CASE_REASON_FINAL);
    }
    
    //12-02-2016 Viraj Rana: #133707065: Case to Call Activiy and #132948555: Define Exhausted Effort
    @isTest
    static void caseCovergaeForError() {
        // Create Guarantor Contact Record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;
        
        // Get Record Type Id. 
        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }
        
        // Create Case object.
        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Precollections', guarantorContact.Id);
        objCase.Type = 'Precollections'; 
        insert objCase;
        
        // Create Campaign Record.
        Campaign campaign = TestUtility.generateCampaign('PreCollections');
        insert campaign;
        
        // Create Campagin Member Record.
        CampaignMember campaignMember = TestUtility.generateCampaignMember(campaign.Id, guarantorContact.Id);
        campaignMember.Case_ID__c = objCase.Id;
        insert campaignMember;
        
        Test.startTest();
        List<Task> lstTask = new List<Task>();
        
        // Get Value for Error Disposition from Custom Meta Data.
        List<Exhausted_Criteria__mdt> lstExhaustedCriteria = 
        	[SELECT MasterLabel, Disposition_Type__c FROM Exhausted_Criteria__mdt WHERE Disposition_Type__c = :TaskTriggerHandler.ERROR_DISPOSITION limit 1]; 
        
        /** Create Task records with CallDisposition equals to Error Dispositions value and add into the List.
         * We need to set Case Id same in all Task Records.
         * When Error Disposition Count equals to or grether than five at that time this Case is Closed with CASE_REASON_EXHAUSTED Reason.
         **/
        Task objTask = TestUtility.generateTask(guarantorContact.Id, objCase.Id, lstExhaustedCriteria[0].MasterLabel);
        lstTask.add(objTask);
                
        objTask = TestUtility.generateTask(guarantorContact.Id, objCase.Id, lstExhaustedCriteria[0].MasterLabel);
        lstTask.add(objTask);
        
        objTask = TestUtility.generateTask(guarantorContact.Id, objCase.Id, lstExhaustedCriteria[0].MasterLabel);
        lstTask.add(objTask);
        
        objTask = TestUtility.generateTask(guarantorContact.Id, objCase.Id, lstExhaustedCriteria[0].MasterLabel);
        lstTask.add(objTask);
        
        objTask = TestUtility.generateTask(guarantorContact.Id, objCase.Id, lstExhaustedCriteria[0].MasterLabel);
        lstTask.add(objTask);
        
        insert lstTask;
        Test.stopTest();
        
        // Check System assert.
        List<Case> lstCase = [Select Id, Reason, Status from Case where Id =: objCase.Id];
        System.assertEquals(lstCase[0].Status, TaskTriggerHandler.CASE_STATUS_CLOSED);
    }
    
    /**
     * Check all access rights for a read only User using runAs.
     **/
    @isTest
    static void checkAccessRights() {
        List<CaseSecurityContext> allContexts = new List<CaseSecurityContext>{CaseSecurityContext.CREATE_CONTEXT,
        	CaseSecurityContext.CREATE_WITH_GT_CONTEXT, CaseSecurityContext.CU_CREATE_WITH_ENCOUNTER_CONTEXT, 
                CaseSecurityContext.UPDATE_CONTEXT, CaseSecurityContext.UPSERT_CONTEXT, CaseSecurityContext.DELETE_CONTEXT
        };

        System.runAs(TestUtility.generateReadOnlyUser()) {
            for (CaseSecurityContext context: allContexts) {
                try {
                    context.actionAllowed();
                    System.assert(false, 'Expected permission to be denied for ' + context);
                } catch (SecurityUtils.SecurityException ex) {
                    System.debug('SecurityException : ' + ex);
                } catch (Exception e) {
                    System.assert(false, 'Expected SecurityUtils.SecurityException to be thrown, but got ' + e);
                }
            }
        }
    }
}