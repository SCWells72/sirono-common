public without sharing class Five9CreateCallLogRecord {

    public String five9ANI {get; set;}
    public String five9DNIS {get; set;}
    public String salesforceId {get; set;}
    public String callDisposition {get; set;}
    public String five9Session_id {get; set;}
    public String end_timestamp {get; set;}
    public String call_type_name {get; set;}
    public String campaign_name {get; set;}
    public String start_timestamp {get; set;}
    public String full_name {get; set;}

    public Five9CreateCallLogRecord() {
        five9ANI = null;
        five9DNIS = null;
        salesforceId = null;
        callDisposition = null;
        five9Session_id = null;
        end_timestamp = null;
        call_type_name = null;
        campaign_name = null;
        start_timestamp = null;
        full_name = null;

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
            five9Session_id = Apexpages.currentPage().getParameters().get('session_id');
        }
        if (Apexpages.currentPage().getParameters().containsKey('end_timestamp')) {
            end_timestamp = Apexpages.currentPage().getParameters().get('end_timestamp');
        }
        if (Apexpages.currentPage().getParameters().containsKey('call_type_name')) {
            call_type_name = Apexpages.currentPage().getParameters().get('call_type_name');
        }
        if (Apexpages.currentPage().getParameters().containsKey('campaign_name')) {
            campaign_name = Apexpages.currentPage().getParameters().get('campaign_name');
        }
        if (Apexpages.currentPage().getParameters().containsKey('start_timestamp')) {
            start_timestamp = Apexpages.currentPage().getParameters().get('start_timestamp');
        }
        if (Apexpages.currentPage().getParameters().containsKey('full_name')) {
            full_name = Apexpages.currentPage().getParameters().get('full_name');
        }
    }

    public Pagereference doAction() {
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
                    t.Five9__Five9SessionId__c = five9Session_id;
                    //t.Call_End_Time__c = end_timestamp;
                    t.Five9__Five9CallType__c = call_type_name;
                    t.Five9__Five9Campaign__c = campaign_name;
                    //t.Call_Start_Time__c = start_timestamp;
                    t.Five9__Five9AgentName__c = full_name;
                    t.ActivityDate = Date.today();
                    t.status = 'Completed';
                    insert t;
                    System.debug('======================= t: ' + t);
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Salesforce Id must be of Contact Type'));
                }
            }
        } catch (Exception e) {
            System.debug('======================= getMessage: ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, e.getMessage()));
        }
        return null;
    }
}