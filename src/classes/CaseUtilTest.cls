/*
* @author Sirono
* @version 1.0.1
* @Date: 08-23-2016
* @ Unit class  for the CaseUtil class.
* Do the code coverage for the CaseUtil class
* 10-19-2016: Viraj - Tracker # 132105543: Revisit negative balances in cases.
* 12-02-2016: Viraj Rana - #133707065: Case to Call Activiy.
*/

@isTest
public class CaseUtilTest {
    public Static List<CampaignMember> lst ;

    //Method to code coverage for callEarlyOutAutoCaseCloser
    @isTest
    public static void callEarlyOutAutoCaseCloser() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 121343);
        insert chargeGroup;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 12134323);
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        chargeGroup.Account_Status__c = Constants.ACCT_STATUS_BILLED;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, -100, Constants.SERVICE);
        insert txn;

        List<Statement__c> statements = new List<Statement__c>();
        Statement__c statement = TestUtility.generateStatement(guarantorContact.Id);
        statements.add(statement);

        statement = TestUtility.generateStatement(guarantorContact.Id);
        statements.add(statement);
        insert statements;

        Test.startTest();
        Map<String, String> campaignMapping = CaseUtil.campaignMapping(new Set<String> {
            Constants.CAMPAIGN_NAME_OVERDUE,
            Constants.CAMPAIGN_NAME_OVERDUE_M,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS_M,
            Constants.CAMPAIGN_NAME_PRESERVICE,
            Constants.CAMPAIGN_NAME_PRESERVICE_M,
            Constants.CAMPAIGN_NAME_PAST_DUE,
            Constants.CAMPAIGN_NAME_PAST_DUE_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR
        });

        List<Campaign> campaigns = new List<Campaign>();
        Campaign campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_OVERDUE));
        campaigns.add(campaign);

        campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_OVERDUE_M));
        campaigns.add(campaign);

        insert campaigns;

        List<CampaignMember> campaignMembers = new list<CampaignMember>();
        CampaignMember campaignMember = new CampaignMember(CampaignId = campaigns[0].Id, ContactId = guarantorContact.Id, Status = Constants.SENT);
        campaignMembers.add(campaignMember);

        campaignMember = new CampaignMember(CampaignId = campaigns[1].Id, ContactId = guarantorContact.Id, Status = Constants.SENT);
        campaignMembers.add(campaignMember);

        insert campaignMembers;

        Case overdueCase = TestUtility.generateCase(RecordTypeUtil.automatedCaseRt, Constants.CASE_TYPE_OVERDUE, guarantorContact.Id);
        overdueCase.Reason = Constants.CASE_REASON_COMPLIANCE_ISSUE;
        insert overdueCase;

        CaseUtil.callEarlyOutAutoCaseCloser();
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, Status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert.
        System.assertEquals(1, cases.size());
        System.assertEquals(Constants.CASE_STATUS_CLOSED, cases[0].Status);
    }

    //Method to code coverage for callCloseEarlyOutAutoCase
    @isTest
    public static void closeEarlyOutAutoCase() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 121343);
        insert chargeGroup;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 12134323);
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        chargeGroup.Account_Status__c = Constants.ACCT_STATUS_BILLED;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, -100, Constants.SERVICE);
        insert txn;

        List<Statement__c> statements = new List<Statement__c>();
        Statement__c statement = TestUtility.generateStatement(guarantorContact.Id);
        statements.add(statement);


        statement = TestUtility.generateStatement(guarantorContact.Id);
        statements.add(statement);
        insert statements;

        Test.startTest();
        Map<String, String> campaignMapping = CaseUtil.campaignMapping(new Set<String> {
            Constants.CAMPAIGN_NAME_OVERDUE,
            Constants.CAMPAIGN_NAME_OVERDUE_M,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS_M,
            Constants.CAMPAIGN_NAME_PRESERVICE,
            Constants.CAMPAIGN_NAME_PRESERVICE_M,
            Constants.CAMPAIGN_NAME_PAST_DUE,
            Constants.CAMPAIGN_NAME_PAST_DUE_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR
        });

        List<Campaign> campaigns = new List<Campaign>();
        Campaign campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_OVERDUE));
        campaigns.add(campaign);

        campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_OVERDUE_M));
        campaigns.add(campaign);

        insert campaigns;

        List<CampaignMember> campaignMembers = new list<CampaignMember>();
        CampaignMember campaignMember = new CampaignMember(CampaignId = campaigns[0].Id, ContactId = guarantorContact.Id, Status = Constants.SENT);
        campaignMembers.add(campaignMember);

        campaignMember = new CampaignMember(CampaignId = campaigns[1].Id, ContactId = guarantorContact.Id, Status = Constants.SENT);
        campaignMembers.add(campaignMember);

        insert campaignMembers;

        Case overdueCase = TestUtility.generateCase(RecordTypeUtil.automatedCaseRt, Constants.CASE_TYPE_OVERDUE, guarantorContact.Id);
        overdueCase.Reason = Constants.CASE_REASON_COMPLIANCE_ISSUE;
        insert overdueCase;

        CaseUtil.callCloseEarlyOutAutoCase(statements);
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, Status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert.
        System.assertEquals(1, cases.size());
        System.assertEquals(Constants.CASE_STATUS_CLOSED, cases[0].Status);
    }


    //Method to code coverage for callPrecollectionsAutoCase
    @isTest
    public static void preCollCaseWithoutDelinquentBalance() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 121343);
        insert chargeGroup;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 12134323);
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        chargeGroup.Account_Status__c = Constants.ACCT_STATUS_BILLED;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, -100, Constants.SERVICE);
        insert txn;

        Test.startTest();
        Statement__c statement = TestUtility.generateStatement(guarantorContact.Id);
        INSERT statement;
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, Status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert, to see no case records get created.
        System.assertEquals(0, cases.size());
    }

    // TODO: Should we just delete this in factor of the one in StatementProcessBuilderFlowTest?
    // Method to code coverage for createPrecollectionsAutoCase
    @isTest
    public static void preCollCaseWithComplianceIssue() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 121343);
        insert chargeGroup;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 12134323);
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        chargeGroup.Account_Status__c = Constants.ACCT_STATUS_BILLED;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        insert chargeGroup;

        //10-19-2016: Viraj - Tracker # 132105543-Change "Delinquent_Balance__c = '< 0' to '> 0'" in condition.
        //Change transaction amount -100 to 100.
        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, 100, Constants.SERVICE);
        insert txn;

        Statement__c statement = TestUtility.generateStatement(guarantorContact.Id);
        insert statement;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = :Case.SObjectType.getDescribe().getName()]) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> campaignMapping = CaseUtil.campaignMapping(new Set<String> {
            Constants.CAMPAIGN_NAME_OVERDUE,
            Constants.CAMPAIGN_NAME_OVERDUE_M,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS_M,
            Constants.CAMPAIGN_NAME_PRESERVICE,
            Constants.CAMPAIGN_NAME_PRESERVICE_M,
            Constants.CAMPAIGN_NAME_PAST_DUE,
            Constants.CAMPAIGN_NAME_PAST_DUE_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR
        });

        List<Campaign> campaigns = new List<Campaign>();
        Campaign campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PRECOLLECTIONS));
        campaigns.add(campaign);

        campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PRECOLLECTIONS_M));
        campaigns.add(campaign);

        insert campaigns;
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, Status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert, Case record is not created because of Compliance Issue.
        System.assertEquals(1, cases.size());
    }

    //Method to code coverage for callPrecollectionsAutoCaseCloser
    @isTest
    public static void callPrecollAutoCaseCloserWithTodayStatement() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 121343);
        insert chargeGroup;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 12134323);
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        chargeGroup.Account_Status__c = Constants.ACCT_STATUS_BILLED;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, -100, Constants.SERVICE);
        insert txn;

        Test.startTest();
        List<Statement__c> statements = new List<Statement__c>();
        Statement__c statement = TestUtility.generateStatement(guarantorContact.Id);
        statements.add(statement);


        statement = TestUtility.generateStatement(guarantorContact.Id);
        statements.add(statement);
        insert statements;

        CaseUtil.callPrecollectionsAutoCaseCloser();
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert, No case record is created because of statment's created date is today.
        System.assert(cases.isEmpty());
    }

    //Method to code coverage for callClosePrecollectionsAutoCase
    @isTest
    public static void closePrecollAutoCaseToCheckCaseReason() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 121343);
        insert chargeGroup;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 12134323);
        chargeGroup.Reported_Selfpay_Balance__c = -10;
        chargeGroup.Account_Status__c = Constants.ACCT_STATUS_BILLED;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, -100, Constants.SERVICE);
        insert txn;

        List<Statement__c> statements = new List<Statement__c>();
        Statement__c statement = TestUtility.generateStatement(guarantorContact.Id);
        statements.add(statement);


        statement = TestUtility.generateStatement(guarantorContact.Id);
        statements.add(statement);
        insert statements;

        Test.startTest();
        Map<String, String> campaignMapping = CaseUtil.campaignMapping(new Set<String> {
            Constants.CAMPAIGN_NAME_OVERDUE,
            Constants.CAMPAIGN_NAME_OVERDUE_M,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS_M,
            Constants.CAMPAIGN_NAME_PRESERVICE,
            Constants.CAMPAIGN_NAME_PRESERVICE_M,
            Constants.CAMPAIGN_NAME_PAST_DUE,
            Constants.CAMPAIGN_NAME_PAST_DUE_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR
        });

        List<Campaign> campaigns = new List<Campaign>();
        Campaign campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PRECOLLECTIONS));
        campaigns.add(campaign);

        campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PRECOLLECTIONS_M));
        campaigns.add(campaign);

        insert campaigns;

        Case overdueCase = TestUtility.generateCase(RecordTypeUtil.automatedCaseRt, Constants.CASE_TYPE_OVERDUE, guarantorContact.Id);
        overdueCase.Type = Constants.CASE_TYPE_PRECOLLECTIONS;
        insert overdueCase;

        // Retrive Case record.
        List<Case> cases = [SELECT Id, Reason, Status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];
        // Check system assert, case reason is not populated before call method.
        System.assertEquals(null, cases[0].Reason);

        CaseUtil.callClosePrecollectionsAutoCase(statements);
        Test.stopTest();

        // Retrive Case record.
        List<Case> caseAfterCall = [SELECT Id, Reason, Status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert, case reason is populated after call method.
        System.assertEquals(Constants.CASE_REASON_CLOSED_AUTOMATED, caseAfterCall[0].Reason);
        System.assertEquals(Constants.CASE_STATUS_CLOSED, caseAfterCall[0].Status);
    }

    //Method to code coverage for createEncounterAutoCase
    @isTest
    public static void checkEncounterAutoCaseWithComplianceIssue() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 121343);
        insert chargeGroup;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 12134323);
        chargeGroup.Reported_Selfpay_Balance__c = -10;
        chargeGroup.Account_Status__c = Constants.ACCT_STATUS_BILLED;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, -100, Constants.SERVICE);
        insert txn;

        List<Encounter__c> lstEncounter = new List<Encounter__c>();
        //10-19-2016: Viraj - Tracker # 132105543-Change Patient_Portion__c = '< 0' to '> 0'" in condition.
        //Change patient Portion amount -10 to 10.
        Encounter__c encounter1 = TestUtility.generateEncounter(guarantorContact.Id, 10, Date.today());
        lstEncounter.add(encounter1);

        //10-19-2016: Viraj - Tracker # 132105543-Change Patient_Portion__c = '< 0' to '> 0'" in condition.
        //Change patient Portion amount -10 to 10.
        Encounter__c encounter2 = TestUtility.generateEncounter(guarantorContact.Id, 10, Date.today());
        lstEncounter.add(encounter2);

        insert lstEncounter;
        encounter1.Patient_Portion__c = 0;
        update encounter1;

        Test.startTest();
        Map<String, String> campaignMapping = CaseUtil.campaignMapping(new Set<String> {
            Constants.CAMPAIGN_NAME_OVERDUE,
            Constants.CAMPAIGN_NAME_OVERDUE_M,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS_M,
            Constants.CAMPAIGN_NAME_PRESERVICE,
            Constants.CAMPAIGN_NAME_PRESERVICE_M,
            Constants.CAMPAIGN_NAME_PAST_DUE,
            Constants.CAMPAIGN_NAME_PAST_DUE_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR
        });

        List<Campaign> campaigns = new List<Campaign>();
        Campaign campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PRESERVICE));
        campaigns.add(campaign);

        campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PRESERVICE_M));
        campaigns.add(campaign);

        insert campaigns;

        List<CampaignMember> campaignMembers = new list<CampaignMember>();
        CampaignMember campaignMember = new CampaignMember(CampaignId = campaigns[0].Id, ContactId = guarantorContact.Id, Status = Constants.SENT);
        campaignMembers.add(campaignMember);

        campaignMember = new CampaignMember(CampaignId = campaigns[1].Id, ContactId = guarantorContact.Id, Status = Constants.SENT);
        campaignMembers.add(campaignMember);

        insert campaignMembers;

        Case overdueCase = TestUtility.generateCase(RecordTypeUtil.automatedCaseRt, Constants.CASE_TYPE_OVERDUE, guarantorContact.Id);
        overdueCase.Type = Constants.CAMPAIGN_NAME_PRESERVICE;
        overdueCase.Reason = Constants.CASE_REASON_COMPLIANCE_ISSUE;
        insert overdueCase;

        CaseUtil.createEncounterAutoCase(lstEncounter);
        Test.stopTest();

        // Retrive Encounter record.
        List<Encounter__c> encountersafter = [SELECT Id FROM Encounter__c];

        // Check system assert to check encounter records gets created.
        System.assertEquals(2, encountersafter.size());
    }


    //Method to code coverage for createEncounterAutoCase
    @isTest
    public static void createEncounterAutoCase() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 121343);
        insert chargeGroup;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 12134323);
        chargeGroup.Reported_Selfpay_Balance__c = -10;
        chargeGroup.Account_Status__c = Constants.ACCT_STATUS_BILLED;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, -100, Constants.SERVICE);
        insert txn;

        List<Encounter__c> lstEncounter = new List<Encounter__c>();
        //10-19-2016: Viraj - Tracker # 132105543-Change Patient_Portion__c = '< 0' to '> 0'" in condition.
        //Change patient Portion amount -10 to 10.
        Encounter__c encounter1 = TestUtility.generateEncounter(guarantorContact.Id, 10, Date.today());
        lstEncounter.add(encounter1);

        //10-19-2016: Viraj - Tracker # 132105543-Change Patient_Portion__c = '< 0' to '> 0'" in condition.
        //Change patient Portion amount -10 to 10.
        Encounter__c encounter2 = TestUtility.generateEncounter(guarantorContact.Id, 10, Date.today());
        lstEncounter.add(encounter2);

        insert lstEncounter;
        encounter1.Patient_Portion__c = 0;
        update encounter1;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = :Case.SObjectType.getDescribe().getName()]) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> campaignMapping = CaseUtil.campaignMapping(new Set<String> {
            Constants.CAMPAIGN_NAME_OVERDUE,
            Constants.CAMPAIGN_NAME_OVERDUE_M,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS_M,
            Constants.CAMPAIGN_NAME_PRESERVICE,
            Constants.CAMPAIGN_NAME_PRESERVICE_M,
            Constants.CAMPAIGN_NAME_PAST_DUE,
            Constants.CAMPAIGN_NAME_PAST_DUE_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR
        });

        List<Campaign> campaigns = new List<Campaign>();
        Campaign campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PRESERVICE));
        campaigns.add(campaign);

        campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PRESERVICE_M));
        campaigns.add(campaign);

        insert campaigns;

        CaseUtil.createEncounterAutoCase(lstEncounter);
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, Status, Type FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert, new case created with Encounter record type.
        System.assertEquals(Constants.CASE_TYPE_ENCOUNTER, cases[1].Type);
    }

    //Method to code coverage for createDelinquentPaymentCase
    @isTest
    public static void delinquentPaymentCase() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 121343);
        insert chargeGroup;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 12134323);
        chargeGroup.Reported_Selfpay_Balance__c = -10;
        chargeGroup.Account_Status__c = Constants.ACCT_STATUS_BILLED;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, -100, Constants.SERVICE);
        insert txn;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = :Case.SObjectType.getDescribe().getName()]) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> campaignMapping = CaseUtil.campaignMapping(new Set<String> {
            Constants.CAMPAIGN_NAME_OVERDUE,
            Constants.CAMPAIGN_NAME_OVERDUE_M,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS_M,
            Constants.CAMPAIGN_NAME_PRESERVICE,
            Constants.CAMPAIGN_NAME_PRESERVICE_M,
            Constants.CAMPAIGN_NAME_PAST_DUE,
            Constants.CAMPAIGN_NAME_PAST_DUE_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR
        });

        List<Campaign> campaigns = new List<Campaign>();
        Campaign campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PAST_DUE));
        campaigns.add(campaign);

        campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PAST_DUE_M));
        campaigns.add(campaign);

        insert campaigns;

        Set<Id> setId = new Set<Id>();
        setId.add(guarantorContact.Id);
        CaseUtil.createDelinquentPaymentCase(setId);
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, Type, Status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert, new case record created with type.
        System.assertEquals(1, cases.size());
        System.assertEquals(Constants.CASE_TYPE_PAST_DUE_PAYMENT_PLANS, cases[0].Type);
    }

    //Method to code coverage for createDelinquentPaymentCase
    @isTest
    public static void delinquentPaymentCaseWithComplianceIssue() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 121343);
        insert chargeGroup;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 12134323);
        chargeGroup.Reported_Selfpay_Balance__c = -10;
        chargeGroup.Account_Status__c = Constants.ACCT_STATUS_BILLED;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, -100, Constants.SERVICE);
        insert txn;

        Test.startTest();
        Map<String, String> campaignMapping = CaseUtil.campaignMapping(new Set<String> {
            Constants.CAMPAIGN_NAME_OVERDUE,
            Constants.CAMPAIGN_NAME_OVERDUE_M,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS_M,
            Constants.CAMPAIGN_NAME_PRESERVICE,
            Constants.CAMPAIGN_NAME_PRESERVICE_M,
            Constants.CAMPAIGN_NAME_PAST_DUE,
            Constants.CAMPAIGN_NAME_PAST_DUE_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR
        });

        List<Campaign> campaigns = new List<Campaign>();
        Campaign campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PAST_DUE));
        campaigns.add(campaign);

        campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PAST_DUE_M));
        campaigns.add(campaign);

        insert campaigns;

        List<CampaignMember> campaignMembers = new list<CampaignMember>();
        CampaignMember campaignMember = new CampaignMember(CampaignId = campaigns[0].Id, ContactId = guarantorContact.Id, Status = Constants.SENT);
        campaignMembers.add(campaignMember);

        campaignMember = new CampaignMember(CampaignId = campaigns[1].Id, ContactId = guarantorContact.Id, Status = Constants.SENT);
        campaignMembers.add(campaignMember);

        insert campaignMembers;

        Case pastDuePaymentPlansCase = TestUtility.generateCase(RecordTypeUtil.automatedCaseRt, Constants.CASE_TYPE_PAST_DUE_PAYMENT_PLANS, guarantorContact.Id);
        pastDuePaymentPlansCase.Reason = Constants.CASE_REASON_COMPLIANCE_ISSUE;
        insert pastDuePaymentPlansCase;

        Set<Id> setId = new Set<Id>();
        setId.add(guarantorContact.Id);
        CaseUtil.createDelinquentPaymentCase(setId);
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, Type, Status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert, New case record created with Type.
        System.assertEquals(1, cases.size());
        System.assertEquals(Constants.CASE_TYPE_PAST_DUE_PAYMENT_PLANS, cases[0].Type);
    }

    //Method to code coverage for createDelinquentPaymentCase
    @isTest
    public static void createDelinquentPaymentCase() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 121343);
        insert chargeGroup;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 12134323);
        chargeGroup.Reported_Selfpay_Balance__c = -10;
        chargeGroup.Account_Status__c = Constants.ACCT_STATUS_BILLED;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, -100, Constants.SERVICE);
        insert txn;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = :Case.SObjectType.getDescribe().getName()]) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> campaignMapping = CaseUtil.campaignMapping(new Set<String> {
            Constants.CAMPAIGN_NAME_OVERDUE,
            Constants.CAMPAIGN_NAME_OVERDUE_M,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS_M,
            Constants.CAMPAIGN_NAME_PRESERVICE,
            Constants.CAMPAIGN_NAME_PRESERVICE_M,
            Constants.CAMPAIGN_NAME_PAST_DUE,
            Constants.CAMPAIGN_NAME_PAST_DUE_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR
        });

        List<Campaign> campaigns = new List<Campaign>();
        Campaign campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PAST_DUE));
        campaigns.add(campaign);

        campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PAST_DUE_M));
        campaigns.add(campaign);

        insert campaigns;

        List<CampaignMember> campaignMembers = new list<CampaignMember>();
        CampaignMember campaignMember = new CampaignMember(CampaignId = campaigns[0].Id, ContactId = guarantorContact.Id, Status = Constants.SENT);
        campaignMembers.add(campaignMember);

        campaignMember = new CampaignMember(CampaignId = campaigns[1].Id, ContactId = guarantorContact.Id, Status = Constants.SENT);
        campaignMembers.add(campaignMember);

        insert campaignMembers;

        Set<Id> setId = new Set<Id>();
        setId.add(guarantorContact.Id);
        CaseUtil.createDelinquentPaymentCase(setId);
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, Status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert, Delinquent Payment Case create or not.
        System.assertEquals(1, cases.size());
        System.assertEquals(Constants.CASE_STATUS_NEW, cases[0].Status);
    }

    /**
     * This method test the Delinquent Payment Case Closer method functionality.
     * When same guarantor have other payment plan with "active__c = true" and "Delinquent__c = true".
     * At that time Case is not closed if we call "closeDelinquentPaymentCase" method force fully.
     * Existing Case status remains same "New".
     **/
    @isTest
    public static void closeDelinquentPaymentCaseWithSameGuarantor() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 121343);
        insert chargeGroup;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 12134323);
        chargeGroup.Reported_Selfpay_Balance__c = -10;
        chargeGroup.Account_Status__c = Constants.ACCT_STATUS_BILLED;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, -100, Constants.SERVICE);
        insert txn;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = :Case.SObjectType.getDescribe().getName()]) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> campaignMapping = CaseUtil.campaignMapping(new Set<String> {
            Constants.CAMPAIGN_NAME_OVERDUE,
            Constants.CAMPAIGN_NAME_OVERDUE_M,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS_M,
            Constants.CAMPAIGN_NAME_PRESERVICE,
            Constants.CAMPAIGN_NAME_PRESERVICE_M,
            Constants.CAMPAIGN_NAME_PAST_DUE,
            Constants.CAMPAIGN_NAME_PAST_DUE_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR
        });

        List<Campaign> campaigns = new List<Campaign>();
        Campaign campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PAST_DUE));
        campaigns.add(campaign);

        campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PAST_DUE_M));
        campaigns.add(campaign);

        insert campaigns;

        List<CampaignMember> campaignMembers = new list<CampaignMember>();
        CampaignMember campaignMember = new CampaignMember(CampaignId = campaigns[0].Id, ContactId = guarantorContact.Id, Status = Constants.SENT);
        campaignMembers.add(campaignMember);

        campaignMember = new CampaignMember(CampaignId = campaigns[1].Id, ContactId = guarantorContact.Id, Status = Constants.SENT);
        campaignMembers.add(campaignMember);

        insert campaignMembers;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.id);
        paymentPlan.active__c = true;
        paymentPlan.Delinquent__c = true;
        insert paymentPlan;

        Payment_Plan__c paymentPlan1 = TestUtility.generatePaymentPlan(guarantorContact.id);
        paymentPlan1.active__c = true;
        paymentPlan1.Delinquent__c = true;
        insert paymentPlan1;


        Set<Id> setId = new Set<Id>();
        setId.add(guarantorContact.Id);

        Set<Id> setpaymentPlan = new Set<Id>();
        setpaymentPlan.add(paymentPlan.Id);

        CaseUtil.closeDelinquentPaymentCase(setId, setpaymentPlan);
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, Status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert.
        System.assertEquals(1, cases.size());
        System.assertEquals(Constants.CASE_STATUS_NEW, cases[0].Status);
    }


    //Method to code coverage for closeDelinquentPaymentCase
    @isTest
    public static void closeDelinquentPaymentCase() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 121343);
        insert chargeGroup;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 12134323);
        chargeGroup.Reported_Selfpay_Balance__c = -10;
        chargeGroup.Account_Status__c = Constants.ACCT_STATUS_BILLED;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, -100, Constants.SERVICE);
        insert txn;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = :Case.SObjectType.getDescribe().getName()]) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> campaignMapping = CaseUtil.campaignMapping(new Set<String> {
            Constants.CAMPAIGN_NAME_OVERDUE,
            Constants.CAMPAIGN_NAME_OVERDUE_M,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS_M,
            Constants.CAMPAIGN_NAME_PRESERVICE,
            Constants.CAMPAIGN_NAME_PRESERVICE_M,
            Constants.CAMPAIGN_NAME_PAST_DUE,
            Constants.CAMPAIGN_NAME_PAST_DUE_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR
        });

        List<Campaign> campaigns = new List<Campaign>();
        Campaign campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PAST_DUE));
        campaigns.add(campaign);

        campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PAST_DUE_M));
        campaigns.add(campaign);

        insert campaigns;

        List<CampaignMember> campaignMembers = new list<CampaignMember>();
        CampaignMember campaignMember = new CampaignMember(CampaignId = campaigns[0].Id, ContactId = guarantorContact.Id, Status = Constants.SENT);
        campaignMembers.add(campaignMember);

        campaignMember = new CampaignMember(CampaignId = campaigns[1].Id, ContactId = guarantorContact.Id, Status = Constants.SENT);
        campaignMembers.add(campaignMember);

        insert campaignMembers;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.id);
        paymentPlan.active__c = true;
        paymentPlan.Delinquent__c = true;
        insert paymentPlan;

        Set<Id> setId = new Set<Id>();
        setId.add(guarantorContact.Id);

        Set<Id> setpaymentPlan = new Set<Id>();
        setpaymentPlan.add(paymentPlan.Id);

        CaseUtil.closeDelinquentPaymentCase(setId, setpaymentPlan);
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, Status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert, case is closed.
        System.assertEquals(Constants.CASE_STATUS_CLOSED, cases[0].Status);
    }


    //Method to code coverage for createCCErrorCase
    @isTest
    public static void createCCErrorCase() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = :Case.SObjectType.getDescribe().getName()]) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> campaignMapping = CaseUtil.campaignMapping(new Set<String> {
            Constants.CAMPAIGN_NAME_OVERDUE,
            Constants.CAMPAIGN_NAME_OVERDUE_M,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS_M,
            Constants.CAMPAIGN_NAME_PRESERVICE,
            Constants.CAMPAIGN_NAME_PRESERVICE_M,
            Constants.CAMPAIGN_NAME_PAST_DUE,
            Constants.CAMPAIGN_NAME_PAST_DUE_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR
        });

        List<Campaign> campaigns = new List<Campaign>();
        Campaign campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR));
        campaigns.add(campaign);

        campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR_M));
        campaigns.add(campaign);

        insert campaigns;

        List<CampaignMember> campaignMembers = new list<CampaignMember>();
        CampaignMember campaignMember = new CampaignMember(CampaignId = campaigns[0].Id, ContactId = guarantorContact.Id, Status = Constants.SENT);
        campaignMembers.add(campaignMember);

        campaignMember = new CampaignMember(CampaignId = campaigns[1].Id, ContactId = guarantorContact.Id, Status = Constants.SENT);
        campaignMembers.add(campaignMember);

        insert campaignMembers;

        Set<Id> setId = new Set<Id>();
        setId.add(guarantorContact.Id);

        CaseUtil.createCCErrorCase(setId);
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, Status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id AND Type = :Constants.CASE_TYPE_PAYMENT_PLAN_ERROR];

        // Check system assert, New case record gets created.
        System.assertEquals(1, cases.size());
        System.assertEquals(Constants.CASE_STATUS_NEW, cases[0].Status);
    }

    //Method to code coverage for createCCErrorCase1
    @isTest
    public static void createCCErrorCaseWithComplianceIssue() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Test.startTest();
        Map<String, String> campaignMapping = CaseUtil.campaignMapping(new Set<String> {
            Constants.CAMPAIGN_NAME_OVERDUE,
            Constants.CAMPAIGN_NAME_OVERDUE_M,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS_M,
            Constants.CAMPAIGN_NAME_PRESERVICE,
            Constants.CAMPAIGN_NAME_PRESERVICE_M,
            Constants.CAMPAIGN_NAME_PAST_DUE,
            Constants.CAMPAIGN_NAME_PAST_DUE_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR
        });

        List<Campaign> campaigns = new List<Campaign>();
        Campaign campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR));
        campaigns.add(campaign);

        campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR_M));
        campaigns.add(campaign);

        insert campaigns;

        List<CampaignMember> campaignMembers = new list<CampaignMember>();
        CampaignMember campaignMember = new CampaignMember(CampaignId = campaigns[0].Id, ContactId = guarantorContact.Id, Status = Constants.SENT);
        campaignMembers.add(campaignMember);

        campaignMember = new CampaignMember(CampaignId = campaigns[1].Id, ContactId = guarantorContact.Id, Status = Constants.SENT);
        campaignMembers.add(campaignMember);

        insert campaignMembers;

        Set<Id> setId = new Set<Id>();
        setId.add(guarantorContact.Id);

        Case paymentPlanErrorCase = TestUtility.generateCase(RecordTypeUtil.automatedCaseRt, Constants.CASE_TYPE_PAYMENT_PLAN_ERROR, guarantorContact.Id);
        paymentPlanErrorCase.Reason = Constants.CASE_REASON_COMPLIANCE_ISSUE;
        insert paymentPlanErrorCase;

        CaseUtil.createCCErrorCase(setId);
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, Status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert, Only one case is exist for Guarantor which we are created above.
        // No any new auto case create for same guarantor because of thay have "Compliance Issue" case.
        System.assertEquals(1, cases.size());
    }

    //Method to code coverage for createCCErrorCase1
    @isTest
    public static void createCCErrorCaseWithoutComplianceIssue() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = :Case.SObjectType.getDescribe().getName()]) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> campaignMapping = CaseUtil.campaignMapping(new Set<String> {
            Constants.CAMPAIGN_NAME_OVERDUE,
            Constants.CAMPAIGN_NAME_OVERDUE_M,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS_M,
            Constants.CAMPAIGN_NAME_PRESERVICE,
            Constants.CAMPAIGN_NAME_PRESERVICE_M,
            Constants.CAMPAIGN_NAME_PAST_DUE,
            Constants.CAMPAIGN_NAME_PAST_DUE_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR
        });

        List<Campaign> campaigns = new List<Campaign>();
        Campaign campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR));
        campaigns.add(campaign);

        campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR_M));
        campaigns.add(campaign);

        insert campaigns;

        Set<Id> setId = new Set<Id>();
        setId.add(guarantorContact.Id);

        CaseUtil.createCCErrorCase(setId);
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, Status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        System.assertEquals(1, cases.size());
        System.assertEquals(Constants.CASE_STATUS_NEW, cases[0].Status);
    }

    //Method to code coverage for closeCCErrorCase
    @isTest
    public static void closeCCErrorCaseWithPaymentPlan() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Test.startTest();
        Map<String, String> campaignMapping = CaseUtil.campaignMapping(new Set<String> {
            Constants.CAMPAIGN_NAME_OVERDUE,
            Constants.CAMPAIGN_NAME_OVERDUE_M,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS_M,
            Constants.CAMPAIGN_NAME_PRESERVICE,
            Constants.CAMPAIGN_NAME_PRESERVICE_M,
            Constants.CAMPAIGN_NAME_PAST_DUE,
            Constants.CAMPAIGN_NAME_PAST_DUE_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR
        });

        List<Campaign> campaigns = new List<Campaign>();
        Campaign campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR));
        campaigns.add(campaign);

        campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR_M));
        campaigns.add(campaign);

        insert campaigns;

        List<CampaignMember> campaignMembers = new list<CampaignMember>();
        CampaignMember campaignMember = new CampaignMember(CampaignId = campaigns[0].Id, ContactId = guarantorContact.Id, Status = Constants.SENT);
        campaignMembers.add(campaignMember);

        campaignMember = new CampaignMember(CampaignId = campaigns[1].Id, ContactId = guarantorContact.Id, Status = Constants.SENT);
        campaignMembers.add(campaignMember);

        insert campaignMembers;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.id);
        paymentPlan.active__c = true;
        paymentPlan.Delinquent__c = true;
        insert paymentPlan;

        Payment_Plan__c paymentPlan1 = TestUtility.generatePaymentPlan(guarantorContact.id);
        paymentPlan1.active__c = true;
        paymentPlan1.Has_Error__c = true;
        paymentPlan1.Remaining_Balance__c = -101;
        insert paymentPlan1;

        Set<Id> setId = new Set<Id>();
        setId.add(guarantorContact.Id);

        Set<Id> setpaymentPlan = new Set<Id>();
        setpaymentPlan.add(paymentPlan.Id);
        setpaymentPlan.add(paymentPlan1.Id);

        Case paymentPlanErrorCase = TestUtility.generateCase(RecordTypeUtil.automatedCaseRt, Constants.CASE_TYPE_PAYMENT_PLAN_ERROR, guarantorContact.Id);
        insert paymentPlanErrorCase;

        lst = [Select id from CampaignMember where ContactId = :guarantorContact.Id];
        System.assertEquals(2, lst.Size());

        CaseUtil.closePaymentPlanErrorCase(setId, setpaymentPlan);
        Test.stopTest();

        // Retrive CampaignMember record.
        lst = [Select id from CampaignMember where ContactId = :guarantorContact.Id and (CampaignID = :campaigns[0].Id or CampaignID = :campaigns[1].Id)];

        // Check system assert.
        System.assert(lst.isEmpty());
    }

    //Method to code coverage for closeCCErrorCase
    @isTest
    public static void closeCCErrorCaseWithCampaignMember() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = :Case.SObjectType.getDescribe().getName()]) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> campaignMapping = CaseUtil.campaignMapping(new Set<String> {
            Constants.CAMPAIGN_NAME_OVERDUE,
            Constants.CAMPAIGN_NAME_OVERDUE_M,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS,
            Constants.CAMPAIGN_NAME_PRECOLLECTIONS_M,
            Constants.CAMPAIGN_NAME_PRESERVICE,
            Constants.CAMPAIGN_NAME_PRESERVICE_M,
            Constants.CAMPAIGN_NAME_PAST_DUE,
            Constants.CAMPAIGN_NAME_PAST_DUE_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR_M,
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR
        });

        List<Campaign> campaigns = new List<Campaign>();
        Campaign campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR));
        campaigns.add(campaign);

        campaign = TestUtility.generateCampaign(campaignMapping.get(Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR_M));
        campaigns.add(campaign);

        insert campaigns;

        List<CampaignMember> campaignMembers = new list<CampaignMember>();
        CampaignMember campaignMember = new CampaignMember(CampaignId = campaigns[0].Id, ContactId = guarantorContact.Id, Status = Constants.SENT);
        campaignMembers.add(campaignMember);

        campaignMember = new CampaignMember(CampaignId = campaigns[1].Id, ContactId = guarantorContact.Id, Status = Constants.SENT);
        campaignMembers.add(campaignMember);

        insert campaignMembers;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.id);
        paymentPlan.active__c = true;
        paymentPlan.Delinquent__c = true;
        insert paymentPlan;

        Payment_Plan__c paymentPlan1 = TestUtility.generatePaymentPlan(guarantorContact.id);
        paymentPlan1.active__c = true;
        paymentPlan1.Has_Error__c = true;
        paymentPlan1.Remaining_Balance__c = -101;
        insert paymentPlan1;

        Set<Id> setId = new Set<Id>();
        setId.add(guarantorContact.Id);

        Set<Id> setpaymentPlan = new Set<Id>();
        setpaymentPlan.add(paymentPlan.Id);

        lst = [Select id from CampaignMember where ContactId = :guarantorContact.Id];
        System.assertEquals(2, lst.Size());

        CaseUtil.closePaymentPlanErrorCase(setId, setpaymentPlan);
        Test.stopTest();

        // Retrive CampaignMember record.
        lst = [Select id from CampaignMember where ContactId = :guarantorContact.Id and (CampaignID = :campaigns[0].Id or CampaignID = :campaigns[1].Id)];

        // Check system assert.
        System.assertEquals(2, lst.Size());
    }
    
    /**
     * Check all access rights for a read only User using runAs.
     **/
    @isTest
    static void checkAccessRights() {
        List<CaseSecurityContext> allContexts = new List<CaseSecurityContext> {
            CaseSecurityContext.CREATE_CONTEXT,
            CaseSecurityContext.CREATE_WITH_GT_CONTEXT,
            CaseSecurityContext.CU_CREATE_WITH_ENCOUNTER_CONTEXT,
            CaseSecurityContext.UPDATE_CONTEXT,
            CaseSecurityContext.UPSERT_CONTEXT,
            CaseSecurityContext.DELETE_CONTEXT
        };

        System.runAs(TestUtility.generateReadOnlyUser()) {
            for (CaseSecurityContext context: allContexts) {
                try {
                    context.actionAllowed();
                    System.assert(false, 'Expected permission to be denied for ' + context);
                } catch (SecurityUtils.SecurityException ex) {
                    System.debug('SecurityException : ' + ex);
                } catch (Exception e) {
                    System.assert(false, 'Expected SecurityUtils.SecurityException to be thrown, but got ' + e);
                }
            }
        }
    }

    /**
     * Check all Read rights for a Chatter User using runAs.
     **/
    @isTest
    static void checkAccessRightsForRead() {
        List<CaseSecurityContext> allContexts = new List<CaseSecurityContext> {
            CaseSecurityContext.SELECT_CONTEXT,
            CaseSecurityContext.CU_SELECT_CONTEXT
        };

        System.runAs(TestUtility.generateChatterOnlyUser()) {
            for (CaseSecurityContext context: allContexts) {
                try {
                    context.actionAllowed();
                    System.assert(false, 'Expected permission to be denied for ' + context);
                } catch (SecurityUtils.SecurityException ex) {
                    System.debug('SecurityException : ' + ex);
                } catch (Exception e) {
                    System.assert(false, 'Expected SecurityUtils.SecurityException to be thrown, but got ' + e);
                }
            }
        }
    }
}
