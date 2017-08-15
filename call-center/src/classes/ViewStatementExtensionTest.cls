/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This class tests methods implemented in ViewStatementExtension class.
 **/
@IsTest
public class ViewStatementExtensionTest {
    public static List<Statement__c> lstStatement = new List<Statement__c>();

    /**
     * Setup data common to all tests.
     **/
    @TestSetup
    static void setupData() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = Decimal.valueOf(RestClientConstants.GUARANTOR_ID);
        insert guarantorContact;

        Statement__c statement = TestUtility.generateStatement(guarantorContact.Id);
        lstStatement.add(statement);

        statement = TestUtility.generateStatement(guarantorContact.Id);
        statement.Statement_Date__c = Date.parse(RestClientConstants.STATEMENT_DATES[0]);
        lstStatement.add(statement);

        statement = TestUtility.generateStatement(guarantorContact.Id);
        statement.Statement_Date__c = Date.parse(RestClientConstants.STATEMENT_DATES[RestClientConstants.STATEMENT_DATES.size() - 1]);
        lstStatement.add(statement);

        insert lstStatement;

    }

    /**
     * This method verifies provided Statement Has PDF to view.
     **/
    @IsTest public static void testStatementHasPDF() {
        // Find the statement for the first statement date
        Date stmtDate = Date.parse(RestClientConstants.STATEMENT_DATES[0]);
        Statement__c stmt = [
            SELECT Id, Guarantor__r.Profile_Pointer_Id__c, Statement_Date__c
            FROM Statement__c
            WHERE Statement_Date__c = :stmtDate
            LIMIT 1
        ];

        // Instantiate StandardController with a Statement object
        ApexPages.StandardController stdController = new ApexPages.StandardController(stmt);

        // Create Controller extension by passing standardController
        ViewStatementExtension ext = new ViewStatementExtension(stdController);

        // Setup the Mock
        Test.setMock(HttpCalloutMock.class, new GuarantorServiceTest.GuarantorRestClientMock());

        // Start Test Context, to reset all Governor limits
        Test.startTest();
        PageReference nextPage = ext.viewPdf();
        Test.stopTest();

        // Verify that we are being redirected to the expected page - when you create a PageReference with a URL, it de-constructs
        // the URL. When it re-creates it, it puts the query parameters in alphabetical order. So, we'll first create a PageReference
        // to compare the URLs to ensure that they are created with the parameters in the same order
        // Check system assert, NextPage Url should match with provided PageReference.
        String pdfURL = new PageReference('https://accudoc-dev.s3.amazonaws.com/20161007/13_55_13_sir.0x1355137f.pdf?AWSAccessKeyId=AKIAIG3KNVYUQ4EURDHA&Signature=E5pZzByCMFcRraYK102YGi6lbhE%3D&Expires=1497709690').getUrl();
        System.assertEquals(pdfURL, nextPage.getUrl());

        // Check system assert, Returned PageReference should have Redirect attribute true.
        System.assert(nextPage.getRedirect(), 'Redirect attribute should be true for returned PageReference');
    }

    /**
     * This method verifies provided Statement has no PDF to view.
     **/
    @IsTest public static void testStatementNoPDF() {

        // Find the statement for the last statement date (it doesn't have a url)
        Date stmtDate = Date.parse(RestClientConstants.STATEMENT_DATES[RestClientConstants.STATEMENT_DATES.size() - 1]);
        Statement__c stmt = [
            SELECT Id, Guarantor__r.Profile_Pointer_Id__c, Statement_Date__c
            FROM Statement__c
            WHERE Statement_Date__c = :stmtDate
            LIMIT 1
        ];

        // Start Test Context, to reset all Governor limits
        Test.startTest();

        ApexPages.StandardController stdController = new ApexPages.StandardController(stmt);
        ViewStatementExtension ext = new ViewStatementExtension(stdController);

        Test.setMock(HttpCalloutMock.class, new GuarantorServiceTest.GuarantorRestClientMock());

        PageReference nextPage = ext.viewPdf();
        Test.stopTest();

        // Check system assert, Returned PageReference should be null & therefore we are not being redirected.
        System.assert(nextPage == null, 'Returned PageReference should be null, found: ' + nextPage);
    }
}