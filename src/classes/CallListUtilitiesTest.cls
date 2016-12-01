/*
* @author Sirono
* @version 1.0.1
* @Date: 09-14-2016
* @ Unit class  for the CallListUtilities class.
* Do the code coverage for the CallListUtilities class
*/

@isTest
public class CallListUtilitiesTest {


    //Viraj Rana : 09-15-2016: Unit test of preCollectionCallListRemoval method
    @isTest
    Public static void preCollectionCallListRemoval() {
        CallListUtilities obj = new CallListUtilities();
        /*TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateguarantorContact();
        insert guarantorContact ;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = 'Due';
        chargeGroup.Charge_Group_ID__c = 123;
        insert chargeGroup;

        Transaction__c transactionObj = TestUtility.generateTransaction(chargeGroup, -101, 'Automatic');
        insert transactionObj ;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = 'Delinquent';
        chargeGroup.Charge_Group_ID__c = 123444;
        chargeGroup.Pre_Collection_Sent__c = system.today();
        insert chargeGroup;

        transactionObj = TestUtility.generateTransaction(chargeGroup, -500, 'Automatic');
        insert transactionObj ;

        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Early-out', 'Early-out M', 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', 'Delinquent', 'Delinquent M', 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('PreCollections'));
        lstCampaign.add(objCampaign);

        objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('Early-out'));
        lstCampaign.add(objCampaign);

        insert lstCampaign;

        CampaignMember cmm = new CampaignMember(CampaignId = lstCampaign[0].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        insert cmm;

        transactionObj.amount__c = -501;
        update transactionObj;
        update guarantorContact ;*/
    }
/*
    //Viraj Rana : 09-15-2016: Unit test of preCollectionCallListRemoval method
    @isTest
    Public static void preCollectionCallListRemoval1() {
        TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateguarantorContact();
        insert guarantorContact ;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = 'Due';
        chargeGroup.Charge_Group_ID__c = 123;
        insert chargeGroup;

        Transaction__c transactionObj = TestUtility.generateTransaction(chargeGroup, -101, 'Automatic');
        insert transactionObj ;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = 'Delinquent';
        chargeGroup.Charge_Group_ID__c = 123444;
        insert chargeGroup;

        List<Charge_Group__c> lst = TestUtility.generatechargeGroupList(guarantorContact.Id);
        transactionObj = TestUtility.generateTransaction(chargeGroup, -500, 'Automatic');
        insert transactionObj ;

        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Early-out', 'Early-out M', 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', 'Delinquent', 'Delinquent M', 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('PreCollections'));
        lstCampaign.add(objCampaign);
        insert lstCampaign;

        CampaignMember cmm = new CampaignMember(CampaignId = lstCampaign[0].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        insert cmm;

        transactionObj.amount__c = -501;
        update transactionObj;
        update guarantorContact ;
    }

    //Viraj Rana : 09-15-2016: Unit test of preCollectionCallListRemoval method
    @isTest
    Public static void earlyOutCallListRemoval() {
        TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateguarantorContact();
        insert guarantorContact ;

        Map<String, String> mapCampaignMapping = CaseUtil.campaignMapping(new Set<String>{
                'Early-out', 'Early-out M', 'PreCollections', 'PreCollections M',
                'PreService', 'PreService M', 'Delinquent', 'Delinquent M', 'CC Error M', 'CC Error'
        });

        List<Campaign> lstCampaign = new List<Campaign>();
        Campaign objCampaign = TestUtility.generateCampaign(mapCampaignMapping.get('Early-out'));
        lstCampaign.add(objCampaign);
        insert lstCampaign;

        CampaignMember cmm = new CampaignMember(CampaignId = lstCampaign[0].Id, ContactId = guarantorContact.Id, Status = 'Sent');
        insert cmm;

        update guarantorContact;
    }

    //Viraj Rana : 09-15-2016: Unit test of preCollectionCallListRemoval method
    @isTest
    public static void removeCampaignMembers() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Early Out', guarantorContact.Id);
        objCase.Type = 'Delinquent';
        insert objCase;

        objCase.Status = 'Closed';
        Update objCase;

    }

    //Viraj Rana : 09-15-2016: Unit test of preCollectionCallListRemoval method
    @isTest
    public static void removeCampaignMembers1() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Precollections', guarantorContact.Id);
        objCase.Type = 'Precollections';
        insert objCase;

        objCase.Status = 'Closed';
        Update objCase;

    }

    //Viraj Rana : 09-15-2016: Unit test of preCollectionCallListRemoval method
    @isTest
    public static void removeCampaignMembers2() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Early Out', guarantorContact.Id);
        insert objCase;

        objCase.Status = 'Closed';
        Update objCase;

    }

    //Viraj Rana : 09-15-2016: Unit test of preCollectionCallListRemoval method
    @isTest
    public static void removeCampaignMembers3() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'CC Error', guarantorContact.Id);
        insert objCase;

        objCase.Status = 'Closed';
        Update objCase;

    }

    //Viraj Rana : 09-15-2016: Unit test of preCollectionCallListRemoval method
    @isTest
    public static void removeCampaignMembers4() {
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
        for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRecordTypeMap.put(recordType.Name, recordType.Id);
        }

        Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Automated Cases'), 'Encounter', guarantorContact.Id);
        insert objCase;

        objCase.Status = 'Closed';
        Update objCase;

    }

    //Viraj Rana : 09-15-2016: Unit test of preCollectionCallListRemoval method
    @isTest
    public static void checkAndDoAddNoteCallout() {
        TestUtility objUtility = new TestUtility();


        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standarduser@testorg1212.com');

        System.runAs(u) {
            Contact guarantorContact = TestUtility.generateGuarantorContact();
            insert guarantorContact;

            Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
            for (RecordType recordType : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
                caseRecordTypeMap.put(recordType.Name, recordType.Id);
            }

            Case objCase = TestUtility.generateCase(caseRecordTypeMap.get('Internal Case'), 'Early Out', guarantorContact.Id);
            objCase.Type = 'Delinquent';
            objCase.Description = 'Delinquent';
            objCase.Charge_Group_IDs__c = '121';
            insert objCase;

            objCase.Status = 'Closed';
            Update objCase;
        }
    }

    //Viraj Rana : 09-15-2016: Unit test of caseEarlyOutClose method
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

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, 'Service');
        insert objTransaction;

        objTransaction.Amount__c = 1000;
        update objTransaction;
        Test.StopTest();
    }

    //Viraj Rana : 09-15-2016: Unit test of caseEarlyOutClose method
    @isTest
    public static void testCallEarlyOutAutoCase2() {
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
        chargeGroup.Account_Sub_Status__c = 'Delinquent';
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -100, 'Service');
        insert objTransaction;

        objTransaction.Amount__c = 1000;
        update objTransaction;
        Test.StopTest();
    }*/
}