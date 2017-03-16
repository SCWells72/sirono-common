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
    Public Static List<CampaignMember> lst ;
    //Method to code coverage for Create Early Out Case, And Close the Early Out case
    @isTest
    public static void checkCallEarlyOutAutoCase() {
        TestUtility objUtility = new TestUtility();
        CaseUtil obj = new CaseUtil();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 121343);
        insert chargeGroup;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 12134323);
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        insert chargeGroup;

        //10-19-2016: Viraj - Tracker # 132105543-Change "Overdue_Balance__c = '< 0' to '> 0'" in condition.
        //Change transaction amount -100 to 100.
        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Service');
        insert objTransaction;

        List<Statement__c> lstStatement = new List<Statement__c>();
        Statement__c statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);


        statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);
        insert lstStatement;

        Test.startTest();
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Early-out', 'Early-out M', 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', 'Delinquent', 'Delinquent M', 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('Early-out'));
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('Early-out M'));
        lstCampaign.add(objCampaign);

        insert lstCampaign;

        List<CampaignMember> lstCamp = new list<CampaignMember>();
        CampaignMember cmm = new CampaignMember(CampaignId = lstCampaign[0].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        cmm = new CampaignMember(CampaignId = lstCampaign[1].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        insert lstCamp;

        //Test coverage for Auto case to manually closing the case [CaseTriggerHandler.removeCampaignMembers method]
        CaseUtil.ExecuteRemoveCampaignTrigger = true;
        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Early Out', guarantorContact.Id);
        objCase.Reason = 'Compliance Issue';
        insert objCase;

        CaseUtil.callEarlyOutAutoCase();
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, Type, status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert, Number of auto created case records.
        System.assertEquals(1, cases.size());
        System.assertEquals('Early Out', cases[0].Type);
    }

    //Method to code coverage for Create Early Out Case, And Close the Early Out case
    @isTest
    public static void callEarlyOutAutoCaseWithoutComplianIssue() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 121343);
        insert chargeGroup;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 12134323);
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        insert chargeGroup;

        //10-19-2016: Viraj - Tracker # 132105543-Change "Overdue_Balance__c = '< 0' to '> 0'" in condition.
        //Change transaction amount -100 to 100.
        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Service');
        insert objTransaction;

        List<Statement__c> lstStatement = new List<Statement__c>();
        Statement__c statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);


        statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);
        insert lstStatement;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Early-out', 'Early-out M', 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', 'Delinquent', 'Delinquent M', 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('Early-out'));
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('Early-out M'));
        lstCampaign.add(objCampaign);

        insert lstCampaign;

        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Early Out', guarantorContact.Id);
        objCase.Type = 'Early Out';
        insert objCase;

        CaseUtil.callEarlyOutAutoCase();
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, Reason, status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        //TODO: verify number of cases returned
        // Check system assert, Case is closed automatically.
        System.assertEquals('Closed - Automated', cases[0].Reason);
    }

    // 12-02-2016 Viraj Rana: #133707065: Case to Call Activiy
    // Increse Code Coverage.
    @isTest
    public static void assignCampaignMemberCaseIdWithEarlyOut() {
        TestUtility objUtility = new TestUtility();
        CaseUtil obj = new CaseUtil();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id,patientContact.id,121343);
        insert chargeGroup;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id,patientContact.id,12134323);
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c= 'Overdue';
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Service');
        insert objTransaction;

        List<Statement__c> lstStatement = new List<Statement__c>();
        Statement__c statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);


        statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);
        insert lstStatement;

        Test.startTest();
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Early-out', 'Early-out M', 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', 'Delinquent', 'Delinquent M', 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('Early-out'));
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('Early-out M'));
        lstCampaign.add(objCampaign);

        insert lstCampaign;

        List<CampaignMember> lstCamp = new list<CampaignMember>();
        CampaignMember cmm = new CampaignMember(CampaignId = lstCampaign[0].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        cmm = new CampaignMember(CampaignId = lstCampaign[1].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        insert lstCamp;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Early Out', guarantorContact.Id);
        objCase.Reason = 'Early Out';
        insert objCase;

        //Check System assert "Case_ID__c = null before calling callEarlyOutAutoCase() method".
        System.assertEquals(lstCamp[0].Case_ID__c, null);

        CaseUtil.callEarlyOutAutoCase();
        Test.stopTest();

        // Check System assert "Case_ID__c != null after calling callEarlyOutAutoCase() method".
        // Case Id assign into the Campaign Member.
        List<CampaignMember> lstCM = [SELECT Id, CampaignId, ContactId, Case_ID__c FROM CampaignMember where Id =: lstCamp[0].Id];
        System.assertNotEquals(lstCM[0].Case_ID__c, null);
    }

    //Method to code coverage for callEarlyOutAutoCaseCloser
    @isTest
    public static void callEarlyOutAutoCaseCloser() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 121343);
        insert chargeGroup;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 12134323);
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, 'Service');
        insert objTransaction;

        List<Statement__c> lstStatement = new List<Statement__c>();
        Statement__c statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);


        statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);
        insert lstStatement;

        Test.startTest();
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Early-out', 'Early-out M', 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', 'Delinquent', 'Delinquent M', 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('Early-out'));
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('Early-out M'));
        lstCampaign.add(objCampaign);

        insert lstCampaign;

        List<CampaignMember> lstCamp = new list<CampaignMember>();
        CampaignMember cmm = new CampaignMember(CampaignId = lstCampaign[0].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        cmm = new CampaignMember(CampaignId = lstCampaign[1].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        insert lstCamp;

        //Test coverage for Auto case to manually closing the case [CaseTriggerHandler.removeCampaignMembers method]
        CaseUtil.ExecuteRemoveCampaignTrigger = true;
        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Early Out', guarantorContact.Id);
        objCase.Reason = 'Compliance Issue';
        insert objCase;

        CaseUtil.callEarlyOutAutoCaseCloser();
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert.
        System.assertEquals(1, cases.size());
        System.assertEquals('Closed', cases[0].status);
    }

    //Method to code coverage for callCloseEarlyOutAutoCase
    @isTest
    public static void closeEarlyOutAutoCase() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 121343);
        insert chargeGroup;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 12134323);
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c =Constants.ACCT_SUBSTATUS_OVERDUE;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, 'Service');
        insert objTransaction;

        List<Statement__c> lstStatement = new List<Statement__c>();
        Statement__c statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);


        statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);
        insert lstStatement;

        Test.startTest();
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Early-out', 'Early-out M', 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', 'Delinquent', 'Delinquent M', 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('Early-out'));
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('Early-out M'));
        lstCampaign.add(objCampaign);

        insert lstCampaign;

        List<CampaignMember> lstCamp = new list<CampaignMember>();
        CampaignMember cmm = new CampaignMember(CampaignId = lstCampaign[0].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        cmm = new CampaignMember(CampaignId = lstCampaign[1].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        insert lstCamp;

        //Test coverage for Auto case to manually closing the case [CaseTriggerHandler.removeCampaignMembers method]
        CaseUtil.ExecuteRemoveCampaignTrigger = true;
        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Early Out', guarantorContact.Id);
        objCase.Reason = 'Compliance Issue';
        insert objCase;

        CaseUtil.callCloseEarlyOutAutoCase(lstStatement);
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert.
        System.assertEquals(1, cases.size());
        System.assertEquals('Closed', cases[0].status);
    }


    //Method to code coverage for callPrecollectionsAutoCase
    @isTest
    public static void preCollCaseWithoutDelinquentBalance() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 121343);
        insert chargeGroup;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 12134323);
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        insert chargeGroup;

        //10-19-2016: Viraj - Tracker # 132105543-Change "Delinquent_Balance__c = '< 0' to '> 0'" in condition.
        //Change transaction amount -100 to 100.
        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Service');
        insert objTransaction;

        Test.startTest();
        List<Statement__c> lstStatement = new List<Statement__c>();
        Statement__c statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);


        statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);
        insert lstStatement;

        CaseUtil.callPrecollectionsAutoCase();
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert, to see no case records get created.
        System.assert(cases.isEmpty());
    }

    //Method to code coverage for createPrecollectionsAutoCase
    @isTest
    public static void preCollCaseWithExistingPreCollCase() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 121343);
        insert chargeGroup;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 12134323);
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        insert chargeGroup;

        // 10-19-2016: Viraj - Tracker # 132105543-Change "Delinquent_Balance__c = '< 0' to '> 0'" in condition.
        // Change transaction amount -100 to 100.
        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Service');
        insert objTransaction;

        List<Statement__c> lstStatement = new List<Statement__c>();
        Statement__c statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);

        statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);
        insert lstStatement;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Early-out', 'Early-out M', 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', 'Delinquent', 'Delinquent M', 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('PreCollections'));
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('PreCollections M'));
        lstCampaign.add(objCampaign);

        insert lstCampaign;

        List<CampaignMember> lstCamp = new list<CampaignMember>();
        CampaignMember cmm = new CampaignMember(CampaignId = lstCampaign[0].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        cmm = new CampaignMember(CampaignId = lstCampaign[1].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        insert lstCamp;

        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Early Out', guarantorContact.Id);
        objCase.Type = 'Precollections';
        insert objCase;

        CaseUtil.createPrecollectionsAutoCase(lstStatement);
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert, existing Case is closed and another record created with Status = 'New'.
        System.assertEquals('Closed', cases[0].Status);
        System.assertEquals('New', cases[1].Status);
    }

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
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        insert chargeGroup;

        //10-19-2016: Viraj - Tracker # 132105543-Change "Delinquent_Balance__c = '< 0' to '> 0'" in condition.
        //Change transaction amount -100 to 100.
        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Service');
        insert objTransaction;

        List<Statement__c> lstStatement = new List<Statement__c>();
        Statement__c statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);


        statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);
        insert lstStatement;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Early-out', 'Early-out M', 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', 'Delinquent', 'Delinquent M', 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('PreCollections'));
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('PreCollections M'));
        lstCampaign.add(objCampaign);

        insert lstCampaign;

        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Early Out', guarantorContact.Id);
        objCase.Type = 'Precollections';
        objCase.Reason = 'Compliance Issue';
        insert objCase;

        CaseUtil.createPrecollectionsAutoCase(lstStatement);
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert, Case record is not created because of Compliance Issue.
        System.assertEquals(1, cases.size());
    }


    //Method to code coverage for createPrecollectionsAutoCase
    @isTest
    public static void preCollCaseCloseExisting() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 121343);
        insert chargeGroup;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 12134323);
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        insert chargeGroup;

        //10-19-2016: Viraj - Tracker # 132105543-Change "Delinquent_Balance__c = '< 0' to '> 0'" in condition.
        //Change transaction amount -100 to 100.
        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Service');
        insert objTransaction;

        List<Statement__c> lstStatement = new List<Statement__c>();
        Statement__c statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);


        statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);
        insert lstStatement;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Early-out', 'Early-out M', 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', 'Delinquent', 'Delinquent M', 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('PreCollections'));
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('PreCollections M'));
        lstCampaign.add(objCampaign);

        insert lstCampaign;

        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Early Out', guarantorContact.Id);
        objCase.Type = 'Precollections';
        insert objCase;

        CaseUtil.createPrecollectionsAutoCase(lstStatement);
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert.
        System.assertEquals(cases[0].status, 'Closed');
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
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, 'Service');
        insert objTransaction;

        Test.startTest();
        List<Statement__c> lstStatement = new List<Statement__c>();
        Statement__c statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);


        statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);
        insert lstStatement;

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
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, 'Service');
        insert objTransaction;

        List<Statement__c> lstStatement = new List<Statement__c>();
        Statement__c statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);


        statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);
        insert lstStatement;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Early-out', 'Early-out M', 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', 'Delinquent', 'Delinquent M', 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('PreCollections'));
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('PreCollections M'));
        lstCampaign.add(objCampaign);

        insert lstCampaign;

        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Early Out', guarantorContact.Id);
        objCase.Type = 'Precollections';
        insert objCase;

        // Retrive Case record.
        List<Case> cases = [SELECT Id, Reason, status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];
        // Check system assert, case reason is not populated before call method.
        System.assertEquals(null, cases[0].Reason);

        CaseUtil.callClosePrecollectionsAutoCase(lstStatement);
        Test.stopTest();

        // Retrive Case record.
        List<Case> caseAfterCall = [SELECT Id, Reason, status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert, case reason is populated after call method.
        System.assertEquals('Closed - Automated', caseAfterCall[0].Reason);
        System.assertEquals('Closed', caseAfterCall[0].status);
    }

    // Method to code coverage for pre collection auto case.
    @isTest
    public static void preCollCaseWithNegativeBalance() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 121343);
        insert chargeGroup;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.id, 12134323);
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, 'Service');
        insert objTransaction;

        Test.startTest();
        List<Statement__c> lstStatement = new List<Statement__c>();
        Statement__c statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);


        statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);
        insert lstStatement;

        CaseUtil.callPrecollectionsAutoCase();
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, Reason, status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert, No case record is created because of charge group balance is not delinquent.
        System.assert(cases.isEmpty());
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
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, 'Service');
        insert objTransaction;

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

        Payment_Arrangement__c paymentArrangement = TestUtility.generatePaymentArrangement(encounter2.Id);
        insert paymentArrangement;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Early-out', 'Early-out M', 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', 'Delinquent', 'Delinquent M', 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('PreService'));
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('PreService M'));
        lstCampaign.add(objCampaign);

        insert lstCampaign;

        List<CampaignMember> lstCamp = new list<CampaignMember>();
        CampaignMember cmm = new CampaignMember(CampaignId = lstCampaign[0].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        cmm = new CampaignMember(CampaignId = lstCampaign[1].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        insert lstCamp;

        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Early Out', guarantorContact.Id);
        objCase.Type = 'PreService';
        objCase.Reason = 'Compliance Issue';
        insert objCase;

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
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, 'Service');
        insert objTransaction;

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

        Payment_Arrangement__c paymentArrangement = TestUtility.generatePaymentArrangement(encounter2.Id);
        insert paymentArrangement;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Early-out', 'Early-out M', 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', 'Delinquent', 'Delinquent M', 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('PreService'));
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('PreService M'));
        lstCampaign.add(objCampaign);

        insert lstCampaign;

        CaseUtil.createEncounterAutoCase(lstEncounter);
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, status, Type FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert, new case created with Encounter record type.
        System.assertEquals('Encounter', cases[1].Type);
    }

    // 12-02-2016 Viraj Rana: #133707065: Case to Call Activiy
    // Increse Code Coverage.
    @isTest
    public static void encounterAutoCaseWithCampaignMemberCaseId() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id,patientContact.id,121343);
        insert chargeGroup;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id,patientContact.id,12134323);
        chargeGroup.Reported_Selfpay_Balance__c = -10;
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c= 'Delinquent';
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, 'Service');
        insert objTransaction;

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

        Payment_Arrangement__c paymentArrangement = TestUtility.generatePaymentArrangement(encounter2.Id);
        insert paymentArrangement;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Early-out', 'Early-out M', 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', 'Delinquent', 'Delinquent M', 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('PreService'));
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('PreService M'));
        lstCampaign.add(objCampaign);

        insert lstCampaign;

        List<CampaignMember> lstCamp = new list<CampaignMember>();
        CampaignMember cmm = new CampaignMember(CampaignId = lstCampaign[0].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        cmm = new CampaignMember(CampaignId = lstCampaign[1].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        insert lstCamp;

        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Early Out', guarantorContact.Id);
        objCase.Type = 'PreService';
        insert objCase;

        //Check System assert "Case_ID__c = null before calling createEncounterAutoCase() method".
        System.assertEquals(lstCamp[0].Case_ID__c, null);

        CaseUtil.createEncounterAutoCase(lstEncounter);
        Test.stopTest();

        //Check System assert "Case_ID__c != null after calling createEncounterAutoCase() method".
        //Case Id assign into the Campaign Member.
        List<CampaignMember> lstCM = [SELECT Id, CampaignId, ContactId, Case_ID__c FROM CampaignMember where Id =: lstCamp[0].Id];
        System.assertNotEquals(lstCM[0].Case_ID__c, null);
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
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, 'Service');
        insert objTransaction;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Early-out', 'Early-out M', 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', 'Delinquent', 'Delinquent M', 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('Delinquent'));
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('Delinquent M'));
        lstCampaign.add(objCampaign);

        insert lstCampaign;

        Set<Id> setId = new Set<Id>();
        setId.add(guarantorContact.Id);
        CaseUtil.createDelinquentPaymentCase(setId);
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, Type, status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert, new case record created with type.
        System.assertEquals(1, cases.size());
        System.assertEquals('Delinquent Payment Plans', cases[0].Type);
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
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, 'Service');
        insert objTransaction;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Early-out', 'Early-out M', 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', 'Delinquent', 'Delinquent M', 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('Delinquent'));
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('Delinquent M'));
        lstCampaign.add(objCampaign);

        insert lstCampaign;

        List<CampaignMember> lstCamp = new list<CampaignMember>();
        CampaignMember cmm = new CampaignMember(CampaignId = lstCampaign[0].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        cmm = new CampaignMember(CampaignId = lstCampaign[1].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        insert lstCamp;

        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Delinquent Payment Plans', guarantorContact.Id);
        objCase.Reason = 'Compliance Issue';
        insert objCase;

        Set<Id> setId = new Set<Id>();
        setId.add(guarantorContact.Id);
        CaseUtil.createDelinquentPaymentCase(setId);
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, Type, status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert, New case record created with Type.
        System.assertEquals(1, cases.size());
        System.assertEquals('Delinquent Payment Plans', cases[0].Type);
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
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, 'Service');
        insert objTransaction;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Early-out', 'Early-out M', 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', 'Delinquent', 'Delinquent M', 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('Delinquent'));
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('Delinquent M'));
        lstCampaign.add(objCampaign);

        insert lstCampaign;

        List<CampaignMember> lstCamp = new list<CampaignMember>();
        CampaignMember cmm = new CampaignMember(CampaignId = lstCampaign[0].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        cmm = new CampaignMember(CampaignId = lstCampaign[1].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        insert lstCamp;

        Set<Id> setId = new Set<Id>();
        setId.add(guarantorContact.Id);
        CaseUtil.createDelinquentPaymentCase(setId);
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert, Delinquent Payment Case create or not.
        System.assertEquals(1, cases.size());
        System.assertEquals('New', cases[0].status);
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
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, 'Service');
        insert objTransaction;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Early-out', 'Early-out M', 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', 'Delinquent', 'Delinquent M', 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('Delinquent'));
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('Delinquent M'));
        lstCampaign.add(objCampaign);

        insert lstCampaign;

        List<CampaignMember> lstCamp = new list<CampaignMember>();
        CampaignMember cmm = new CampaignMember(CampaignId = lstCampaign[0].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        cmm = new CampaignMember(CampaignId = lstCampaign[1].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        insert lstCamp;

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
        List<Case> cases = [SELECT Id, status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert.
        System.assertEquals(1, cases.size());
        System.assertEquals('New', cases[0].status);
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
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, 'Service');
        insert objTransaction;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Early-out', 'Early-out M', 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', 'Delinquent', 'Delinquent M', 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('Delinquent'));
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('Delinquent M'));
        lstCampaign.add(objCampaign);

        insert lstCampaign;

        List<CampaignMember> lstCamp = new list<CampaignMember>();
        CampaignMember cmm = new CampaignMember(CampaignId = lstCampaign[0].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        cmm = new CampaignMember(CampaignId = lstCampaign[1].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        insert lstCamp;

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
        List<Case> cases = [SELECT Id, status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert, case is closed.
        System.assertEquals('Closed', cases[0].status);
    }


    //Method to code coverage for createCCErrorCase
    @isTest
    public static void createCCErrorCase() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Early-out', 'Early-out M', 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', 'Delinquent', 'Delinquent M', 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('CC Error'));
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('CC Error M'));
        lstCampaign.add(objCampaign);

        insert lstCampaign;

        List<CampaignMember> lstCamp = new list<CampaignMember>();
        CampaignMember cmm = new CampaignMember(CampaignId = lstCampaign[0].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        cmm = new CampaignMember(CampaignId = lstCampaign[1].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        insert lstCamp;

        Set<Id> setId = new Set<Id>();
        setId.add(guarantorContact.Id);

        CaseUtil.createCCErrorCase(setId);
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id AND Type = 'CC Error'];

        // Check system assert, New case record gets created.
        System.assertEquals(1, cases.size());
        System.assertEquals('New', cases[0].status);
    }

    //Method to code coverage for createCCErrorCase1
    @isTest
    public static void createCCErrorCaseWithComplianceIssue() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Early-out', 'Early-out M', 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', 'Delinquent', 'Delinquent M', 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('CC Error'));
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('CC Error M'));
        lstCampaign.add(objCampaign);

        insert lstCampaign;

        List<CampaignMember> lstCamp = new list<CampaignMember>();
        CampaignMember cmm = new CampaignMember(CampaignId = lstCampaign[0].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        cmm = new CampaignMember(CampaignId = lstCampaign[1].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        insert lstCamp;

        Set<Id> setId = new Set<Id>();
        setId.add(guarantorContact.Id);

        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'CC Error', guarantorContact.Id);
        objCase.Reason = 'Compliance Issue';
        insert objCase;

        CaseUtil.createCCErrorCase(setId);
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

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
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Early-out', 'Early-out M', 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', 'Delinquent', 'Delinquent M', 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('CC Error'));
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('CC Error M'));
        lstCampaign.add(objCampaign);

        insert lstCampaign;

        Set<Id> setId = new Set<Id>();
        setId.add(guarantorContact.Id);

        CaseUtil.createCCErrorCase(setId);
        Test.stopTest();

        // Retrive Case record.
        List<Case> cases = [SELECT Id, status FROM Case WHERE Guarantor_Information__c = :guarantorContact.Id];

        // Check system assert, case record gets created with status = 'New'.
        System.assertEquals(1, cases.size());
        System.assertEquals('New', cases[0].status);
    }

    //Method to code coverage for closeCCErrorCase
    @isTest
    public static void closeCCErrorCaseWithPaymentPlan() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Early-out', 'Early-out M', 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', 'Delinquent', 'Delinquent M', 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('CC Error'));
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('CC Error M'));
        lstCampaign.add(objCampaign);

        insert lstCampaign;

        List<CampaignMember> lstCamp = new list<CampaignMember>();
        CampaignMember cmm = new CampaignMember(CampaignId = lstCampaign[0].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        cmm = new CampaignMember(CampaignId = lstCampaign[1].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        insert lstCamp;

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


        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'CC Error', guarantorContact.Id);
        insert objCase;

        lst = [Select id from CampaignMember where ContactId = :guarantorContact.Id];
        System.assertEquals(2, lst.Size());

        CaseUtil.closeCCErrorCase(setId, setpaymentPlan);
        Test.stopTest();

        // Retrive CampaignMember record.
        lst = [Select id from CampaignMember where ContactId = :guarantorContact.Id and (CampaignID = :lstCampaign[0].Id or CampaignID = :lstCampaign[1].Id)];

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
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Test.startTest();
        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Early-out', 'Early-out M', 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', 'Delinquent', 'Delinquent M', 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('CC Error'));
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('CC Error M'));
        lstCampaign.add(objCampaign);

        insert lstCampaign;

        List<CampaignMember> lstCamp = new list<CampaignMember>();
        CampaignMember cmm = new CampaignMember(CampaignId = lstCampaign[0].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        cmm = new CampaignMember(CampaignId = lstCampaign[1].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        lstCamp.add(cmm);

        insert lstCamp;

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

        CaseUtil.closeCCErrorCase(setId, setpaymentPlan);
        Test.stopTest();

        // Retrive CampaignMember record.
        lst = [Select id from CampaignMember where ContactId = :guarantorContact.Id and (CampaignID = :lstCampaign[0].Id or CampaignID = :lstCampaign[1].Id)];

        // Check system assert.
        System.assertEquals(2, lst.Size());
    }
    
    /**
     * Check all access rights for a read only User using runAs.
     **/
    @isTest
    static void checkAccessRights() {
        List<CaseSecurityContext> allContexts = new List<CaseSecurityContext>{CaseSecurityContext.CREATE_CONTEXT,
        	CaseSecurityContext.CREATE_WITH_GT_CONTEXT, CaseSecurityContext.CU_CREATE_WITH_ENCOUNTER_CONTEXT, 
                CaseSecurityContext.UPDATE_CONTEXT, CaseSecurityContext.UPSERT_CONTEXT, CaseSecurityContext.DELETE_CONTEXT
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
}
