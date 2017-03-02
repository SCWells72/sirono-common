@isTest
private class HiMSS_SummaryWidgetRESTServiceTest {
//    static testMethod void getGuarantorTest() {
//    	Test.startTest();
//        User portalUser;
//    	User thisUser = [ SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
//      	System.runAs(thisUser) {
//      		UserRole portalRole = [SELECT Id FROM UserRole WHERE PortalType = 'None' Limit 1];
//      		Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
//
//      		Account portalAccount = new Account(
//		        Name = 'Portal Account',
//		        OwnerId = thisUser.Id
//		    );
//		    insert portalAccount;
//
//		    Contact portalContact = new Contact(
//	           	FirstName = 'Donald',
//	          	Lastname = 'McTesty',
//		        AccountId = portalAccount.Id
//	      	);
//		    insert portalContact;
//
//		    Invoice__c invoice = new Invoice__c(
//		    	Due_Date__c = Date.today().addDays(4),
//		    	Guarantor__c = portalContact.Id,
//		    	Name = 'invoice for test',
//		    	Invoice_Status_Index__c = 7
//		    );
//		    insert invoice;
//
//		    Payment_Plan__c paymentPlan = new Payment_Plan__c(
//		    	Name = 'payment plan for test',
//		    	Guarantor__c = portalContact.Id,
//		    	NextPaymentDate__c = Date.today().addDays(4),
//		    	Installment_Amount__c = 340,
//		    	Original_Installment_Count__c = 120,
//		    	Active__c = true,
//		    	Plan_Type__c = 'planType'
//		    );
//		    insert paymentPlan;
//
//		    Encounter__c encounter = new Encounter__c(
//		    	Guarantor__c = portalContact.Id
//		    );
//		    insert encounter;
//
//		    Profile portalProfile = [
//		        SELECT Id
//		        FROM Profile
//		        WHERE Name = 'Guarantor'
//		        LIMIT 1
//		    ];
//
//		    portalUser = new User(
//		        Username = System.now().millisecond() + 'test12345@test.com',
//		        ContactId = portalContact.Id,
//		        ProfileId = portalProfile.Id,
//		        Alias = 'test123',
//		        Email = 'test12345@test.com',
//		        EmailEncodingKey = 'UTF-8',
//		        FirstName = 'Donald',
//		        LastName = 'McTesty',
//		        CommunityNickname = 'test12345',
//		        TimeZoneSidKey = 'America/Los_Angeles',
//		        LocaleSidKey = 'en_US',
//		        LanguageLocaleKey = 'en_US',
//		        Community_Password__c = '!pass_1234',
//		        Is_Demo_Locked__c = false
//	      	);
//	      	insert portalUser;
//
//	      	RestRequest req = new RestRequest();
//	        req.requestURI = '/rest';
//	        req.addParameter('firstName', 'Donald');
//	        req.addParameter('lastName', 'McTesty');
//	        RestContext.request = req;
//        	HiMSS_SummaryWidgetRESTService.getGuarantor();
//
//        	System.debug('::::RestContext.response:::::' + RestContext.response);
//      	}
//      	Test.stopTest();
//    }
}