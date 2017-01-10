/*
* @author Sirono
* @version 1.0.1
* @Date: 06-06-2016
* @Handler class for TaskTrigger.
* #130111863 Viraj Rana 09-29-2016: update the Hours_of_Day__c  field based on the timezone defined in the custom meta data. 
*
* 11-28-2016 Viraj Rana: #133707065: Case to Call Activiy
* 
* 12-02-2016 Viraj Rana: #132948555: Define Exhausted Effort
*/

public with sharing class TaskTriggerHandler {

    public static boolean isRecursive = false;
    
    public static final String CASEPREFIX = '500';
    public static final String CONTACTPREFIX = '003';    
    public static final String IB = 'IB';
    public static final String OB = 'OB';
    
    //#132948555: Define Exhausted Effort Constants.
    public static final String CASE_REASON_EXHAUSTED = 'Case Closed - Exhausted';
    public static final String CASE_REASON_FINAL = 'Case Closed - FINAL';
    public static final String CASE_STATUS_CLOSED = 'Closed';
    // We can't make only ERROR, FINAL or RETRY, because of we can't take FINAL only so make consistency we put DISPOSITION for all.
    public static final String ERROR_DISPOSITION = 'Error';
    public static final String FINAL_DISPOSITION = 'Final';
    public static final String RETRY_DISPOSITION = 'Retry';
    public static final Integer MAX_RETRY_COUNT = 2;
    public static final Integer MAX_ERROR_COUNT = 5;

    // Call removeFromCallList method when the task is inserted
    public static void afterInsert(List<Task> newList) {
        // Call closeCasesWithExhaustedCriteria method when Task is inserted.
        closeCasesWithExhaustedCriteria(newList, null);
        
        removeFromCallList(newList, null);
        callHoursOfDay(newList, false);
    }
    
    // 11-28-2016 Viraj Rana: #133707065: Case to Call Activiy
    // Call assignCaseId method when the task is inserted
    public static void beforeInsert(List<Task> newList){
        assignCaseId(newList);
    }

    // Call removeFromCallList method when the task is updated
    public static void afterUpdate(List<Task> newList, Map<Id, Task> oldMap) {
        // Call closeCasesWithExhaustedCriteria method when Task is updated.
        closeCasesWithExhaustedCriteria(newList, oldMap);
        removeFromCallList(newList, oldMap);
    }

    // Call removeFromCallList method when the task is updated
    public static void beforeUpdate(List<Task> newList) {
        callHoursOfDay(newList, true);
    }

    // Getter-setter for callListNameMap
    private static Map<String, String> callListNameMap {
        get {
            if (callListNameMap == null) {
                callListNameMap = new Map<String, String>();
                for (Campaign cm : [
                        Select Id, Name, IsActive
                        From Campaign
                        Where isActive = true
                ]) {
                    callListNameMap.put(cm.Name, String.valueOf(cm.Id));
                }
            }
            return callListNameMap;
        }
        set;
    }
    
    // 11-28-2016 Viraj Rana: #133707065: Case to Call Activiy
    // This method is used to assign Latest Case Id in Task/Activity based on Campaign.
    private static void assignCaseId(List<Task> newList) {
        Set<Id> setContactId = new Set<Id>();
        Set<String> setFive9Campaign = new Set<String>();
        
        Map<String,String> mapCampaignMapping = new Map<String,String>();
        
        Map<String,Task> mapTask = new Map<String,Task>();
        
        for (Campaign_Mapping__mdt cm : [Select MasterLabel, Salesforce_Campaign_Name__c
                                            From Campaign_Mapping__mdt]) {
            mapCampaignMapping.put(cm.MasterLabel, cm.Salesforce_Campaign_Name__c);
        }
        
        for (Task t : newList) {
            string strFive9Campaign;
            
            if (t.Five9__Five9Campaign__c != null && t.WhoId != null
                    && String.valueOf(t.WhoId).startsWith(CONTACTPREFIX)
                    && t.WhatId == null) {
                
                if (t.Five9__Five9Campaign__c.contains(OB)) {
                    strFive9Campaign = t.Five9__Five9Campaign__c.replace(OB, '').trim();
                } else if (t.Five9__Five9Campaign__c.contains(IB)) {
                    strFive9Campaign = t.Five9__Five9Campaign__c.replace(IB, '').trim();
                }                
                system.debug('strFive9Campaign : ' + strFive9Campaign);            
            
                if (mapCampaignMapping.containsKey(strFive9Campaign)) {
                                    
                    setContactId.add(t.WhoId);
                    setFive9Campaign.add(mapCampaignMapping.get(strFive9Campaign));
                    
                    mapTask.put(t.WhoId + '-' + mapCampaignMapping.get(strFive9Campaign), t);
                }
            }
        }
        
        if (setContactId.size() > 0) {
            for (Campaign_Member_History__c cmh : [SELECT Id, Campaign__c, Campaign__r.Name, Contact__c, Case_ID__c
                                                    FROM Campaign_Member_History__c
                                                    WHERE Campaign__r.Name in: setFive9Campaign
                                                        and Contact__c in: setContactId
                                                        and Case_ID__c != null
                                                    order by createddate desc]) {
                                            
                if (mapTask.containsKey(cmh.Contact__c + '-' + cmh.Campaign__r.Name)) {
                    mapTask.get(cmh.Contact__c + '-' + cmh.Campaign__r.Name).WhatId = cmh.Case_ID__c;
                    mapTask.remove(cmh.Contact__c + '-' + cmh.Campaign__r.Name);
                }                       
            }
        }
    }
    
    /* 01-09-2017 Viraj Rana: #132948555: Define Exhausted Effort.
     * It is used for Retry and Error Exhausted Calculation.
     */
    public class ExhaustedCriteriaCounts {
        public Integer retryCount { get; set; }
        public Integer errorCount { get; set; }

        public ExhaustedCriteriaCounts() {
            // Default value set by 0,
            this.retryCount = 0;
            this.errorCount = 0;
        }
    }
    
    // 12-02-2016 Viraj Rana: #132948555: Define Exhausted Effort.
    // This method is used to Closed the Case based on Exhausted Criteria.
    private static void closeCasesWithExhaustedCriteria(List<Task> newList, Map<Id,Task> oldMap) {
        
        // Check Task is not updated through Trigger bz of Task is updated by "callHoursOfDay" method in Trigger.
        if (isRecursive) return;
        
        Set<Id> contactIds = new Set<Id>();
        Set<Id> caseIds = new Set<Id>();
        Set<String> five9Campaigns = new Set<String>();
        
        Map<String,String> mapCampaignMapping = new Map<String,String>();
        
        for (Campaign_Mapping__mdt cm: [SELECT MasterLabel, Salesforce_Campaign_Name__c
                                            FROM Campaign_Mapping__mdt]) {
            mapCampaignMapping.put(cm.MasterLabel, cm.Salesforce_Campaign_Name__c);
        }

        for (Task t: newList) {
            if (t.CallDisposition != null && t.Five9__Five9Campaign__c != null
                    && t.WhoId != null
                    && String.valueOf(t.WhoId).startsWith(CONTACTPREFIX)
                    && t.WhatId != null
                    && String.valueOf(t.WhatId).startsWith(CASEPREFIX)
                    && (oldMap == null || t.CallDisposition != oldMap.get(t.Id).CallDisposition)
                    && (oldMap == null || t.WhatId != oldMap.get(t.Id).WhatId)) {
                
                string strFive9Campaign;
                
                if (t.Five9__Five9Campaign__c.contains(OB)) {
                    strFive9Campaign = t.Five9__Five9Campaign__c.replace(OB, '').trim();
                } else if (t.Five9__Five9Campaign__c.contains(IB)) {
                    strFive9Campaign = t.Five9__Five9Campaign__c.replace(IB, '').trim();
                }
                
                if (mapCampaignMapping.containsKey(strFive9Campaign)) {                                    
                    contactIds.add(t.WhoId);
                    five9Campaigns.add(t.Five9__Five9Campaign__c);
                    caseIds.add(t.WhatId);
                }
            }
        }
        
        if (contactIds.size() > 0) {
            Set<String> finalDispositions = new Set<String>();
            Set<String> retryDispositions = new Set<String>();
            Set<String> errorDispositions = new Set<String>();
            
            Set<String> finalCaseIds = new Set<String>();
            Set<String> exhaustedCaseIds = new Set<String>();
            
            // Get Exhausted Criteria data from Custom Meta Data.
            for (Exhausted_Criteria__mdt ec: [SELECT MasterLabel, Disposition_Type__c FROM Exhausted_Criteria__mdt]) {
                if (ec.Disposition_Type__c.equals(FINAL_DISPOSITION)) {
                    finalDispositions.add(ec.MasterLabel);
                } else if (ec.Disposition_Type__c.equals(RETRY_DISPOSITION)) {
                    retryDispositions.add(ec.MasterLabel);
                } else if (ec.Disposition_Type__c.equals(ERROR_DISPOSITION)) {
                    errorDispositions.add(ec.MasterLabel);
                }
            }
            
            for (Contact c: [
                            SELECT Id, FirstName, LastName, 
                                (SELECT Id, CallDisposition, Five9__Five9Campaign__c, WhatId
                                FROM Tasks
                                WHERE WhatId != null
                                AND CallDisposition != null
                                AND WhoId != null
                                AND WhatId IN :caseIds
                                AND Five9__Five9Campaign__c IN :five9Campaigns)
                             FROM Contact WHERE Id IN :contactIds
                             ]) {
                
                Map<Id, ExhaustedCriteriaCounts> mapDispositionCounts = new Map<Id, ExhaustedCriteriaCounts>();
                for (Task t: c.Tasks) {
                    if (finalDispositions.contains(t.CallDisposition)) {
                        finalCaseIds.add(t.WhatId);
                        // Remove Case Id in set of Exhausted Case Ids.
                        // If any task contains Final Disposition value than we need to closed the case with Final.
                        exhaustedCaseIds.remove(t.WhatId);
                    } else if (retryDispositions.contains(t.CallDisposition) && !finalCaseIds.contains(t.WhatId)
                            && !exhaustedCaseIds.contains(t.WhatId)) {
                        if (!mapDispositionCounts.containsKey(t.WhatId)) {
                            mapDispositionCounts.put(t.WhatId, new ExhaustedCriteriaCounts());
                        }
                        mapDispositionCounts.get(t.WhatId).retryCount++;

                        if (mapDispositionCounts.get(t.WhatId).retryCount >= MAX_RETRY_COUNT) {
                            exhaustedCaseIds.add(t.WhatId);
                        }
                    } else if (errorDispositions.contains(t.CallDisposition) && !finalCaseIds.contains(t.WhatId)
                            && !exhaustedCaseIds.contains(t.WhatId)) {
                        if (!mapDispositionCounts.containsKey(t.WhatId)) {
                            mapDispositionCounts.put(t.WhatId, new ExhaustedCriteriaCounts());
                        }
                        mapDispositionCounts.get(t.WhatId).errorCount++;

                        if (mapDispositionCounts.get(t.WhatId).errorCount >= MAX_ERROR_COUNT) {
                            exhaustedCaseIds.add(t.WhatId);
                        }
                    }
                }
            }
            
            if (finalCaseIds.size() > 0 || exhaustedCaseIds.size() > 0) {
                Set<String> allCaseIds = new Set<String>();                
                allCaseIds.addAll(finalCaseIds);
                allCaseIds.addAll(exhaustedCaseIds);
                
                List<Case> lstCase = [SELECT Id, Status, Reason FROM Case
                                        WHERE Id IN :allCaseIds AND Status != :CASE_STATUS_CLOSED];
                                        
                if (lstCase.size() > 0) {
                    for (Case c: lstCase) {
                        if (finalCaseIds.contains(c.Id)) {
                            c.Status = CASE_STATUS_CLOSED;
                            c.Reason = CASE_REASON_FINAL;
                        } else if (exhaustedCaseIds.contains(c.Id)) {
                            c.Status = CASE_STATUS_CLOSED;
                            c.Reason = CASE_REASON_EXHAUSTED;
                        }
                    }
                    
                    Update lstCase;
                }
            }
        }
    }
    	
    // Call removeFromCallList method when the task is created or updated
    private static void removeFromCallList(List<Task> newList, Map<Id, Task> oldMap) {
        Set<Id> contactIds = new Set<Id>();
        for (Task t : newList) {
            if (t.CallDisposition != null && t.WhoId != null
                    && String.valueOf(t.WhoId).startsWith('003')
                    && (t.CallDisposition.trim().equalsIgnoreCase('Final')
                    || t.CallDisposition.trim().equalsIgnoreCase('Retry')
                    || t.CallDisposition.trim().equalsIgnoreCase('Error'))
                    && (oldMap == null || t.CallDisposition != oldMap.get(t.Id).CallDisposition)) {
                contactIds.add(t.WhoId);
            }
        }

        if (contactIds.size() > 0) {
            Map<String, ActivityCounterWrapper> counterMap = new Map<String, ActivityCounterWrapper>();
            Map<String, CampaignMember> cmMap = new Map<String, CampaignMember>();
            for (CampaignMember cm : [
                    Select Id, ContactId, CampaignId
                    From CampaignMember
                    Where ContactId IN :contactIds
                    AND CampaignId IN :callListNameMap.values()
            ]) {
                String keyStr = String.valueOf(cm.ContactId).substring(0, 15) + '-'
                        + String.valueOf(cm.CampaignId).substring(0, 15);
                cmMap.put(keyStr, cm);
            }

            for (Contact c : [
                    Select Id, FirstName, LastName, (
                            Select Id, CallDisposition, Five9__Five9Campaign__c
                            From Tasks
                            WHERE Five9__Five9Campaign__c != null
                            AND Five9__Five9Campaign__c IN :callListNameMap.KeySet()
                            AND CallDisposition IN ('Final', 'Retry', 'Error')
                    )
                    From Contact
                    Where Id IN :contactIds
            ]) {
                for (Task t : c.Tasks) {
                    if (callListNameMap.containsKey(t.Five9__Five9Campaign__c)) {
                        String keyStr = String.valueOf(c.Id).substring(0, 15) + '-'
                                + callListNameMap.get(t.Five9__Five9Campaign__c).substring(0, 15);
                        if (!counterMap.containsKey(keyStr)) {
                            counterMap.put(keyStr,
                                    new ActivityCounterWrapper(c.Id,
                                            callListNameMap.get(t.Five9__Five9Campaign__c)));
                        }
                        if (t.CallDisposition.trim().equalsIgnoreCase('Final')) {
                            counterMap.get(keyStr).finalCount++;
                        }
                        if (t.CallDisposition.trim().equalsIgnoreCase('Retry')) {
                            counterMap.get(keyStr).retryCount++;
                        }
                        if (t.CallDisposition.trim().equalsIgnoreCase('Error')) {
                            counterMap.get(keyStr).errorCount++;
                        }
                    }
                }
            }

            List<CampaignMember> cmListToRemove = new List<CampaignMember>();
            for (String keyStr : counterMap.keySet()) {
                ActivityCounterWrapper acw = counterMap.get(keyStr);
                if ((acw.finalCount == 1 || acw.retryCount == 2 || acw.errorCount == 5)
                        && cmMap.containsKey(keyStr)) {
                    cmListToRemove.add(cmMap.get(keyStr));
                }
            }

            if (cmListToRemove.size() > 0) {
                delete cmListToRemove;
            }
        }
    }

    /*#130111863 : Viraj Rana :Call Activity Dates and Timestamps
     * Call callHoursOfDay method when the task is created to calculate the Hours Of Day
     */
    private static void callHoursOfDay(List<Task> newList, Boolean isUpdate) {
        if (isRecursive) return;

        List<User_Timezone_Setting__mdt> lstUserSetting = [Select id, Timezone_Name__c
                                                           From User_Timezone_Setting__mdt 
                                                           where DeveloperName = 'Default' limit 1];
        List<Task> lstTask = new List<Task>();

        for (Task objTask : newList) {
            // This is the Date and Time in the users TimeZone
            //string customerDateTimeString = objTask.Createddate;
            //DateTime customerDateTime = DateTime.valueofGmt(customerDateTimeString);
            //string customerTimeZoneSidId = 'America/Los_Angeles';
            if(!lstUserSetting.IsEmpty() && !String.isblank(lstUserSetting[0].Timezone_Name__c)){
                String selectedTimeZone = lstUserSetting[0].Timezone_Name__c;
                String strConvertedDate = objTask.Createddate.format('MM/dd/yyyy HH:mm:ss', selectedTimeZone );
                String strHours = objTask.Createddate.format('HH', selectedTimeZone );
                if (isUpdate) {
                    objTask.Hours_of_Day__c = Integer.Valueof(strHours);
                } else {
                    Task tempTask = objTask.Clone(true);
                    tempTask.Hours_of_Day__c = Integer.Valueof(strHours);
                    lstTask.add(tempTask);
                }
            }
        }

        if (!lstTask.Isempty()) {
            isRecursive = true;
            update lstTask;
            isRecursive = false;
        }
    }

    //Wrapper class of ActivityCounter
    public class ActivityCounterWrapper {
        public String contactId { get; set; }
        public String campaignId { get; set; }
        public Integer finalCount { get; set; }
        public Integer retryCount { get; set; }
        public Integer errorCount { get; set; }

        public ActivityCounterWrapper(String conId, String campId) {
            this.contactId = conId;
            this.campaignId = campId;
            this.finalCount = 0;
            this.retryCount = 0;
            this.errorCount = 0;
        }
    }
}