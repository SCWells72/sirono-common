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