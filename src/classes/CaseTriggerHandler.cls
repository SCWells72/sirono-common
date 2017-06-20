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
            // Passing parameter change Case single record to List of Case to resolve Security Scan Issue.
            checkAndDoAddNoteCallout(newList);
        }

        createCaseCGRecords(newList);
    }
        
    /* PUBLIC METHOD CALLED FROM TRIGGER
    * Call the method removeCampaignMembers
    */
    public static void afterUpdate(List<Case> newList, Map<Id, Case> oldMap) {
        removeCampaignMembers(newList, oldMap);
    }

    /**
     * PRIVATE METHOD TO VALIDATE AND CALL ADD NOTE FUTURE METHOD
     * Call a Method addNoteFuture with Charge_Group_IDs__c and Description parameter and send a Request to endpoint
     *
     * @param List<Case> newCases - That contains List of Case.
     *
     * Parameter change Case object to List of Case to resolve Security Scan Issue.
     **/
    private static void checkAndDoAddNoteCallout(List<Case> newCases) {      
        //Tracker # 130687155 REMOVED CONDITION TO CHECK FOR CASE RECORD TYPE 
        if (newCases.get(0).Description != null) {
            // CHECK IF CASE DID NOT CREATED BY SIRONO INTEGRATION USER

            if (CaseSecurityContext.SELECT_CONTEXT.actionAllowed()) {
                // We have removed Loop and take List Variable because of we need only one record based on Case Id.
                // This changes do for Security Scan's "Async Future Method Inside Loops" related Error.
                List<Case> cases = new List<Case>([
                            SELECT Id, Description, Charge_Group_IDs__c
                            FROM Case
                            WHERE Id = :newCases.get(0).Id
                            AND CreatedBy.Name != 'Sirono Integration'
                            AND Charge_Group_IDs__c != null
                ]);
                if (cases.size() > 0) {
                    //CALL FUTURE METHOD FOR ADD NOTE CALLOUT
                    //split the Charge_Group_IDs__c parameter to pass it as a List in the method
                    PayStaffWSUtill.addNoteFuture(cases[0].Charge_Group_IDs__c.split(','), cases[0].Description);
                }
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
        
        // Create instant of CmpnMemberSecurityContext class. It is use to check Delete access on Object.
	CmpnMemberSecurityContext cmpnMemSecurityContext = new CmpnMemberSecurityContext();

        if (earlyOutGuarantors.size() > 0) {
            Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                    'Early-out', 'Early-out M'
            });
            string earlyOut = mapCampaignMapping.get('Early-out');
            string earlyOutMobile = mapCampaignMapping.get('Early-out M');

            if (cmpnMemSecurityContext.deleteActionAllowed()) {
                if (CmpnMemberSecurityContext.SELECT_CONTEXT.actionAllowed()) {
                    DELETE [
                            SELECT Id, ContactId
                            FROM CampaignMember
                            WHERE (Campaign.Name = :earlyOut OR Campaign.Name = :earlyOutMobile)
                            AND ContactId IN :earlyOutGuarantors
                    ];
                }
            }
        }

        if (preCollectionGuarantors.size() > 0) {
            Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                    'PreCollections', 'PreCollections M'
            });
            string preCollection = mapCampaignMapping.get('PreCollections');
            string preCollectionMobile = mapCampaignMapping.get('PreCollections M');

            if (cmpnMemSecurityContext.deleteActionAllowed()) {
                if (CmpnMemberSecurityContext.SELECT_CONTEXT.actionAllowed()) {
                    DELETE [
                            SELECT Id, ContactId
                            FROM CampaignMember
                            WHERE (Campaign.Name = :preCollection OR Campaign.Name = :preCollectionMobile)
                            AND ContactId IN :preCollectionGuarantors
                    ];
                }
            }
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

            if (cmpnMemSecurityContext.deleteActionAllowed()) {
                if (CmpnMemberSecurityContext.SELECT_CONTEXT.actionAllowed()) {
                    DELETE [
                            SELECT Id, ContactId
                            FROM CampaignMember
                            WHERE (Campaign.Name = :delinquent OR Campaign.Name = :delinquentMobile)
                            AND ContactId IN :delinquentGuarantors
                    ];
                }
            }
        }

        if (ccErrorGuarantors.size() > 0) {
            Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                    'CC Error', 'CC Error M'
            });
            string ccError = mapCampaignMapping.get('CC Error');
            string ccErrorMobile = mapCampaignMapping.get('CC Error M');

            if (cmpnMemSecurityContext.deleteActionAllowed()) {
                if (CmpnMemberSecurityContext.SELECT_CONTEXT.actionAllowed()) {
                    DELETE [
                            SELECT Id, ContactId
                            FROM CampaignMember
                            WHERE (Campaign.Name = :ccError OR Campaign.Name = :ccErrorMobile )
                            AND ContactId IN :ccErrorGuarantors
                    ];
                }
            }
        }
    }

    private static void createCaseCGRecords(List<Case> newList) {
        if (newList.size() > 0) {
            Set<Id> contactIds = new Set<Id>();
            Set<String> cgSubStatuses = new Set<String>();
            Map<Id, List<Charge_Group__c>> chargeGroups = new Map<Id, List<Charge_Group__c>>();

            List<RecordType> rt = new List<RecordType>();
            if (RecordTypeSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
                rt = [
                        SELECT Id
                        FROM RecordType
                        WHERE SobjectType = 'Case'
                        AND DeveloperName = 'Automated_Cases'
                ];
            }

            for (Case objCase: newList) {
                if (!String.isEmpty(objCase.Guarantor_Information__c) && objCase.RecordTypeID == rt[0].Id) {
                    contactIds.add(objCase.Guarantor_Information__c);
                    if (objCase.Type == Constants.CASE_TYPE_OVERDUE) {
                        cgSubStatuses.add(Constants.ACCT_SUBSTATUS_OVERDUE);
                    } else if (objCase.Type == Constants.CASE_TYPE_PRECOLLECTIONS) {
                        cgSubStatuses.add(Constants.ACCT_SUBSTATUS_DELINQUENT);
                    } else if (objCase.Type == Constants.CASE_TYPE_CC_ERROR) {
                        cgSubStatuses.add(Constants.ACCT_SUBSTATUS_PAYMENT_PLAN);
                    }
                }
            }

            for (Charge_Group__c cg: ChargeGroupService.getCGBasedOnGuarantorFilterByStatus(contactIds, cgSubStatuses)) {
                if (chargeGroups.containsKey(cg.Guarantor__c)) {
                    chargeGroups.get(cg.Guarantor__c).add(cg);
                } else {
                    chargeGroups.put(cg.Guarantor__c, new List<Charge_Group__c>{cg});
                }
            }

            if (chargeGroups.size() > 0) {
                ChargeGroupService.insertCaseCGJunRecords(chargeGroups, newList);
            }
        }
    }
}