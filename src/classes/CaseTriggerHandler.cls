/**
 * TriggerHandler class for CaseTrigger.
 **/

public with sharing class CaseTriggerHandler {

    /**
     * This method is use after insert the case.
     *
     * @param List<Case> newList - That contains List of Case.
     **/
    public static void afterInsert(List<Case> newList) {
        if (newList.isEmpty()) {
            return;
        }

        if (newList.size() == 1) {
            // Passing parameter change Case single record to List of Case to resolve Security Scan Issue.
            checkAndDoAddNoteCallout(newList);
        }

        createCaseCGJunctions(newList);
        createCampaignMemberRecords(newList);
    }

    /**
     * This method is use after update the case.
     *
     * @param List<Case> newList - That contains List of Case.
     * @param Map<Id, Case> oldMap - That contains Map of Case.
     **/
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
        if (newCases.get(0).Description != null) {
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
                    // CALL FUTURE METHOD FOR ADD NOTE CALLOUT
                    PayStaffWSUtill.addNoteFuture(cases[0].Charge_Group_IDs__c.split(','), cases[0].Description);
                }
            }
        }
    }

   /**
    * Remove campaign members associated with the given guarantorId/Case.Type combos
    *
    * @param List<Case> newList - That contains List of Case.
    * @param Map<Id, Case> oldMap - That contains Map of Case.
    **/
    private static void removeCampaignMembers(List<Case> newList, Map<Id, Case> oldMap) {
        if (!CaseUtil.executeRemoveCampaignTrigger) {
            return;
        }

        Map<String, Set<Id>> caseCmpnMemberMap = new Map<String, Set<Id>>();

        for (Case c: newList) {
            if ((c.IsClosed && !oldMap.get(c.Id).IsClosed) &&
                c.Guarantor_Information__c != null) {

                if (!caseCmpnMemberMap.containsKey(c.Type)) {
                    caseCmpnMemberMap.put(c.Type, new Set<Id>());
                }

                caseCmpnMemberMap.get(c.Type).add(c.Guarantor_Information__c);
            }
        }

        CampaignMemberService.deleteMembers(caseCmpnMemberMap);
    }

    /**
     * Create Case_CG Junction records.
     *
     * @param List<Case> newList - That contains List of Case.
     **/
    private static void createCaseCGJunctions(List<Case> newList) {
        Map<String, List<Case>> filteredCases = new Map<String, List<Case>>();

        Map<Id, List<Charge_Group__c>> chargeGroups = new Map<Id, List<Charge_Group__c>>();

        for (Case objCase: newList) {
            if (!String.isEmpty(objCase.Guarantor_Information__c)) {
                if (Constants.CASE_CG_SUBSTATUS.containsKey(objCase.Type)) {

                    if (!filteredCases.containsKey(objCase.Type)) {
                        filteredCases.put(objCase.Type, new List<Case>());
                    }
                    filteredCases.get(objCase.Type).add(objCase);
                }
            }
        }

        if (!filteredCases.isEmpty()) {
            CaseService.createCaseCGJunctions(filteredCases);
        }
    }

    /**
     * Create campaign members for the guarantor associated with the case for all
     * campaigns associated with the case's type. If there is a mapping, create a campaign member.
     *
     * @param newCases the cases to create campaign members for
     **/
    private static void createCampaignMemberRecords(List<Case> newCases) {
        // Collect the guarantorIds from the new cases & group by caseType
        Map<String, Set<Id>> caseTypeGTMap = new Map<String, Set<Id>>();

        for (Case objCase: newCases) {
            if (!String.isEmpty(objCase.Guarantor_Information__c)) {
                if (!caseTypeGTMap.containsKey(objCase.Type)) {
                    caseTypeGTMap.put(objCase.Type, new Set<Id>());
                }
                caseTypeGTMap.get(objCase.Type).add(objCase.Guarantor_Information__c);
            }
        }

        CampaignMemberService.createCampaignMembers(caseTypeGTMap);
    }
}
