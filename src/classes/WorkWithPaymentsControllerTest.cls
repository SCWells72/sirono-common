@isTest
private class WorkWithPaymentsControllerTest {
	
	@isTest static void getPaymentHistoryTest() {
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

	  		Map<String, String> recordTypeMap = new Map<String, String>();
	        for (RecordType recordType : [
                SELECT Id, Name
                FROM RecordType
                WHERE sObjectType = 'Payment_Method__c'
	        ]) {
	            recordTypeMap.put(recordType.Name, recordType.Id);
	        }

	        List<Payment_Method__c> lstPaymentMethod = new List<Payment_Method__c>();
	        Payment_Method__c paymentMethod1 = TestUtility.generatePaymentMethod(guarantorContact.Id, recordTypeMap.get('Credit Card'));
	        paymentMethod1.Card_Type__c = 'Visa';
	        paymentMethod1.Last_4__c = '1111';
        	insert paymentMethod1;
        	Payment_Method__c paymentMethod2 = TestUtility.generatePaymentMethod(guarantorContact.Id, recordTypeMap.get('Check/Cash'));
        	insert paymentMethod2;

	  		Payment__c payment1 = TestUtility.generateSironoPayment(guarantorContact.Id, 1234, 12);
	  		payment1.Payment_Method__c = paymentMethod1.Id;
	  		payment1.Method__c = 'Credit';
	        Payment__c payment2 = TestUtility.generateSironoPayment(guarantorContact.Id, 1235, 25);
	        payment2.Payment_Method__c = paymentMethod2.Id;
	  		payment2.Method__c = 'Check';
	  		payment2.Processor_Transaction_ID__c = '12345qwert';
	        List<Payment__c> lstPayment = new List<Payment__c>{payment1, payment2};
	        insert lstPayment;
	    }

	    System.runAs(internalUser) {
        	Test.startTest();

        	List<WorkWithPaymentsController.PaymentsWrapper> paymentsList = WorkWithPaymentsController.getPaymentHistory();
        	System.assertEquals(paymentsList.size(), 2);
        	for (WorkWithPaymentsController.PaymentsWrapper pw : paymentsList) {
        		if (pw.method == 'Credit') {
        			System.assertEquals(pw.description, 'Visa 1111');
        		} else {
        			System.assertEquals(pw.description, '12345qwert');
        		}
        	}
        	Test.stopTest();
        }
	}	
}