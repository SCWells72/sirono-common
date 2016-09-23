/*
Test class for Auto Case functionality
*/
@isTest
public class TestClassUtil {
    Public Static Set<String> SetContact = new Set<String>();
    Public Static List<Statement__c> lstStatement = new List<Statement__c>();
    @testSetup static void setupData() {
        Map<String, Id> rtMap = new Map<String, Id>();
        for (RecordType rt : [Select Id, Name From RecordType Where sObjectType = 'Contact']) {
            rtMap.put(rt.Name, rt.Id);
        }


        Contact g = new Contact();
        g.RecordTypeId = rtMap.get('Guarantor');
        g.LastName = 'G Test';
        g.Profile_Pointer_Id__c = 12345;
        g.HomePhone = '111';
        g.MobilePhone = '111';
        insert g;

        Contact g1 = new Contact();
        g1.RecordTypeId = rtMap.get('Guarantor');
        g1.LastName = 'G Test1';
        g1.Profile_Pointer_Id__c = 123451;
        g1.HomePhone = '1111';
        g1.MobilePhone = '1111';
        insert g1;

        SetContact.Add(g1.Id);

        Statement__c stmt = new Statement__c();
        stmt.Statement_Date__c = System.Today();
        stmt.Guarantor__c = g.Id;
        insert stmt;

        stmt = new Statement__c();
        stmt.Statement_Date__c = System.Today();
        stmt.Guarantor__c = g.Id;
        lstStatement.add(stmt);


        stmt = new Statement__c();
        stmt.Statement_Date__c = System.Today();
        stmt.Guarantor__c = g1.Id;
        lstStatement.add(stmt);
        insert lstStatement;

        List<Campaign> lst = new List<Campaign>();
        Campaign objCampaign = New Campaign();
        objCampaign.Name = 'Early Out';
        objCampaign.IsActive = True;
        lst.add(objCampaign);

        objCampaign = New Campaign();
        objCampaign.Name = 'Early Out - Mobile';
        objCampaign.IsActive = True;
        lst.add(objCampaign);

        objCampaign = New Campaign();
        objCampaign.Name = 'Pre-collections';
        objCampaign.IsActive = True;
        lst.add(objCampaign);

        objCampaign = New Campaign();
        objCampaign.Name = 'Pre-collections - Mobile';
        objCampaign.IsActive = True;
        lst.add(objCampaign);

        objCampaign = New Campaign();
        objCampaign.Name = 'Pre-Service';
        objCampaign.IsActive = True;
        lst.add(objCampaign);

        objCampaign = New Campaign();
        objCampaign.Name = 'Pre-Service - Mobile';
        objCampaign.IsActive = True;
        lst.add(objCampaign);

        insert lst;

        Charge_Group__c cg = new Charge_Group__c();
        cg.Guarantor_Name__c = g.Id;
        cg.Charge_Group_ID__c = 123;
        cg.Charge_Group_External_ID__c = true;
        cg.Reported_Selfpay_Balance__c = 10;
        cg.Account_Status__c = 'Billed';
        cg.Account_Sub_Status__c = 'Overdue';
        insert cg;

        Transaction__c t = new Transaction__c();
        t.Amount__c = -100;
        t.Charge_Group__c = cg.Id;
        t.Credit_Balance__c = false;
        t.Export_Date__c = System.today();
        t.Fail_Date__c = null;
        t.Id__c = 123;
        t.Method__c = 'Service';
        t.Notes__c = 'Test';
        insert t;

        cg = new Charge_Group__c();
        cg.Guarantor_Name__c = g1.Id;
        cg.Charge_Group_ID__c = 1232323;
        cg.Charge_Group_External_ID__c = true;
        cg.Reported_Selfpay_Balance__c = 10;
        cg.Account_Status__c = 'Billed';
        cg.Account_Sub_Status__c = 'Overdue';
        insert cg;

        Encounter__c e1 = TestUtility.createEncounter(g.Id, -10, Date.today());
        insert e1;

        Encounter__c e2 = TestUtility.createEncounter(g.Id, -10, Date.today());
        insert e2;

        e1.Patient_Portion__c = 0;
        update e1;

        Payment_Arrangement__c pa = TestUtility.createPaymentArrangement(e2.Id);
        insert pa;

        //Test coverage for Auto case to manually closing the case [CaseTriggerHandler.removeCampaignMembers method]
        CaseUtil.ExecuteRemoveCampaignTrigger = true;
        Map<String, Id> caseRTMap = new Map<String, Id>();
        for (RecordType rt : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            caseRTMap.put(rt.Name, rt.Id);
        }

        List<Case> caseList = new List<Case>();
        Case c = TestUtility.createCase(caseRTMap.get('Automated Cases'), 'Early Out', g.Id);
        caseList.add(c);
        c = TestUtility.createCase(caseRTMap.get('Automated Cases'), 'Precollections', g.Id);
        caseList.add(c);
        c = TestUtility.createCase(caseRTMap.get('Automated Cases'), 'Encounter', g.Id);
        caseList.add(c);
        insert caseList;

        for (Case obj : caseList) {
            obj.Status = 'Closed';
        }
        update caseList;
    }
    @isTest public static void testCallEarlyOutAutoCase() {
        CaseUtil.CallEarlyOutAutoCase();
        CaseUtil.CallEarlyOutAutoCaseCloser();
        CaseUtil.CallCloseEarlyOutAutoCase(lstStatement);
    }

    @isTest public static void testCallPrecollectionsAutoCase() {
        CaseUtil.CallPrecollectionsAutoCaseCloser();
        CaseUtil.CallPrecollectionsAutoCase();

    }
    @isTest public static void testCloseEarlyOutAutoCase() {

        CaseUtil.CloseEarlyOutAutoCase(SetContact);

    }
}