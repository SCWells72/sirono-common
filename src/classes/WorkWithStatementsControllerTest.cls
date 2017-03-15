@isTest
private class WorkWithStatementsControllerTest {
	
	@isTest static void getAllInfoTest() {
		User internalUser;
		System.runAs(new User(Id = UserInfo.getUserId(), UserRoleId = UserInfo.getUserRoleId())) {
			Profile profile = [
	            SELECT Id, Name
	            FROM Profile 
	            WHERE name = 'Guarantor Community'
	        ];

	        Account testAcc = new Account (
	        	Name = 'Test Account Name'
	        );
  			insert testAcc;

	      	Contact guarantorContact = TestUtility.generateGuarantorContact();
	      	guarantorContact.AccountId = testAcc.Id;
	        insert guarantorContact;

	        internalUser = new User (
	        	Username = profile.Id + String.valueOf(System.now().millisecond()) + '@example.com',
	            ProfileId = profile.Id,
	            ContactId = guarantorContact.Id,
	            Alias = 'user' + System.now().millisecond(),
	            Email = profile.Id + '@example.com',
	            EmailEncodingKey = 'UTF-8',
	            LastName = 'Test',
	            CommunityNickname = profile.Id,
	            TimeZoneSidKey = 'America/Los_Angeles',
	            LocaleSidKey = 'en_US',
	            LanguageLocaleKey = 'en_US'
	        );
	  		insert internalUser;

	  		Statement__c statement1 = TestUtility.generateStatement(guarantorContact.Id);
	  		Statement__c statement2 = TestUtility.generateStatement(guarantorContact.Id);
	  		List<Statement__c> lstStatement = new List<Statement__c>{statement1, statement2};
	  		insert lstStatement;

	  		Attachment testAttach = new Attachment (
	        	Body = Blob.valueOf('Test string'),
	        	Name = 'test attach',
	        	ParentId = statement1.Id
	        );
	        insert testAttach;
	  	}

	  	List<WorkWithStatementsController.StatementWrapper> statementList = WorkWithStatementsController.getAllInfo();
    	System.assertEquals(statementList.size(), 0);

        System.runAs(internalUser) {
        	Test.startTest();

        	statementList = WorkWithStatementsController.getAllInfo();
        	System.assertEquals(statementList.size(), 2);

        	Test.stopTest();
        }

	}	
}