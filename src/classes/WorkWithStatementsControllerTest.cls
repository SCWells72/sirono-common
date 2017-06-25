@isTest
private class WorkWithStatementsControllerTest {
	
	@isTest static void getAllInfoTest() {
		User gtUser = TestUtility.getGuarantorCommunityUser();
		User adminUser = TestUtility.getAdminUser();


		System.runAs(adminUser) {
	        Account testAcc = TestUtility.getAccount();

	      	Contact guarantorContact = GuarantorService.getPortalGuarantor(gtUser.Id);

			List<Statement__c> statements = new List<Statement__c>();
			for (String stmtDate :  new String[]{'10/07/2016', '11/07/2016', '12/07/2016', '01/07/2017', '02/07/2017'}) {
				Statement__c statement = TestUtility.generateStatement(guarantorContact.Id);
				statement.Statement_Date__c = Date.parse(stmtDate);
				statements.add(statement);
			}

	  		insert statements;

	  	}

        System.runAs(gtUser) {

			Test.setMock(HttpCalloutMock.class, new GuarantorServiceTest.GuarantorRestClientMock());
        	Test.startTest();

			List<WorkWithStatementsController.StatementWrapper> statements = WorkWithStatementsController.getAllInfo();
        	System.assertEquals(5, statements.size(), 'Expected 5 statements');

        	Test.stopTest();
        }

	}	
}