/**
 * CampaignMemberService with logic for creating/deleting CampaignMembers
 **/

public with sharing class CampaignMemberService extends AbstractService {

    /**
     * Create new campaign members for the guarantors associated with the given caseType. If a case is associated with
     * more than one campaign, the gt will be added as a member to all. However, we only want to add a gt as a
     * This method is use to add contact as a campaign member (List).
     * campaigns without duplicating the guarantor within a campaign
     *
     * @param Set<String> campaignNames - That contains Name of Campaigns.
     * @param Map<Id, Contact> mapContact - That contains Map of Contact with Ids.
     * @returns List<CampaignMember> campaignMembers - That contains list of campaign members need to insert.
     */
    public static void createCampaignMembers(Map<String, Set<Id>> caseTypeGTMap) {
        List<CampaignMember> newCampaignMembers = new List<CampaignMember>();

        for (String caseType: caseTypeGTMap.keySet()) {
            newCampaignMembers.addAll(createNewCampaignMembers(caseType, caseTypeGTMap.get(caseType)));
        }

        CampaignMemberDao.insertCampaignMembers(newCampaignMembers);
    }

    /**
     * Create new campaign members for the guarantors associated with the given caseType. If a case is associated with
     * more than one campaign, the gt will be added as a member to all. However, we only want to add a gt as a
     * member once to a campaign (no dupes), so if their id is already there, skip them
     *
     * @param String caseType - That contains case type.
     * @param Set<Id> gtIds - The guarantor Ids associated with this caseType.
     * @returns List<CampaignMember> newCampaignMembers - That contains list of campaign members.
     **/
    @TestVisible
    private static List<CampaignMember> createNewCampaignMembers(String caseType, Set<Id> gtIds) {
        Set<String> campaignNames = CampaignMemberDao.getSFCampaignNames(caseType);
        Set<Id> currentMembers = new Set<Id>();
        Map<String, Id> campaignNameIdMap = new Map<String, Id>();

        for (Campaign campaign: CampaignMemberDao.getCampaigns(gtIds, campaignNames)) {
            campaignNameIdMap.put(campaign.Name, campaign.Id);
            for (CampaignMember objCM: campaign.CampaignMembers) {
                currentMembers.add(objCM.ContactId);
            }
        }

        gtIds.removeAll(currentMembers);
        List<CampaignMember> newCampaignMembers = new List<CampaignMember>();

        for (Id gtId: gtIds) {
            for (String campaignName: campaignNameIdMap.keySet()) {
                CampaignMember campaignMember = new CampaignMember();
                campaignMember.CampaignId = campaignNameIdMap.get(campaignName);
                campaignMember.ContactId = gtId;
                newCampaignMembers.add(campaignMember);
            }
        }

        return newCampaignMembers;
    }

    /**
     * Given a case type and the associated guarantorIds, delete the campaignMembers associated with
     * @param Set<String> caseTypes - That contains Case.Type values.
     *
     * @returns Map<String, Set<String>> mapCampaignMapping - That contains Case.Type Name with List of SF Campaign Names.
     */
    public static void deleteMembers(Map<String, Set<Id>> caseCmpnMemberMap) {

        List<CampaignMember> membersToDelete = new List<CampaignMember>();

        for (String caseType: caseCmpnMemberMap.keySet()) {
            membersToDelete.addAll(CampaignMemberDao.getCampaignMembers(caseType, caseCmpnMemberMap.get(caseType)));
        }

        CampaignMemberDao.deleteCampaignMembers(membersToDelete);
    }
}
