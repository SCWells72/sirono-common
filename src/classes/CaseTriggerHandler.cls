public with sharing class CaseTriggerHandler {
    // PUBLIC METHOD CALLED FROM TRIGGER
    public static void afterInsert(List<Case> newList) {
        //ONLY DOING CALLOUT WHEN BATCH SIZE IS ONE (It's Created from UI)
        if (newList.size() == 1) {
            checkAndDoAddNoteCallout(newList.get(0));
        }
    }

    // PUBLIC METHOD CALLED FROM TRIGGER
    public static void afterUpdate(List<Case> newList, Map<Id, Case> oldMap) {
        removeCampaignMembers(newList, oldMap);
    }

    // PRIVATE METHOD TO VALIDATE AND CALL ADD NOTE FUTURE METHOD
    private static void checkAndDoAddNoteCallout(Case c) {
        Map<String, Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();
        String caseNotesRTId = rtMapByName.get('Internal Case').getRecordTypeId();

        // CHECK IF CASE RECORD OF NOTES TYPE 
        if (c.RecordTypeId == caseNotesRTId && c.Description != null) {
            // CHECK IF CASE DID NOT CREATED BY SIRONO INTEGRATION USER
            // AND HAVE Charge_Group_Id__c ON ASSOCIATED CHARGE GROUP RECORD
            for (Case ob : [
                    Select Id, Description, Charge_Group_IDs__c
                    From Case
                    Where Id = :c.Id AND CreatedBy.Name != 'Sirono Integration'
                    AND Charge_Group_IDs__c != null
            ]) {
                // CALL FUTURE METHOD FOR ADD NOTE CALLOUT
                PayStaffWSUtill.addNoteFuture(ob.Charge_Group_IDs__c, ob.Description);
            }
        }
    }

    private static void removeCampaignMembers(List<Case> newList, Map<Id, Case> oldMap) {
        if (!CaseUtil.ExecuteRemoveCampaignTrigger) return;

        Set<Id> earlyOutGuarantors = new Set<Id>();
        Set<Id> preCollectionGuarantors = new Set<Id>();
        Set<String> encounterGuarantors = new Set<String>();

        for (Case c : newList) {
            if (c.IsClosed && !oldMap.get(c.Id).IsClosed) {
                if (c.Type == 'Early Out' && c.Guarantor_Information__c != null) earlyOutGuarantors.add(c.Guarantor_Information__c);
                if (c.Type == 'Precollections' && c.Guarantor_Information__c != null) preCollectionGuarantors.add(c.Guarantor_Information__c);
                if (c.Type == 'Encounter' && c.Guarantor_Information__c != null) encounterGuarantors.add(c.Guarantor_Information__c);
            }
        }

        if (earlyOutGuarantors.size() > 0) {
            delete [Select id, ContactId from CampaignMember where (Campaign.Name = 'Early Out' or Campaign.Name = 'Early Out - Mobile') and ContactId in :earlyOutGuarantors];
        }

        if (preCollectionGuarantors.size() > 0) {
            delete [Select id, ContactId from CampaignMember where (Campaign.Name = 'Pre-collections' or Campaign.Name = 'Pre-collections - Mobile') and ContactId in :preCollectionGuarantors];
        }

        if (encounterGuarantors.size() > 0) {
            CaseUtil.CloseEncounterAutoCase(null, encounterGuarantors, true);
        }
    }
}