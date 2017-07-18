/**
 * TriggerHandler class for CaseTrigger.
 **/

public with sharing class CaseTriggerHandler {

    /**
     * This method is use after insert the case.
     *
     * @param List<Case> newList - That contains List of Case.
     **/
    public static void afterInsert(List<Case> cases) {
        if (cases.isEmpty()) {
            return;
        }

        checkAndDoAddNoteCallout(cases);
        createCaseCGJunctions(cases);
        createCampaignMemberRecords(cases);
    }

    /**
     * This method is use after update the case.
     *
     * @param List<Case> newList - That contains List of Case.
     * @param Map<Id, Case> oldMap - That contains Map of Case.
     **/
    public static void afterUpdate(List<Case> cases, Map<Id, Case> oldCasesByIds) {
        removeCampaignMembers(cases, oldCasesByIds);
    }

    /**
     * PRIVATE METHOD TO VALIDATE AND CALL ADD NOTE FUTURE METHOD
     * Call a Method addNoteFuture with Charge_Group_IDs__c and Description parameter and send a Request to endpoint
     *
     * @param List<Case> newCases - That contains List of Case.
     *
     * Parameter change Case object to List of Case to resolve Security Scan Issue.
     **/
    private static void checkAndDoAddNoteCallout(List<Case> cases) {
        if (CampaignSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            List<Id> caseIds = new List<Id>();
            for (Case aCase : cases) {
                if (String.isNotBlank(aCase.Description)) {
                    caseIds.add(aCase.Id);
                }
            }

            if (!caseIds.isEmpty()) {
                // NOTE: We can't filter by CreatedBy.Name in a unit test context, so query all case comments and
                // filter by creator afterward
                List<User> sironoIntegrationUsers = [SELECT Id FROM User WHERE Name = :Constants.SIRONO_INTEGRATION_USER_NAME LIMIT 1];
                User sironoIntegrationUser = (sironoIntegrationUsers.size() == 1) ? sironoIntegrationUsers.get(0) : null;
                Id sironoIntegrationUserId = sironoIntegrationUser != null ? sironoIntegrationUser.Id : null;

                List<Case> queriedCases = new List<Case>([
                    SELECT Id, Description, (
                        SELECT Charge_Group__c
                        FROM Case_Charge_Groups__r
                    )
                    FROM Case
                    WHERE Id IN :caseIds
                    AND CreatedById != :sironoIntegrationUserId
                ]);
                if (!queriedCases.isEmpty()) {
                    // TODO: Once there's a bulk version of this API, collate all requests and invoke in bulk
                    for (Case queriedCase : queriedCases) {
                        List<String> chargeGroupIds = new List<String>();
                        for (Case_Charge_Group_Junction__c caseChargeGroupJunction : queriedCase.Case_Charge_Groups__r) {
                            chargeGroupIds.add(caseChargeGroupJunction.Charge_Group__c);
                        }
                        if (!chargeGroupIds.isEmpty()) {
                            PayStaffWSUtill.addNoteFuture(chargeGroupIds, queriedCase.Description);
                        }
                    }
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
    private static void removeCampaignMembers(List<Case> cases, Map<Id, Case> oldCasesByIds) {
        if (!CaseUtil.executeRemoveCampaignTrigger) {
            return;
        }

        Map<String, Set<Id>> caseCmpnMemberMap = new Map<String, Set<Id>>();

        for (Case aCase: cases) {
            if ((aCase.IsClosed && !oldCasesByIds.get(aCase.Id).IsClosed) &&
                aCase.Guarantor_Information__c != null) {

                if (!caseCmpnMemberMap.containsKey(aCase.Type)) {
                    caseCmpnMemberMap.put(aCase.Type, new Set<Id>());
                }

                caseCmpnMemberMap.get(aCase.Type).add(aCase.Guarantor_Information__c);
            }
        }

        CampaignMemberService.deleteMembers(caseCmpnMemberMap);
    }

    /**
     * Create Case_CG Junction records.
     *
     * @param List<Case> newList - That contains List of Case.
     **/
    private static void createCaseCGJunctions(List<Case> cases) {
        Map<String, List<Case>> filteredCases = new Map<String, List<Case>>();

        Map<Id, List<Charge_Group__c>> chargeGroups = new Map<Id, List<Charge_Group__c>>();

        for (Case aCase: cases) {
            if (!String.isEmpty(aCase.Guarantor_Information__c)) {
                if (Constants.CASE_CG_SUBSTATUS.containsKey(aCase.Type)) {

                    if (!filteredCases.containsKey(aCase.Type)) {
                        filteredCases.put(aCase.Type, new List<Case>());
                    }
                    filteredCases.get(aCase.Type).add(aCase);
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
    private static void createCampaignMemberRecords(List<Case> cases) {
        // Collect the guarantorIds from the new cases & group by caseType
        Map<String, Set<Id>> caseTypeGTMap = new Map<String, Set<Id>>();

        for (Case aCase: cases) {
            if (!String.isEmpty(aCase.Guarantor_Information__c)) {
                if (!caseTypeGTMap.containsKey(aCase.Type)) {
                    caseTypeGTMap.put(aCase.Type, new Set<Id>());
                }
                caseTypeGTMap.get(aCase.Type).add(aCase.Guarantor_Information__c);
            }
        }

        CampaignMemberService.createCampaignMembers(caseTypeGTMap);
    }
}
