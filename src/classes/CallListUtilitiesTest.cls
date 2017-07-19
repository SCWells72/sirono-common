/*
* @author Sirono
* @version 1.0.1
* @Date: 09-14-2016
* @ Unit class  for the CallListUtilities class.
* Do the code coverage for the CallListUtilities class
*/

@isTest
public class CallListUtilitiesTest {

    //TODO: Provide a valid message about what is being asserted on all asserts.
    //TODO: Add inline documentation here about what this assert is verifying

    // Viraj Rana : 09-15-2016: Unit test of preCollectionCallListRemoval method
    @isTest
    Public static void removeCMWithOverdueDelinquentBalance() {
        TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateguarantorContact();
        insert guarantorContact ;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Account_Status__c = Constants.ACCT_STATUS_BILLED;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DUE_BY;
        chargeGroup.Sirono_ID__c = 123;
        insert chargeGroup;

        Transaction__c transactionObj = TestUtility.generateTransaction(chargeGroup, -101, Constants.AUTOMATIC);
        insert transactionObj ;

        Test.startTest();
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Account_Status__c = Constants.ACCT_STATUS_BILLED;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        chargeGroup.Sirono_ID__c = 123444;
        chargeGroup.Pre_Collection_Sent__c = system.today();
        insert chargeGroup;

        transactionObj = TestUtility.generateTransaction(chargeGroup, -500, Constants.AUTOMATIC);
        insert transactionObj ;

        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String> {
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

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get(Constants.CAMPAIGN_NAME_PRECOLLECTIONS));
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get(Constants.CAMPAIGN_NAME_OVERDUE));
        lstCampaign.add(objCampaign);

        insert lstCampaign;

        CampaignMember cmm = new CampaignMember(CampaignId = lstCampaign[0].Id, ContactId = guarantorContact.Id, Status = Constants.SENT);
        insert cmm;

        transactionObj.amount__c = -501;
        update transactionObj;
        update guarantorContact ;
        Test.stopTest();

        // Check system assert.
        List<CampaignMember> campaignMembers = [
            SELECT Id, CampaignId, ContactId, Case_ID__c
            FROM CampaignMember
            WHERE CampaignId = :lstCampaign[0].Id
        ];

