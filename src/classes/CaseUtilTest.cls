/*
* @author Sirono
* @version 1.0.1
* @Date: 08-23-2016
* @ Unit class  for the CaseUtil class.     
* Do the code coverage for the CaseUtil class
* 10-19-2016: Viraj - Tracker # 132105543: Revisit negative balances in cases.
*/

@isTest
public class CaseUtilTest {
    Public Static List<CampaignMember> lst ;
    //Method to code coverage for Create Early Out Case, And Close the Early Out case
    @isTest
    public static void testCallEarlyOutAutoCase1() {
        Test.StartTest();
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
        chargeGroup.Account_Sub_Status__c = 'Overdue';
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
        Test.StopTest();
    }

    //Method to code coverage for Create Early Out Case, And Close the Early Out case
    @isTest
    public static void testCallEarlyOutAutoCase2() {
        Test.StartTest();
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
        chargeGroup.Account_Sub_Status__c = 'Overdue';
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
        Test.StopTest();
    }

    //Method to code coverage for callEarlyOutAutoCaseCloser
    @isTest
    public static void testCallEarlyOutAutoCaseCloser1() {
        Test.StartTest();
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
        chargeGroup.Account_Sub_Status__c = 'Overdue';
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, 'Service');
        insert objTransaction;

        List<Statement__c> lstStatement = new List<Statement__c>();
        Statement__c statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);


        statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);
        insert lstStatement;

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
        Test.StopTest();
    }

    //Method to code coverage for callCloseEarlyOutAutoCase
    @isTest
    public static void testCallEarlyOutAutoCaseCloser2() {
        Test.StartTest();
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
        chargeGroup.Account_Sub_Status__c = 'Overdue';
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, 'Service');
        insert objTransaction;

        List<Statement__c> lstStatement = new List<Statement__c>();
        Statement__c statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);


        statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);
        insert lstStatement;

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
        Test.StopTest();
    }


    //Method to code coverage for callPrecollectionsAutoCase
    @isTest
    public static void testcallPrecollectionsAutoCase1() {
        Test.StartTest();
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
        chargeGroup.Account_Sub_Status__c = 'Overdue';
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

        CaseUtil.callPrecollectionsAutoCase();
        Test.StopTest();
    }

    //Method to code coverage for createPrecollectionsAutoCase
    @isTest
    public static void testCallPrecollectionsAutoCase2() {
        Test.StartTest();
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
        chargeGroup.Account_Sub_Status__c = 'Delinquent';
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
        Test.StopTest();
    }


    //Method to code coverage for createPrecollectionsAutoCase
    @isTest
    public static void testCallPrecollectionsAutoCase3() {
        Test.StartTest();
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
        chargeGroup.Account_Sub_Status__c = 'Delinquent';
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
        Test.StopTest();
    }

    //Method to code coverage for createPrecollectionsAutoCase
    @isTest
    public static void testCallPrecollectionsAutoCase4() {
        Test.StartTest();
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
        chargeGroup.Account_Sub_Status__c = 'Delinquent';
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
        Test.StopTest();
    }

    //Method to code coverage for callPrecollectionsAutoCaseCloser
    @isTest
    public static void testcallPrecollectionsAutoCaseCloser1() {
        Test.StartTest();
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
        chargeGroup.Account_Sub_Status__c = 'Overdue';
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, 'Service');
        insert objTransaction;

        List<Statement__c> lstStatement = new List<Statement__c>();
        Statement__c statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);


        statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);
        insert lstStatement;

        CaseUtil.callPrecollectionsAutoCaseCloser();
        Test.StopTest();
    }

    //Method to code coverage for callClosePrecollectionsAutoCase
    @isTest
    public static void testcallClosePrecollectionsAutoCase1() {
        Test.StartTest();
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
        chargeGroup.Account_Sub_Status__c = 'Delinquent';
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

        CaseUtil.callClosePrecollectionsAutoCase(lstStatement);
        Test.StopTest();
    }


    //Method to code coverage for createEncounterAutoCase
    @isTest
    public static void testCreateEncounterAutoCase() {
        Test.StartTest();
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
        chargeGroup.Account_Sub_Status__c = 'Overdue';
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, 'Service');
        insert objTransaction;

        List<Statement__c> lstStatement = new List<Statement__c>();
        Statement__c statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);


        statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);
        insert lstStatement;

        CaseUtil.callPrecollectionsAutoCase();
        Test.StopTest();
    }

    //Method to code coverage for createEncounterAutoCase
    @isTest
    public static void testCreateEncounterAutoCase1() {
        Test.StartTest();
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
        chargeGroup.Account_Sub_Status__c = 'Delinquent';
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
        Test.StopTest();
    }


    //Method to code coverage for createEncounterAutoCase
    @isTest
    public static void testCreateEncounterAutoCase2() {
        Test.StartTest();
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
        chargeGroup.Account_Sub_Status__c = 'Delinquent';
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
        Test.StopTest();
    }


    //Method to code coverage for createDelinquentPaymentCase
    @isTest
    public static void testCreateDelinquentPaymentCase1() {
        Test.StartTest();
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
        chargeGroup.Account_Sub_Status__c = 'Delinquent';
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, 'Service');
        insert objTransaction;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

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
        Test.StopTest();
    }

    //Method to code coverage for createDelinquentPaymentCase
    @isTest
    public static void testCreateDelinquentPaymentCase2() {
        Test.StartTest();
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
        chargeGroup.Account_Sub_Status__c = 'Delinquent';
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, 'Service');
        insert objTransaction;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

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
        Test.StopTest();
    }

    //Method to code coverage for createDelinquentPaymentCase
    @isTest
    public static void testCreateDelinquentPaymentCase3() {
        Test.StartTest();
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
        chargeGroup.Account_Sub_Status__c = 'Delinquent';
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, 'Service');
        insert objTransaction;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

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
        Test.StopTest();
    }


    //Method to code coverage for closeDelinquentPaymentCase
    @isTest
    public static void testcloseDelinquentPaymentCase() {
        Test.StartTest();
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
        chargeGroup.Account_Sub_Status__c = 'Delinquent';
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, 'Service');
        insert objTransaction;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

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

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.id);
        paymentPlan.active__c = true;
        paymentPlan.Delinquent__c = true;
        insert paymentPlan;

        test__c paymentPlan1 = TestUtility.generatePaymentPlan(guarantorContact.id);
        paymentPlan1.active__c = true;
        paymentPlan1.Delinquent__c = true;
        insert paymentPlan1;


        Set<Id> setId = new Set<Id>();
        setId.add(guarantorContact.Id);

        Set<Id> setpaymentPlan = new Set<Id>();
        setpaymentPlan.add(paymentPlan.Id);

        CaseUtil.closeDelinquentPaymentCase(setId, setpaymentPlan);
        Test.StopTest();
    }


    //Method to code coverage for closeDelinquentPaymentCase
    @isTest
    public static void testcloseDelinquentPaymentCase2() {
        Test.StartTest();
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
        chargeGroup.Account_Sub_Status__c = 'Delinquent';
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, 'Service');
        insert objTransaction;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

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

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.id);
        paymentPlan.active__c = true;
        paymentPlan.Delinquent__c = true;
        insert paymentPlan;

        Set<Id> setId = new Set<Id>();
        setId.add(guarantorContact.Id);

        Set<Id> setpaymentPlan = new Set<Id>();
        setpaymentPlan.add(paymentPlan.Id);

        CaseUtil.closeDelinquentPaymentCase(setId, setpaymentPlan);
        Test.StopTest();
    }


    //Method to code coverage for createCCErrorCase
    @isTest
    public static void testCreateCCErrorCase() {
        Test.StartTest();
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

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
        Test.StopTest();
    }

    //Method to code coverage for createCCErrorCase1
    @isTest
    public static void testCreateCCErrorCase1() {
        Test.StartTest();
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

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
        Test.StopTest();
    }

    //Method to code coverage for createCCErrorCase1
    @isTest
    public static void testCreateCCErrorCase2() {
        Test.StartTest();
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

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
        Test.StopTest();
    }

    //Method to code coverage for closeCCErrorCase
    @isTest
    public static void testcloseCCErrorCase1() {
        Test.StartTest();
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

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

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.id);
        paymentPlan.active__c = true;
        paymentPlan.Delinquent__c = true;
        insert paymentPlan;

        test__c paymentPlan1 = TestUtility.generatePaymentPlan(guarantorContact.id);
        paymentPlan1.active__c = true;
        paymentPlan1.Has_Error__c = true;
        paymentPlan1.Payable_Amount__c = -101;
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

        lst = [Select id from CampaignMember where ContactId = :guarantorContact.Id and (CampaignID = :lstCampaign[0].Id or CampaignID = :lstCampaign[1].Id)];
        System.assertEquals(0, lst.Size());

        Test.StopTest();
    }

    //Method to code coverage for closeCCErrorCase
    @isTest
    public static void testcloseCCErrorCase2() {
        Test.StartTest();
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

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

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.id);
        paymentPlan.active__c = true;
        paymentPlan.Delinquent__c = true;
        insert paymentPlan;

        test__c paymentPlan1 = TestUtility.generatePaymentPlan(guarantorContact.id);
        paymentPlan1.active__c = true;
        paymentPlan1.Has_Error__c = true;
        paymentPlan1.Payable_Amount__c = -101;
        insert paymentPlan1;

        Set<Id> setId = new Set<Id>();
        setId.add(guarantorContact.Id);

        Set<Id> setpaymentPlan = new Set<Id>();
        setpaymentPlan.add(paymentPlan.Id);

        lst = [Select id from CampaignMember where ContactId = :guarantorContact.Id];
        System.assertEquals(2, lst.Size());

        CaseUtil.closeCCErrorCase(setId, setpaymentPlan);

        lst = [Select id from CampaignMember where ContactId = :guarantorContact.Id and (CampaignID = :lstCampaign[0].Id or CampaignID = :lstCampaign[1].Id)];
        System.assertEquals(2, lst.Size());
        Test.StopTest();
    }
}