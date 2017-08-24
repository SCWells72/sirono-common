/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
private class WorkWithStatementsControllerTest {

    private static final String[] STATEMENT_DATES = new String[] { '10/07/2016', '11/07/2016', '12/07/2016', '01/07/2017', '02/07/2017' };

    @IsTest
    static void getStatementsTest() {
        User gtUser = PortalTestUtility.getGuarantorCommunityUser();
        User adminUser = PortalTestUtility.getPortalAdminUser();


        System.runAs(adminUser) {
            Contact guarantorContact = sPRS.GuarantorService.getPortalGuarantor(gtUser.Id);

            List<sPRS__Statement__c> statements = new List<sPRS__Statement__c>();
            for (String stmtDate : STATEMENT_DATES) {
                sPRS__Statement__c statement = PortalTestUtility.generateStatement(guarantorContact.Id);
                statement.sPRS__Statement_Date__c = Date.parse(stmtDate);
                statements.add(statement);
            }

            insert statements;
        }

        System.runAs(gtUser) {
            Test.setMock(HttpCalloutMock.class, new sPRS.GuarantorRestClientMock());
            Test.startTest();

            List<WorkWithStatementsController.StatementWrapper> statements = WorkWithStatementsController.getStatements();
            Test.stopTest();

            System.assertEquals(5, statements.size(), 'Expected 5 statements');
        }
    }
}