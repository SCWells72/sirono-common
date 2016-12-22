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
    
    public static final String CONTACTPREFIX = '003';
    public static final String CASEPREFIX = '500';
    public static final String OB = 'OB';
    public static final String IB = 'IB';

    // Call removeFromCallList method when the task is inserted
    public static void afterInsert(List<Task> newList) {
        // Call caseCloseWithExhaustedCriteria method when Task is inserted.
        caseCloseWithExhaustedCriteria(newList, null);
        
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
        // Call caseCloseWithExhaustedCriteria method when Task is updated.
        caseCloseWithExhaustedCriteria(newList, oldMap);
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

    // 12-02-2016 Viraj Rana: #132948555: Define Exhausted Effort.
    // This method is used to Closed the Case based on Exhausted Criteria.
    private static void caseCloseWithExhaustedCriteria(List<Task> newList, Map<Id,Task> oldMap) {
    
        Set<Id> setContactId = new Set<Id>();
        Set<Id> setCaseId = new Set<Id>();
        
        for (Task t : newList) {
            if (t.CallDisposition != null
                    && t.WhoId != null
                    && String.valueOf(t.WhoId).startsWith(CONTACTPREFIX)
                    && t.WhatId != null
                    && String.valueOf(t.WhatId).startsWith(CASEPREFIX)
                    && (oldMap == null || t.CallDisposition != oldMap.get(t.Id).CallDisposition)
                    && (oldMap == null || t.WhatId != oldMap.get(t.Id).WhatId)) {
                
                setContactId.add(t.WhoId);
                setCaseId.add(t.WhatId);
            }
        }
        
        if (setContactId.size() > 0) {
            // Get Exhausted Criteria data in Custom Settings.
            List<Exhausted_Criteria__mdt> lstExhaustedCriteria = [select MasterLabel, Type__c from Exhausted_Criteria__mdt];
            Set<String> setFinalDisposition = new Set<String>();
            Set<String> setRetryDisposition = new Set<String>();
            Set<String> setErrorDisposition = new Set<String>();
            
            Set<String> setFinalCase = new Set<String>();
            Set<String> setExhaustedCase = new Set<String>();
            
            for (Exhausted_Criteria__mdt ec : lstExhaustedCriteria) {
                if (ec.Type__c == 'Final Dispositions') {
                    setFinalDisposition.add(ec.MasterLabel);
                } else if (ec.Type__c == 'Retry Dispositions') {
                    setRetryDisposition.add(ec.MasterLabel);
                } else if (ec.Type__c == 'Error Dispositions') {
                    setErrorDisposition.add(ec.MasterLabel);
                }
            }
            
            for (Contact c : [
                            Select Id, FirstName, LastName, 
                                (Select Id, CallDisposition, WhatId
                                From Tasks
                                WHERE WhatId != null
                                AND CallDisposition != null
                                AND WhoId != null
                                AND WhatId in: setCaseId)
                             From Contact Where Id IN: setContactId
                             ]) {
                
                Integer count = 0;
                Map<Id,String> mapDispositionCount = new Map<Id,String>();
                
                for (Task t : c.Tasks) {
                    if (setFinalDisposition.contains(t.CallDisposition)) {                        
                        setFinalCase.add(t.WhatId);

                        if (setExhaustedCase.contains(t.WhatId)) {
                            setExhaustedCase.remove(t.WhatId);
                        }
                    } else if (setRetryDisposition.contains(t.CallDisposition) && !setFinalCase.contains(t.WhatId)
                            && !setExhaustedCase.contains(t.WhatId)) {
                        if (!mapDispositionCount.containsKey(t.WhatId)) {
                            mapDispositionCount.put(t.WhatId, '1#0');
                        } else {
                            count = Integer.valueof(mapDispositionCount.get(t.WhatId).split('#')[0]);
                            count ++;
                            if (count >= 2) {
                                setExhaustedCase.add(t.WhatId);
                            } else {
                                mapDispositionCount.put(t.WhatId, count + '#' + mapDispositionCount.get(t.WhatId).split('#')[1]);
                            }
                        }
                    } else if (setErrorDisposition.contains(t.CallDisposition) && !setFinalCase.contains(t.WhatId)
                            && !setExhaustedCase.contains(t.WhatId)) {
                        if (!mapDispositionCount.containsKey(t.WhatId)) {
                            mapDispositionCount.put(t.WhatId, '0#1');
                        } else {
                            count = Integer.valueof(mapDispositionCount.get(t.WhatId).split('#')[1]);
                            count ++;
                            if (count >= 5) {
                                setExhaustedCase.add(t.WhatId);
                            } else {                                
                                mapDispositionCount.put(t.WhatId, mapDispositionCount.get(t.WhatId).split('#')[0] + '#' + count);
                            }
                        }
                    }
                }
            }
            
            if (setFinalCase.size() > 0 || setExhaustedCase.size() > 0) {
                Set<String> setAllCase = new Set<String>();                
                setAllCase.addAll(setFinalCase);
                setAllCase.addAll(setExhaustedCase);
                
                List<Case> lstCase = [SELECT Id, Status, Reason FROM Case
                                        WHERE Id in: setAllCase and Status != 'Closed'];
                                        
                if (lstCase.size() > 0) {
                    for (Case c : lstCase) {
                        if (setFinalCase.contains(c.Id)) {
                            c.Status = 'Closed';
                            c.Reason = 'Case Closed - FINAL';
                        } else if (setExhaustedCase.contains(c.Id)) {
                            c.Status = 'Closed';
                            c.Reason = 'Case Closed - Exhausted';
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