        //TODO: Add inline documentation to this test to specify why we are performing the data manipulation and what the expected outcome should be.  If there are other asserts that add values please add them.
        System.assertEquals(campaignMembers[0].ContactId, guarantorContact.Id);
    }

    //Viraj Rana : 09-15-2016: Unit test of preCollectionCallListRemoval method
    @isTest
    Public static void preCollectionCallListRemoval() {
        TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateguarantorContact();
        insert guarantorContact ;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Test.startTest();
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Account_Status__c = Constants.ACCT_STATUS_BILLED;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DUE_BY;
        chargeGroup.Sirono_ID__c = 123;
        insert chargeGroup;

        Transaction__c transactionObj = TestUtility.generateTransaction(chargeGroup, -101, Constants.AUTOMATIC);
        insert transactionObj ;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Account_Status__c = Constants.ACCT_STATUS_BILLED;
        chargeGroup.Sirono_ID__c = 123444;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        insert chargeGroup;

        List<Charge_Group__c> lst = TestUtility.generatechargeGroupList(guarantorContact.Id);
        transactionObj = TestUtility.generateTransaction(chargeGroup, -500, Constants.AUTOMATIC);
        insert transactionObj ;

        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String> {
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

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get(Constants.CAMPAIGN_NAME_PRECOLLECTIONS));
        lstCampaign.add(objCampaign);
        insert lstCampaign;

        CampaignMember cmm = new CampaignMember(CampaignId = lstCampaign[0].Id, ContactId = guarantorContact.Id, Status = Constants.SENT);
        insert cmm;

        transactionObj.amount__c = -501;
        update transactionObj;
        update guarantorContact;
        Test.stopTest();

        // Check system assert.
        List<CampaignMember> campaignMembers = [
            SELECT Id, CampaignId, ContactId, Case_ID__c
            FROM CampaignMember
            WHERE CampaignId = :lstCampaign[0].Id
        ];
        System.assertEquals(campaignMembers.size(), 0);
    }

    //Viraj Rana : 09-15-2016: Unit test of preCollectionCallListRemoval method
    @isTest
    Public static void earlyOutCallListRemovalWithoutCG() {
        TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateguarantorContact();
        insert guarantorContact ;

        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String> {
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

        Test.startTest();
        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get(Constants.CAMPAIGN_NAME_OVERDUE));
        lstCampaign.add(objCampaign);
        insert lstCampaign;

        CampaignMember cmm = new CampaignMember(CampaignId = lstCampaign[0].Id, ContactId = guarantorContact.Id, Status = Constants.SENT);
        insert cmm;

        update guarantorContact;
        Test.stopTest();

        // Check system assert. Don't remove campaign member because of we do not insert charge group.
        List<CampaignMember> campaignMembers = [
            SELECT Id, CampaignId, ContactId, Case_ID__c
            FROM CampaignMember
            WHERE CampaignId = :lstCampaign[0].Id
        ];
        //TODO: verify the found campaign member is the expect object.
        System.assertEquals(campaignMembers.size(), 1);
    }

    //Viraj Rana : 09-15-2016: Unit test of preCollectionCallListRemoval method
    @isTest
    public static void delinquentCaseWithoutCG() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Test.startTest();
        Case objCase = TestUtility.generateCase(RecordTypeUtil.automatedCaseRt, Constants.CASE_TYPE_OVERDUE, guarantorContact.Id);
        objCase.Type = Constants.CASE_TYPE_PAST_DUE_PAYMENT_PLANS;
        insert objCase;

        objCase.Status = Constants.CASE_STATUS_CLOSED;
        Update objCase;
        Test.stopTest();

        // Check system assert.
        List<Case> cases = [
            SELECT Id, Reason, Guarantor_Information__c
            FROM Case
            WHERE Guarantor_Information__c = :guarantorContact.Id
        ];

        //TODO: verify the case is the expected object and that it has been updated appropriately
        System.assertEquals(cases.size(), 1);
    }

    //Viraj Rana : 09-15-2016: Unit test of preCollectionCallListRemoval method
    @isTest
    public static void preCollectionCaseWithoutCG() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Test.startTest();
        Case objCase = TestUtility.generateCase(RecordTypeUtil.automatedCaseRt, Constants.CASE_TYPE_PRECOLLECTIONS, guarantorContact.Id);
        objCase.Type = Constants.CASE_TYPE_PRECOLLECTIONS;
        insert objCase;

        objCase.Status = Constants.CASE_STATUS_CLOSED;
        Update objCase;
        Test.stopTest();

        // Check system assert.
        List<Case> cases = [
            SELECT Id, Status, Guarantor_Information__c
            FROM Case
            WHERE Guarantor_Information__c = :guarantorContact.Id
        ];

        System.assertEquals(Constants.CASE_STATUS_CLOSED, cases[0].Status);
    }

    //Viraj Rana : 09-15-2016: Unit test of preCollectionCallListRemoval method
    @isTest
    public static void earlyOutCaseUpdate() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Test.startTest();
        Case objCase = TestUtility.generateCase(RecordTypeUtil.automatedCaseRt, Constants.CASE_TYPE_OVERDUE, guarantorContact.Id);
        insert objCase;

        objCase.Status = Constants.CASE_STATUS_CLOSED;
        Update objCase;
        Test.stopTest();

        // Check system assert.
        List<Case> cases = [
            SELECT Id, Reason, Guarantor_Information__c
            FROM Case
            WHERE Guarantor_Information__c = :guarantorContact.Id
        ];

        //TODO: verify the case is the expected object and that it has been updated appropriately
        System.assertEquals(cases.size(), 1);
    }

    //Viraj Rana : 09-15-2016: Unit test of preCollectionCallListRemoval method
    @isTest
    public static void ccErrorCaseUpdate() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Test.startTest();
        Case objCase = TestUtility.generateCase(RecordTypeUtil.automatedCaseRt, Constants.CASE_TYPE_PAYMENT_PLAN_ERROR, guarantorContact.Id);
        insert objCase;

        objCase.Status = Constants.CASE_STATUS_CLOSED;
        Update objCase;
        Test.stopTest();

        // Check system assert.
        List<Case> cases = [
            SELECT Id, Status, Guarantor_Information__c
            FROM Case
            WHERE Guarantor_Information__c = :guarantorContact.Id
        ];
        System.assertEquals(Constants.CASE_STATUS_CLOSED, cases[0].Status);
    }

    //Viraj Rana : 09-15-2016: Unit test of preCollectionCallListRemoval method
    @isTest
    public static void encounterCaseUpdate() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Test.startTest();
        Case objCase = TestUtility.generateCase(RecordTypeUtil.automatedCaseRt, Constants.CASE_TYPE_ENCOUNTER, guarantorContact.Id);
        insert objCase;

        objCase.Status = Constants.CASE_STATUS_CLOSED;
        Update objCase;
        Test.stopTest();

        // Check system assert.
        List<Case> cases = [
            SELECT Id, Status, Guarantor_Information__c
            FROM Case
            WHERE Guarantor_Information__c = :guarantorContact.Id
        ];
        System.assertEquals(Constants.CASE_STATUS_CLOSED, cases[0].Status);
    }

    //Viraj Rana : 09-15-2016: Unit test of caseEarlyOutClose method
    @isTest
    public static void checkContactOverdueBalance() {
        TestUtility objUtility = new TestUtility();
        CaseUtil obj = new CaseUtil();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 121343);
        insert chargeGroup;

        Test.startTest();
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 12134323);
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        chargeGroup.Account_Status__c = Constants.ACCT_STATUS_BILLED;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, Constants.SERVICE);
        insert objTransaction;

        objTransaction.Amount__c = 1000;
        update objTransaction;
        Test.stopTest();

        // Check system assert.
        List<Contact> Contacts = [
            SELECT Id, Overdue_Balance__c
            FROM Contact
            WHERE Id = :guarantorContact.Id
        ];
        System.assertEquals(Contacts[0].Overdue_Balance__c, 1000);
    }

    //Viraj Rana : 09-15-2016: Unit test of caseEarlyOutClose method
    @isTest
    public static void checkContactDelinquentBalance() {
        TestUtility objUtility = new TestUtility();
        CaseUtil obj = new CaseUtil();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 121343);
        insert chargeGroup;

        Test.startTest();
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 12134323);
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        chargeGroup.Account_Status__c = Constants.ACCT_STATUS_BILLED;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, Constants.SERVICE);
        insert objTransaction;

        objTransaction.Amount__c = 1000;
        update objTransaction;
        Test.stopTest();

        // Check system assert.
        List<Contact> Contacts = [
            SELECT Id, Delinquent_Balance__c
            FROM Contact
            WHERE Id = :guarantorContact.Id
        ];
        System.assertEquals(Contacts[0].Delinquent_Balance__c, 1000);
    }
}
