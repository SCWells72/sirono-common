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
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DUE_BY;
        chargeGroup.Sirono_ID__c = 123;
        insert chargeGroup;

        Transaction__c transactionObj = TestUtility.generateTransaction(chargeGroup, -101, 'Automatic');
        insert transactionObj ;

        Test.startTest();
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        chargeGroup.Sirono_ID__c = 123444;
        chargeGroup.Pre_Collection_Sent__c = system.today();
        insert chargeGroup;

        transactionObj = TestUtility.generateTransaction(chargeGroup, -500, 'Automatic');
        insert transactionObj ;

        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                Constants.CAMPAIGN_NAME_OVERDUE, Constants.CAMPAIGN_NAME_OVERDUE_M, 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', Constants.CAMPAIGN_NAME_PAST_DUE, Constants.CAMPAIGN_NAME_PAST_DUE_M, 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('PreCollections'));
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get(Constants.CAMPAIGN_NAME_OVERDUE));
        lstCampaign.add(objCampaign);

        insert lstCampaign;

        CampaignMember cmm = new CampaignMember(CampaignId = lstCampaign[0].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        insert cmm;

        transactionObj.amount__c = -501;
        update transactionObj;
        update guarantorContact ;
        Test.stopTest();

        // Check system assert.
        List<CampaignMember> campaignMembers = [SELECT Id, CampaignId, ContactId, Case_ID__c FROM CampaignMember
                WHERE CampaignId = :lstCampaign[0].Id];

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
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DUE_BY;
        chargeGroup.Sirono_ID__c = 123;
        insert chargeGroup;

        Transaction__c transactionObj = TestUtility.generateTransaction(chargeGroup, -101, 'Automatic');
        insert transactionObj ;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Sirono_ID__c = 123444;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        insert chargeGroup;

        List<Charge_Group__c> lst = TestUtility.generatechargeGroupList(guarantorContact.Id);
        transactionObj = TestUtility.generateTransaction(chargeGroup, -500, 'Automatic');
        insert transactionObj ;

        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                Constants.CAMPAIGN_NAME_OVERDUE, Constants.CAMPAIGN_NAME_OVERDUE_M, 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', Constants.CAMPAIGN_NAME_PAST_DUE, Constants.CAMPAIGN_NAME_PAST_DUE_M, 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('PreCollections'));
        lstCampaign.add(objCampaign);
        insert lstCampaign;

        CampaignMember cmm = new CampaignMember(CampaignId = lstCampaign[0].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        insert cmm;

        transactionObj.amount__c = -501;
        update transactionObj;
        update guarantorContact;
        Test.stopTest();

        // Check system assert.
        List<CampaignMember> campaignMembers = [SELECT Id, CampaignId, ContactId, Case_ID__c FROM CampaignMember
                WHERE CampaignId = :lstCampaign[0].Id];
        System.assertEquals(campaignMembers.size(), 0);
    }

    //Viraj Rana : 09-15-2016: Unit test of preCollectionCallListRemoval method
    @isTest
    Public static void earlyOutCallListRemovalWithoutCG() {
        TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateguarantorContact();
        insert guarantorContact ;

        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                Constants.CAMPAIGN_NAME_OVERDUE, Constants.CAMPAIGN_NAME_OVERDUE_M, 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', Constants.CAMPAIGN_NAME_PAST_DUE, Constants.CAMPAIGN_NAME_PAST_DUE_M, 'CC Error M', 'CC Error'
        });

        Test.startTest();
        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get(Constants.CAMPAIGN_NAME_OVERDUE));
        lstCampaign.add(objCampaign);
        insert lstCampaign;

        CampaignMember cmm = new CampaignMember(CampaignId = lstCampaign[0].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        insert cmm;

        update guarantorContact;
        Test.stopTest();

        // Check system assert. Don't remove campaign member because of we do not insert charge group.
        List<CampaignMember> campaignMembers = [SELECT Id, CampaignId, ContactId, Case_ID__c FROM CampaignMember
                WHERE CampaignId = :lstCampaign[0].Id];
        //TODO: verify the found campaign member is the expect object.
        System.assertEquals(campaignMembers.size(), 1);
    }

    //Viraj Rana : 09-15-2016: Unit test of preCollectionCallListRemoval method
    @isTest
    public static void delinquentCaseWithoutCG() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }
        Test.startTest();
        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), Constants.CASE_TYPE_OVERDUE, guarantorContact.Id);
        objCase.Type = Constants.CASE_TYPE_PAST_DUE_PAYMENT_PLANS;
        insert objCase;

        objCase.Status = 'Closed';
        Update objCase;
        Test.stopTest();

        // Check system assert.
        List<Case> cases = [SELECT Id, Reason, Guarantor_Information__c FROM Case
                WHERE Guarantor_Information__c = :guarantorContact.Id];

        //TODO: verify the case is the expected object and that it has been updated appropriately
        System.assertEquals(cases.size(), 1);
    }

    //Viraj Rana : 09-15-2016: Unit test of preCollectionCallListRemoval method
    @isTest
    public static void preCollectionCaseWithoutCG() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }
        Test.startTest();
        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Precollections', guarantorContact.Id);
        objCase.Type = 'Precollections';
        insert objCase;

        objCase.Status = 'Closed';
        Update objCase;
        Test.stopTest();

        // Check system assert.
        List<Case> cases = [SELECT Id, Status, Guarantor_Information__c FROM Case
                WHERE Guarantor_Information__c = :guarantorContact.Id];

        System.assertEquals(cases[0].Status, 'Closed');
    }

    //Viraj Rana : 09-15-2016: Unit test of preCollectionCallListRemoval method
    @isTest
    public static void earlyOutCaseUpdate() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }
        Test.startTest();
        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), Constants.CASE_TYPE_OVERDUE, guarantorContact.Id);
        insert objCase;

        objCase.Status = 'Closed';
        Update objCase;
        Test.stopTest();

        // Check system assert.
        List<Case> cases = [SELECT Id, Reason, Guarantor_Information__c FROM Case
                WHERE Guarantor_Information__c = :guarantorContact.Id];

        //TODO: verify the case is the expected object and that it has been updated appropriately
        System.assertEquals(cases.size(), 1);
    }

    //Viraj Rana : 09-15-2016: Unit test of preCollectionCallListRemoval method
    @isTest
    public static void ccErrorCaseUpdate() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }
        Test.startTest();
        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'CC Error', guarantorContact.Id);
        insert objCase;

        objCase.Status = 'Closed';
        Update objCase;
        Test.stopTest();

        // Check system assert.
        List<Case> cases = [SELECT Id, Status, Guarantor_Information__c FROM Case
                WHERE Guarantor_Information__c = :guarantorContact.Id];
        System.assertEquals(cases[0].Status, 'Closed');
    }

    //Viraj Rana : 09-15-2016: Unit test of preCollectionCallListRemoval method
    @isTest
    public static void encounterCaseUpdate() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }
        Test.startTest();
        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Encounter', guarantorContact.Id);
        insert objCase;

        objCase.Status = 'Closed';
        Update objCase;
        Test.stopTest();

        // Check system assert.
        List<Case> cases = [SELECT Id, Status, Guarantor_Information__c FROM Case
                WHERE Guarantor_Information__c = :guarantorContact.Id];
        System.assertEquals(cases[0].Status, 'Closed');
    }

    //Viraj Rana : 09-15-2016: Unit test of preCollectionCallListRemoval method
    @isTest
    public static void checkAndDoAddNoteCallout() {
        TestUtility objUtility = new TestUtility();

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'standt', Email = 'systemuser@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'systemuser@testorg1212.com');

        System.runAs(u) {
            Contact guarantorContact = TestUtility.generateGuarantorContact();
            insert guarantorContact;

            Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
            for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
                caseRecordTypeMap.put(recordType.Name, recordType.Id);
            }
            Test.startTest();
            Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Internal Case'), Constants.CASE_TYPE_OVERDUE, guarantorContact.Id);
            objCase.Type = Constants.CASE_TYPE_PAST_DUE_PAYMENT_PLANS;
            objCase.Description = Constants.CASE_TYPE_PAST_DUE_PAYMENT_PLANS;
            objCase.Charge_Group_IDs__c = '121';
            insert objCase;
            Test.stopTest();

            // Check system assert.
            List<Case> cases = [SELECT Id, Type, Guarantor_Information__c FROM Case
                WHERE Id = :objCase.Id];
            //TODO: verify the case is the expected object and that it has been updated appropriately
            System.assertEquals(cases.size(), 1);
        }
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
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, 'Service');
        insert objTransaction;

        objTransaction.Amount__c = 1000;
        update objTransaction;
        Test.stopTest();

        // Check system assert.
        List<Contact> Contacts = [SELECT Id, Overdue_Balance__c FROM Contact
            WHERE Id = :guarantorContact.Id];
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
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, 'Service');
        insert objTransaction;

        objTransaction.Amount__c = 1000;
        update objTransaction;
        Test.stopTest();

        // Check system assert.
        List<Contact> Contacts = [SELECT Id, Delinquent_Balance__c FROM Contact
            WHERE Id = :guarantorContact.Id];
        System.assertEquals(Contacts[0].Delinquent_Balance__c, 1000);
    }
}
