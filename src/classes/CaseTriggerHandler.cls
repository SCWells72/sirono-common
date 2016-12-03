/*
* @author: Sirono
* @version 1.0.1
* @Date: 05-05-2016 
*
* 08-11-2016: Sirono - Tracker # 128030957 For Removal from Early-out campaign
*
* 08-12-2016: Sirono - Tracker # 127517133 For Removal from Precollections campaign
*
* 08-18-2016: Sirono - Tracker # 128457157 For Encounter: Remove Guarantor to the Preservice Call list
*    
* 08-22-2016: Sirono - Tracker # 128197107 For Remove Guarantor to the Delinquent Payment Plan Call list
*
* 08-25-2016: Sirono - Tracker # 127517003 For Add/Remove Guarantor to the CC Error Call list
* 
* 09-22-2016 Sirono - Tracker # 130687155 REMOVED CONDITION TO CHECK FOR CASE RECORD TYPE
*/

public with sharing class CaseTriggerHandler {

    /* PUBLIC METHOD CALLED FROM TRIGGER
    * Call the method checkAndDoAddNoteCallout
    */
    public static void afterInsert(List<Case> newList) {
        //ONLY DOING CALLOUT WHEN BATCH SIZE IS ONE (It's Created from UI)
        if (newList.size() == 1) {
            checkAndDoAddNoteCallout(newList.get(0));
        }
    }
        
    /* PUBLIC METHOD CALLED FROM TRIGGER
    * Call the method removeCampaignMembers
    */
    public static void afterUpdate(List<Case> newList, Map<Id, Case> oldMap) {
        removeCampaignMembers(newList, oldMap);
    }

    //PRIVATE METHOD TO VALIDATE AND CALL ADD NOTE FUTURE METHOD
    //Call a Method addNoteFuture with Charge_Group_IDs__c and Description parameter and send a Request to endpoint
    private static void checkAndDoAddNoteCallout(Case c) {
        //Tracker # 130687155 REMOVED CONDITION TO CHECK FOR CASE RECORD TYPE 
        if (c.Description != null) {
            //CHECK IF CASE DID NOT CREATED BY SIRONO INTEGRATION USER
            for (Case ob : [Select Id, Description, Charge_Group_IDs__c From Case Where Id = :c.Id AND CreatedBy.Name != 'Sirono Integration' AND Charge_Group_IDs__c != null]) {
                //CALL FUTURE METHOD FOR ADD NOTE CALLOUT
                //split the Charge_Group_IDs__c parameter to pass it as a List in the method
                PayStaffWSUtill.addNoteFuture(ob.Charge_Group_IDs__c.split(','), ob.Description);
            }
        }
    }
                                                        
   /*
    * 08-11-2016: Sirono - Tracker # 128030957 For Removal from Early-out campaign
    *
    * 08-12-2016: Sirono - Tracker # 127517133 For Removal from Precollections campaign
    *
    * 08-18-2016: Sirono - Tracker # 128457157 For Encounter: Remove Guarantor to the Preservice Call list
    *    
    * 08-22-2016: Sirono - Tracker # 128197107 For Remove Guarantor to the Delinquent Payment Plan Call list
    *
    * 08-25-2016: Sirono - Tracker # 127517003 For Add/Remove Guarantor to the CC Error Call list
    */
    private static void removeCampaignMembers(List<Case> newList,
            Map<Id, Case> oldMap) {
        if (!CaseUtil.executeRemoveCampaignTrigger) return;

        Set<Id> earlyOutGuarantors = new Set<Id>();
        Set<Id> preCollectionGuarantors = new Set<Id>();
        Set<String> encounterGuarantors = new Set<String>();
        Set<Id> delinquentGuarantors = new Set<Id>();
        Set<Id> ccErrorGuarantors = new Set<Id>();
        for (Case c : newList) {
            if (c.IsClosed && !oldMap.get(c.Id).IsClosed) {
                if (c.Type == 'Early Out' && c.Guarantor_Information__c != null) {
                    earlyOutGuarantors.add(c.Guarantor_Information__c);
                }
                if (c.Type == 'Precollections' && c.Guarantor_Information__c != null) {
                    preCollectionGuarantors.add(c.Guarantor_Information__c);
                }
                if (c.Type == 'Encounter' && c.Guarantor_Information__c != null) {
                    encounterGuarantors.add(c.Guarantor_Information__c);
                }
                if (c.Type == 'Delinquent' && c.Guarantor_Information__c != null) {
                    delinquentGuarantors.add(c.Guarantor_Information__c);
                }
                if (c.Type == 'CC Error' && c.Guarantor_Information__c != null) {
                    ccErrorGuarantors.add(c.Guarantor_Information__c);
                }
            }
        }

        if (earlyOutGuarantors.size() > 0) {
            Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                    'Early-out', 'Early-out M'
            });
            string earlyOut = mapCampaignMapping.get('Early-out');
            string earlyOutMobile = mapCampaignMapping.get('Early-out M');

            delete [
                    Select id, ContactId
                    From CampaignMember
                    Where (Campaign.Name = :earlyOut or Campaign.Name = :earlyOutMobile)
                    and ContactId in :earlyOutGuarantors
            ];
        }

        if (preCollectionGuarantors.size() > 0) {
            Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                    'PreCollections', 'PreCollections M'
            });
            string preCollection = mapCampaignMapping.get('PreCollections');
            string preCollectionMobile = mapCampaignMapping.get('PreCollections M');

            delete [
                    Select id, ContactId
                    From CampaignMember
                    Where (Campaign.Name = :preCollection or Campaign.Name = :preCollectionMobile)
                    and ContactId in :preCollectionGuarantors
            ];
        }

        if (encounterGuarantors.size() > 0) {
            CaseUtil.closeEncounterAutoCase(null, encounterGuarantors, true);
        }

        if (delinquentGuarantors.size() > 0) {
            Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                    'Delinquent', 'Delinquent M'
            });
            string delinquent = mapCampaignMapping.get('Delinquent');
            string delinquentMobile = mapCampaignMapping.get('Delinquent M');

            Delete [
                    Select id, ContactId
                    From CampaignMember
                    Where (Campaign.Name = :delinquent or Campaign.Name = :delinquentMobile)
                    and ContactId in :delinquentGuarantors
            ];
        }

        if (ccErrorGuarantors.size() > 0) {
            Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                    'CC Error', 'CC Error M'
            });
            string ccError = mapCampaignMapping.get('CC Error');
            string ccErrorMobile = mapCampaignMapping.get('CC Error M');

            Delete [
                    Select id, ContactId
                    From CampaignMember
                    Where (Campaign.Name = :ccError or Campaign.Name = :ccErrorMobile )
                    and ContactId in :ccErrorGuarantors
            ];
        }
    }
}