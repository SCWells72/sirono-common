@isTest
public class TestViewStatementExtension {


    @testSetup static void setupData() {
        Map<String, Id> rtMap = new Map<String, Id>();
        for (RecordType rt : [Select Id, Name From RecordType Where sObjectType = 'Contact']) {
            rtMap.put(rt.Name, rt.Id);
        }

        Contact g = new Contact();
        g.RecordTypeId = rtMap.get('Guarantor');
        g.LastName = 'G Test';
        g.Profile_Pointer_Id__c = 12345;
        insert g;

        Statement__c stmt = new Statement__c();
        stmt.Statement_Date__c = Date.parse('11/22/2015');
        stmt.Guarantor__c = g.Id;
        insert stmt;

        stmt = new Statement__c();
        stmt.Statement_Date__c = Date.parse('05/22/2016');
        stmt.Guarantor__c = g.Id;
        insert stmt;
    }

    @isTest public static void testStatementHasPDF() {
        //Find the statement for 11/22/2015
        Date stmtDate = Date.parse('11/22/2015');
        Statement__c stmt = [
                SELECT ID, Guarantor__r.Profile_Pointer_ID__c, Statement_Date__c
                FROM Statement__c
                WHERE Statement_Date__c = :stmtDate
                LIMIT 1
        ];

        //Start Test Context, to reset all Governor limits
        Test.startTest();

        //Instantiate StandardController with a Statement object
        ApexPages.StandardController stdController = new ApexPages.StandardController(stmt);

        //Create Controller extension by passing standardController
        ViewStatementExtension ext = new ViewStatementExtension(stdController);

        //Setup the MockHttpResponseGenerator
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        PageReference nextPage = ext.viewPdf();
        // Verify that we are being redirected to the expected page - when you create a PageReference with a URL, it de-constructs
        // the URL. When it re-creates it, it puts the query parameters in alphabetical order. So, we'll first create a PageReference
        // to compare the URLs to ensure that they are created with the parameters in the same order
        System.assertEquals(new PageReference('https://accudoc-toledo.s3.amazonaws.com/20151123/13_55_13_sir.' +
                '0x1355137f.pdf?Signature=TLcx4lV6cNNZ0eGPuiyRXe6LrAQ%3D&Expires=' +
                '1469037622&AWSAccessKeyId=AKIAJDZKICOKPTWZUYQA').getUrl(),
                nextPage.getUrl());

        System.assert(nextPage.getRedirect(), 'Expected redirect on returned PageReference to be set');

        //Finish Test
        Test.stopTest();
    }

    @isTest public static void testStatementNoPDF() {

        //Find the statement for 5/22/2016
        Date stmtDate = Date.parse('05/22/2016');
        Statement__c stmt = [
                SELECT ID, Guarantor__r.Profile_Pointer_ID__c, Statement_Date__c
                FROM Statement__c
                WHERE Statement_Date__c = :stmtDate
                LIMIT 1
        ];

        //Start Test Context, to reset all Governor limits
        Test.startTest();

        ApexPages.StandardController stdController = new ApexPages.StandardController(stmt);
        ViewStatementExtension ext = new ViewStatementExtension(stdController);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        PageReference nextPage = ext.viewPdf();
        // Verify that we are not being redirected
        System.assert(nextPage == null, 'Expected null, found: ' + nextPage);

        //Finish Test
        Test.stopTest();
    }
}