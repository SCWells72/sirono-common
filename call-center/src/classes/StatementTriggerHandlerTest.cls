/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
public class StatementTriggerHandlerTest {
    private static Contact createStatementPrereqs(String status, String substatus, Decimal amount) {
        Contact guarantor = TestUtility.generateGuarantorContact();
        guarantor.Profile_Pointer_Id__c = 100.0;
        insert guarantor;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(
            guarantor.Id,
            patientContact.Id,
            200.0
        );
        chargeGroup.Account_Status__c = status;
        chargeGroup.Account_Sub_Status__c = substatus;
        insert chargeGroup;

        TestUtility.createAllCampaigns();

        Service2__c service = TestUtility.generateService(guarantor, amount);
        insert service;

        Transaction__c txn = TestUtility.generateServiceTxn(chargeGroup, amount, service);
        insert txn;

        return guarantor;
    }

    @IsTest
    private static void testStatementWithOverdueBalance() {
        Contact guarantor = createStatementPrereqs(
            Constants.ACCT_STATUS_BILLED,
            Constants.ACCT_SUBSTATUS_OVERDUE,
            100.00
        );

        Test.startTest();
        {
            Statement__c statement = new Statement__c(
                Statement_Date__c = System.today(),
                Guarantor__c = guarantor.Id
            );
            insert statement;
        }
        Test.stopTest();

        List<Case> cases = [SELECT Id, Type FROM Case WHERE Subject = :Constants.CASE_SUBJECT_GUARANTOR_OVERDUE];
        System.assertEquals(1, cases.size());
        System.assertEquals(Constants.CASE_TYPE_OVERDUE, cases[0].Type);

        List<CampaignMember> campaignMembers = [SELECT Id FROM CampaignMember];
        System.assertEquals(2, campaignMembers.size());
    }

    @IsTest
    private static void testStatementWithNoOverdueBalance() {
        Contact guarantor = createStatementPrereqs(
            Constants.ACCT_STATUS_BILLED,
            Constants.ACCT_SUBSTATUS_OVERDUE,
            -100.00
        );

        Test.startTest();
        {
            Statement__c statement = new Statement__c(
                Statement_Date__c = System.today(),
                Guarantor__c = guarantor.Id
            );
            insert statement;
        }
        Test.stopTest();

        List<Case> cases = [SELECT Id, Type FROM Case WHERE Subject = :Constants.CASE_SUBJECT_GUARANTOR_OVERDUE];
        System.assert(cases.isEmpty());

        List<CampaignMember> campaignMembers = [SELECT Id FROM CampaignMember];
        System.assert(campaignMembers.isEmpty());
    }

    @IsTest
    private static void testStatementWithOverdueBalanceAndSettingDisabled() {
        // Disable overdue balance/precollections auto-case creation
        Sirono_Call_Center_Settings__c sironoCallCenterSettings = SironoCallCenterSettingsUtil.getSironoCallCenterSettings();
        sironoCallCenterSettings.Auto_Create_Overdue_Cases__c = false;
        update sironoCallCenterSettings;

        Contact guarantor = createStatementPrereqs(
            Constants.ACCT_STATUS_BILLED,
            Constants.ACCT_SUBSTATUS_OVERDUE,
            100.00
        );

        Test.startTest();
        {
            Statement__c statement = new Statement__c(
                Statement_Date__c = System.today(),
                Guarantor__c = guarantor.Id
            );
            insert statement;
        }
        Test.stopTest();

        List<Case> cases = [SELECT Id, Type FROM Case WHERE Subject = :Constants.CASE_SUBJECT_GUARANTOR_OVERDUE];
        System.assert(cases.isEmpty());

        List<CampaignMember> campaignMembers = [SELECT Id FROM CampaignMember];
        System.assert(campaignMembers.isEmpty());
    }

    @IsTest
    private static void testStatementWithDelinquentBalance() {
        Contact guarantor = createStatementPrereqs(
            Constants.ACCT_STATUS_BILLED,
            Constants.ACCT_SUBSTATUS_DELINQUENT,
            100.00
        );

        Test.startTest();
        {
            Statement__c statement = new Statement__c(
                Statement_Date__c = System.today(),
                Guarantor__c = guarantor.Id
            );
            insert statement;
        }
        Test.stopTest();

        List<Case> cases = [SELECT Id, Type FROM Case WHERE Subject = :Constants.CASE_SUBJECT_GUARANTOR_DELINQUENT];
        System.assertEquals(1, cases.size());
        System.assertEquals(Constants.CASE_TYPE_PRECOLLECTIONS, cases[0].Type);

        List<CampaignMember> campaignMembers = [SELECT Id FROM CampaignMember];
        System.assertEquals(2, campaignMembers.size());
    }

    @IsTest
    private static void testStatementWithNoDelinquentBalance() {
        Contact guarantor = createStatementPrereqs(
            Constants.ACCT_STATUS_BILLED,
            Constants.ACCT_SUBSTATUS_DELINQUENT,
            -100.00
        );

        Test.startTest();
        {
            Statement__c statement = new Statement__c(
                Statement_Date__c = System.today(),
                Guarantor__c = guarantor.Id
            );
            insert statement;
        }
        Test.stopTest();

        List<Case> cases = [SELECT Id, Type FROM Case WHERE Subject = :Constants.CASE_SUBJECT_GUARANTOR_DELINQUENT];
        System.assert(cases.isEmpty());

        List<CampaignMember> campaignMembers = [SELECT Id FROM CampaignMember];
        System.assert(campaignMembers.isEmpty());
    }

    @IsTest
    private static void testStatementWithDelinquentBalanceAndSettingDisabled() {
        // Disable delinquent balance/precollections auto-case creation
        Sirono_Call_Center_Settings__c sironoCallCenterSettings = SironoCallCenterSettingsUtil.getSironoCallCenterSettings();
        sironoCallCenterSettings.Auto_Create_Precollection_Cases__c = false;
        update sironoCallCenterSettings;

        Contact guarantor = createStatementPrereqs(
            Constants.ACCT_STATUS_BILLED,
            Constants.ACCT_SUBSTATUS_DELINQUENT,
            100.00
        );

        Test.startTest();
        {
            Statement__c statement = new Statement__c(
                Statement_Date__c = System.today(),
                Guarantor__c = guarantor.Id
            );
            insert statement;
        }
        Test.stopTest();

        List<Case> cases = [SELECT Id, Type FROM Case WHERE Subject = :Constants.CASE_SUBJECT_GUARANTOR_DELINQUENT];
        System.assert(cases.isEmpty());

        List<CampaignMember> campaignMembers = [SELECT Id FROM CampaignMember];
        System.assert(campaignMembers.isEmpty());
    }
}