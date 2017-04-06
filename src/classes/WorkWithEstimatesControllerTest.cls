@isTest
private class WorkWithEstimatesControllerTest {
	
	@isTest static void getAllEstimatesAndPatientTest() {
		Contact guarantorContact;
		Contact patientContact;
		User internalUser;
		UserRole usrRole = [
            SELECT Id
            FROM UserRole 
            WHERE Name = 'CEO'
        ];

        Profile testProfile = [
            SELECT Id, Name
            FROM Profile 
            WHERE Name = 'System Administrator'
        ];

		User testUser = new User (
            LastName = 'test user 1', 
            Username = String.valueOf(System.now().millisecond()) + 'test.user.estimate@example.com', 
            Email = 'test.1@example.com', 
            Alias = 'testu1', 
            TimeZoneSidKey = 'GMT', 
            LocaleSidKey = 'en_GB', 
            EmailEncodingKey = 'ISO-8859-1', 
            ProfileId = testProfile.Id, 
            UserRoleId = usrRole.Id,
            LanguageLocaleKey = 'en_US'
        ); 
        insert testUser;        

		System.runAs(testUser) {
			Profile profile = [
	            SELECT Id, Name
	            FROM Profile 
	            WHERE Name = 'Guarantor'
	        ];

	        Account testAcc = new Account (
	        	Name = 'Test Account Name'
	        );
  			insert testAcc;

	      	guarantorContact = TestUtility.generateGuarantorContact();
	      	guarantorContact.AccountId = testAcc.Id;
	        insert guarantorContact;

	        patientContact = TestUtility.generatePatientContact();
	      	patientContact.AccountId = testAcc.Id;
	      	patientContact.Medical_Record_Number__c = '1234512345';
	        insert patientContact;

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

	  		List<Encounter__c> lstEncounter = new List<Encounter__c>();
	  		Encounter__c encounter1 = TestUtility.generateEncounter(guarantorContact.Id, 10, Date.today());
	  		encounter1.Patient__c = patientContact.Id;
	  		encounter1.Insurance_Discount__c = 2;
	        encounter1.Insurance_Portion__c = 2;
	        lstEncounter.add(encounter1);
	        Encounter__c encounter2 = TestUtility.generateEncounter(guarantorContact.Id, 10, Date.today());
	        encounter2.Total_Payments__c = 5;
	        encounter2.Patient__c = patientContact.Id;
	        encounter2.Insurance_Discount__c = 3;
	        encounter2.Insurance_Portion__c = 2;
	        lstEncounter.add(encounter2);

	        insert lstEncounter;

	        Attachment testAttach = new Attachment (
	        	Body = Blob.valueOf('Test string'),
	        	Name = 'test attach',
	        	ParentId = encounter1.Id
	        );
	        insert testAttach;
		}

		List<WorkWithInvoicesController.PatientWrapper> patientList = WorkWithEstimatesController.getPatientList();
    	System.assertEquals(patientList.size(), 0);

        System.runAs(internalUser) {
        	Test.startTest();

        	List<WorkWithEstimatesController.EstimateWrapper> estimateList = WorkWithEstimatesController.getAllEstimates('Unpaid', patientContact.Id);
        	System.assertEquals(estimateList.size(), 1);
        	estimateList = WorkWithEstimatesController.getAllEstimates('Paid', patientContact.Id);
        	System.assertEquals(estimateList.size(), 1);
        	patientList = WorkWithEstimatesController.getPatientList();
        	System.assertEquals(patientList.size(), 2);

        	Test.stopTest();
        }
	}	
}