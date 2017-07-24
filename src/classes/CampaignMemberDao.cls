/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * CampaignMemberDao for CampaignMember object SOQL/DML operations
 **/
public with sharing class CampaignMemberDao extends AbstractDao {


    /**
     *  Helper methods invoked from the TriggerHandlers to keep the system in a valid state
     *  Because this work could be triggered by a portal user creating a payment plan, no FLS/CRUD checks
     *  are done here
     */
    public without sharing class ElevatedPrivilegesHelper {
        //Remove these Campaign Members for the specified campaign
        public void removeFromCampaign(String campaignName, Set<Id> contactIds) {

            List<CampaignMember> membersToRemove = new List<CampaignMember>([
                    SELECT Id, ContactId, CampaignId
                    FROM CampaignMember
                    WHERE ContactId IN :contactIds
                    AND Campaign.Name = :campaignName
            ]);

            if (!membersToRemove.isEmpty()) {
                DELETE membersToRemove;
            }
        }
    }

    /**
     * Get the campaign and campaign member records based on contact.
     *
     * @param Set<Id> contactIds - That contains Contact Ids.
     * @param Set<String> campaignNames - That contains Campaign Names.
     * @returns List<Campaign> campaigns - That contains List of Campaigns with campaign members based on contact and campaign names.
     **/
    public static List<Campaign> getCampaigns(Set<Id> contactIds, Set<String> campaignNames) {
        List<Campaign> campaigns = new List<Campaign>();

        if (CampaignSecurityContext.SELECT_CONTEXT.actionAllowed() &&
                    CmpnMemberSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
            campaigns = [SELECT Id, Name,
                            (
                                SELECT Id, ContactId
                                FROM CampaignMembers
                                WHERE ContactId IN :contactIds
                            )
                        FROM Campaign
                        WHERE Name IN :campaignNames AND IsActive = TRUE
            ];
        }
        return campaigns;
    }

    /**
     * Get the campaign member records based on case type and contacts.
     *
     **/
    public static List<CampaignMember> getCampaignMembers(String caseType, Set<Id> guarantors) {
        // Get Campaign Names from Metadata.
        Set<String> campaignNames = getSFCampaignNames(caseType);

        if (CmpnMemberSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            return [
                    SELECT Id, ContactId
                    FROM CampaignMember
                    WHERE Campaign.Name IN :campaignNames
                    AND ContactId IN :guarantors
            ];
        }
        return new List<CampaignMember>();
    }

    /**
     * Get the caseToCampaign Mappings from the meta data based on Case Type.
     *
     * @param String caseType - That contains Case.Type value.
     *
     * @returns Set<String> campaignNames - That contains SF Campaign Names based on case type.
     **/
    //TODO Do we want to put access to all our custom metadata in a single dao? This feels like a weird place for it
    public static Set<String> getSFCampaignNames(String caseType) {
        Set<String> campaignNames = new Set<String>();

        for (Case_to_Campaign__mdt objCCM: [
                SELECT Case_Type__c, Salesforce_Campaign_Name__c
                FROM Case_to_Campaign__mdt
                WHERE Case_Type__c = :caseType
        ]) {
            campaignNames.add(objCCM.Salesforce_Campaign_Name__c);
        }
        return campaignNames;
    }

    /**
     * This method is use to insert campaign member records.
     *
     * @param List<CampaignMember> campaignMembers - That contains campaign member records.
     **/
    public static void insertCampaignMembers(List<CampaignMember> campaignMembers) {
        if (CmpnMemberSecurityContext.CREATE_CONTEXT.actionAllowed()) {
            INSERT campaignMembers;
        }
    }

    /**
     * This method is use to delete campaign members.
     *
     * @param List<CampaignMember> removeCmpnMembers - That contains list of campaign members.
     **/
    public static void deleteCampaignMembers(List<CampaignMember> removeCmpnMembers) {
        // Create instant of CmpnMemberSecurityContext class. It is use to check Delete access on Object.
        CmpnMemberSecurityContext cmpnMemSecurityContext = new CmpnMemberSecurityContext();

        if (cmpnMemSecurityContext.deleteActionAllowed()) {
            DELETE removeCmpnMembers;
        }
    }
}