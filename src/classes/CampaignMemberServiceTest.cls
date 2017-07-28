/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Test the CampaignMemberService
 **/
@IsTest
public with sharing class CampaignMemberServiceTest {

    /**
     * This method tests the logic of addCmpnMember method.
     **/
    @IsTest
    static void addCmpnMemberTest() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(Constants.CAMPAIGN_NAME_OVERDUE);
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(Constants.CAMPAIGN_NAME_OVERDUE_M);
        lstCampaign.add(objCampaign);
        insert lstCampaign;

        // Check system assert.
        List<CampaignMember> campaignMembers = [SELECT Id FROM CampaignMember WHERE ContactId = :guarantorContact.Id];
        System.assertEquals(0, campaignMembers.size(), 'Should be campaignMembers size is zero but we got ' + campaignMembers.size());

        Test.startTest();
        campaignMembers = CampaignMemberService.createNewCampaignMembers(Constants.CASE_TYPE_OVERDUE, new Set<Id> { guarantorContact.Id });
        Test.stopTest();

        // Check system assert.
        System.assertEquals(2, campaignMembers.size(), 'Expected campaignMembers size equals to 2 but we got ' + campaignMembers.size());
    }

    /**
     * This method tests the logic of addCmpnMember method negative.
     **/
    @IsTest
    static void addCmpnMemberNegativeTest() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;


        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(Constants.CAMPAIGN_NAME_OVERDUE);
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(Constants.CAMPAIGN_NAME_OVERDUE_M);
        lstCampaign.add(objCampaign);
        insert lstCampaign;

        // Check system assert.
        List<CampaignMember> campaignMembers = [SELECT Id FROM CampaignMember WHERE ContactId = :guarantorContact.Id];
        System.assertEquals(0, campaignMembers.size(), 'Should be campaignMembers size is zero but we got ' + campaignMembers.size());

        Test.startTest();
        campaignMembers = CampaignMemberService.createNewCampaignMembers(null, new Set<Id> { guarantorContact.Id });
        Test.stopTest();

        // Check system assert, campaignMembers size equals to 0 because of we pass case type equals to null.
        System.assertEquals(0, campaignMembers.size(), 'Expected campaignMembers size equals to 0 but we got ' + campaignMembers.size());
    }

}