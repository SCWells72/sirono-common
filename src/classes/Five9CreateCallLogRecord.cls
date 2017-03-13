/*
* @author Sirono
* @version 1.0.1
* @Date: 06-14-2016
*/
public with sharing class Five9CreateCallLogRecord {

    public String five9ANI {get; set;}
    public String five9DNIS {get; set;}
    public String salesforceId {get; set;}
    public String callDisposition {get; set;}
    public String five9SessionId {get; set;}
    public String endTimestamp {get; set;}
    public String callTypeName {get; set;}
    public String campaignName {get; set;}
    public String startTimestamp {get; set;}
    public String fullName {get; set;}

    //constructor initializing member variables
    public Five9CreateCallLogRecord() {
        five9ANI = null;
        five9DNIS = null;
        salesforceId = null;
        callDisposition = null;
        five9SessionId = null;
        endTimestamp = null;
        callTypeName = null;
        campaignName = null;
        startTimestamp = null;
        fullName = null;

        if (Apexpages.currentPage().getParameters().containsKey('Five9_ANI')) {
            five9ANI = Apexpages.currentPage().getParameters().get('Five9_ANI');
        }
        if (Apexpages.currentPage().getParameters().containsKey('Five9_DNIS')) {
            five9DNIS = Apexpages.currentPage().getParameters().get('Five9_DNIS');
        }
        if (Apexpages.currentPage().getParameters().containsKey('Salesforce_Id')) {
            salesforceId = Apexpages.currentPage().getParameters().get('Salesforce_Id');
        }
        if (Apexpages.currentPage().getParameters().containsKey('Call_disposition')) {
            callDisposition = Apexpages.currentPage().getParameters().get('Call_disposition');
        }
        if (Apexpages.currentPage().getParameters().containsKey('session_id')) {
            five9SessionId = Apexpages.currentPage().getParameters().get('session_id');
        }
        if (Apexpages.currentPage().getParameters().containsKey('endTimestamp')) {
            endTimestamp = Apexpages.currentPage().getParameters().get('endTimestamp');
        }
        if (Apexpages.currentPage().getParameters().containsKey('callTypeName')) {
            callTypeName = Apexpages.currentPage().getParameters().get('callTypeName');
        }
        if (Apexpages.currentPage().getParameters().containsKey('campaignName')) {
            campaignName = Apexpages.currentPage().getParameters().get('campaignName');
        }
        if (Apexpages.currentPage().getParameters().containsKey('startTimestamp')) {
            startTimestamp = Apexpages.currentPage().getParameters().get('startTimestamp');
        }
        if (Apexpages.currentPage().getParameters().containsKey('fullName')) {
            fullName = Apexpages.currentPage().getParameters().get('fullName');
        }
    }

    //Controller Method that creates a task 
    public PageReference doAction() {
        try {
            System.debug('======================= salesforceId: ' + salesforceId);
            System.debug('======================= callDisposition: ' + callDisposition);
            System.debug('======================= five9ANI: ' + five9ANI);
            if (salesforceId != null && callDisposition != null && five9ANI != null) {
                if (salesforceId.startsWith('003')) {
                    Task t = new Task();
                    t.Five9__Five9ANI__c = five9ANI;
                    t.Five9__Five9DNIS__c = five9DNIS;
                    t.whoId = salesforceId;
                    t.CallDisposition = callDisposition;
                    t.Five9__Five9SessionId__c = five9SessionId;
                    //t.Call_End_Time__c = endTimestamp;
                    t.Five9__Five9CallType__c = callTypeName;
                    t.Five9__Five9Campaign__c = campaignName;
                    //t.Call_Start_Time__c = startTimestamp;
                    t.Five9__Five9AgentName__c = fullName;
                    t.ActivityDate = Date.today();
                    t.status = 'Completed';
                    if (TaskSecurityContext.CREATE_CONTEXT.actionAllowed()) {
                        INSERT t;
                        System.debug('======================= t: ' + t);    
                    }
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Salesforce Id must be of Contact Type'));
                    if (Test.IsRunningTest()) {
                        TestUtility.generateException();
                    }
                }
            }
        } catch (Exception e) {
            System.debug('======================= getMessage: ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, e.getMessage()));
        }
        return null;
    }
}