/**
 * This class tests methods implemented in ViewStatementExtension class.
 **/

@isTest
public class ViewStatementExtensionTest {
    Public Static List<Statement__c> lstStatement = new List<Statement__c>();

    /**
     * This method is used to setup preliminary data to let's all testmethods to execute as expected.
     **/
    @testSetup
    static void setupData() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Statement__c statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);

        statement = TestUtility.generateStatement(guarantorContact.Id);
        statement.Statement_Date__c = Date.parse('11/22/2015');
        lstStatement.add(statement);

        statement = TestUtility.generateStatement(guarantorContact.Id);
        statement.Statement_Date__c = Date.parse('05/22/2016');
        lstStatement.add(statement);

        INSERT lstStatement;

    }

    /**
     * This method verifies provided Statement Has PDF to view.
     **/
    @isTest public static void testStatementHasPDF() {
        // Find the statement for 11/22/2015
        Date stmtDate = Date.parse('11/22/2015');
        Statement__c stmt = [
                SELECT ID, Guarantor__r.Profile_Pointer_ID__c, Statement_Date__c
                FROM Statement__c
                WHERE Statement_Date__c = :stmtDate
                LIMIT 1
        ];

        // Start Test Context, to reset all Governor limits
        Test.startTest();

        // Instantiate StandardController with a Statement object
        ApexPages.StandardController stdController = new ApexPages.StandardController(stmt);

        // Create Controller extension by passing standardController
        ViewStatementExtension ext = new ViewStatementExtension(stdController);

        // Setup the MockHttpResponseGenerator
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        PageReference nextPage = ext.viewPdf();
        Test.stopTest();

        // Verify that we are being redirected to the expected page - when you create a PageReference with a URL, it de-constructs
        // the URL. When it re-creates it, it puts the query parameters in alphabetical order. So, we'll first create a PageReference
        // to compare the URLs to ensure that they are created with the parameters in the same order
        // Check system assert, NextPage Url should match with provided PageReference.
        System.assertEquals(new PageReference('https://accudoc-toledo.s3.amazonaws.com/20151123/13_55_13_sir.' +
                '0x1355137f.pdf?Signature=TLcx4lV6cNNZ0eGPuiyRXe6LrAQ%3D&Expires=' +
                '1469037622&AWSAccessKeyId=AKIAJDZKICOKPTWZUYQA').getUrl(),
                nextPage.getUrl(),
                'NextPage Url does not match with provided PageReference Url.');

        // Check system assert, Returned PageReference should have Redirect attribute true.
        System.assert(nextPage.getRedirect(), 'Redirect attribute should be true for returned PageReference');
    }

    /**
     * This method verifies provided Statement Has not PDF to view.
     **/
    @isTest public static void testStatementNoPDF() {

        // Find the statement for 5/22/2016
        Date stmtDate = Date.parse('05/22/2016');
        Statement__c stmt = [
                SELECT ID, Guarantor__r.Profile_Pointer_ID__c, Statement_Date__c
                FROM Statement__c
                WHERE Statement_Date__c = :stmtDate
                LIMIT 1
        ];

        // Start Test Context, to reset all Governor limits
        Test.startTest();

        ApexPages.StandardController stdController = new ApexPages.StandardController(stmt);
        ViewStatementExtension ext = new ViewStatementExtension(stdController);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());

        PageReference nextPage = ext.viewPdf();
        Test.stopTest();

        // Check system assert, Returned PageReference should be null & therefore we are not being redirected.
        System.assert(nextPage == null, 'Returned PageReference should must be null, found: ' + nextPage);
    }
}