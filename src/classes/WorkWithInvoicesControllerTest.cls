@isTest
private class WorkWithInvoicesControllerTest {
	@isTest static void invoicesTest() {
		Contact guarantorContact;
		Contact patientContact;
		User internalUser;
		Invoice__c invoice1;

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
            Username = String.valueOf(System.now().millisecond()) + 'test.user.invoice@example.com', 
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

	  		Payment_Plan__c pPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
	  		insert pPlan;

	  		List<Invoice__c> lstInvoice = new List<Invoice__c>();
	  		invoice1 = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
	        lstInvoice.add(invoice1);

	        Invoice__c invoice2 = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
	        lstInvoice.add(invoice2);

	        Invoice__c invoice3 = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
	        invoice3.Invoice_Status_Index__c = 2;
	        lstInvoice.add(invoice3);

	        insert lstInvoice;

	        List<Charge_Group__c> lstChrgGroup = new List<Charge_Group__c>();
	        Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 1234, pPlan.Id);
	        chargeGroup1.Invoice__c = invoice1.Id;
	        lstChrgGroup.add(chargeGroup1);

	        Charge_Group__c chargeGroup2 = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 1234, pPlan.Id);
	        chargeGroup2.Invoice__c = invoice2.Id;
	        lstChrgGroup.add(chargeGroup2);
	        insert lstChrgGroup;

	        Payor__c payorTest = new Payor__c(
	        	Name = 'payotTest'
	        );
	        insert payorTest;

	        Coverage__c objcoverage = new Coverage__c(
	        	Name = 'Test',
	        	Payor__c = payorTest.Id 
	        );
	        insert objcoverage;
	        
	        Charge_Group_Coverage_Junction__c objCGCoverage = new Charge_Group_Coverage_Junction__c();
	        objCGCoverage.Name = 'Test';
	        objCGCoverage.Charge_Group__c = chargeGroup1.Id;
	        objCGCoverage.Coverage__c = objcoverage.Id;
	        insert objCGCoverage;

	        Service__c serviceTest = new Service__c(
	        	Name = 'serviceTest',
	        	Charge_Group__c	= chargeGroup2.Id
	        );
	        insert serviceTest;

	        Payment_Adjustments__c paymentAdjTest = new Payment_Adjustments__c(
	        	Name = 'paymentAdjTest',
	        	Charge_Group__c = chargeGroup2.Id
	        );
	        insert paymentAdjTest;

	        Payment__c payment1 = TestUtility.generateSironoPayment(guarantorContact.Id, 1234, 12);
	        Payment__c payment2 = TestUtility.generateSironoPayment(guarantorContact.Id, 1235, 25);
	        List<Payment__c> lstPayment = new List<Payment__c>{payment1, payment2};
	        insert lstPayment;

	        List<Transaction__c> lstTransaction = new List<Transaction__c>();
	        Transaction__c transaction1 = TestUtility.generatePaymentTxn(chargeGroup1, 20, payment1);
	        lstTransaction.add(transaction1);

	        Transaction__c transaction2 = TestUtility.generatePaymentTxn(chargeGroup1, 200, payment2);
	        lstTransaction.add(transaction2);

	        Transaction__c transaction3 = TestUtility.generateServiceTxn(chargeGroup2, 20, serviceTest);
	        lstTransaction.add(transaction3);

	        Transaction__c transaction4 = TestUtility.generateServiceTxn(chargeGroup2, 200, serviceTest);
	        lstTransaction.add(transaction4);

	        Transaction__c transaction5 = TestUtility.generateAdjTxn(chargeGroup2, 200, paymentAdjTest);
	        lstTransaction.add(transaction5);
	        insert lstTransaction;

	        invoice1.Invoice_Status_Index__c = 9;
	        invoice2.Invoice_Status_Index__c = 4;
	        List<Invoice__c> lstInvoiceUpdate = new List<Invoice__c>{invoice1, invoice2};
	        update lstInvoiceUpdate;
		}

		List<WorkWithInvoicesController.PatientWrapper> patientList = WorkWithInvoicesController.getPatientList();
		System.assertEquals(patientList.size(), 0);	

		System.runAs(internalUser) {
        	Test.startTest();

        	List<WorkWithInvoicesController.InvoicesWrapper> invoiceList = WorkWithInvoicesController.getAllInvoices('Unpaid', patientContact.Id);
        	System.assertEquals(invoiceList.size(), 1);
        	invoiceList = WorkWithInvoicesController.getAllInvoices('Paid', patientContact.Id);
        	System.assertEquals(invoiceList.size(), 1);
        	invoiceList = WorkWithInvoicesController.getAllInvoices('Unknown', patientContact.Id);
        	System.assertEquals(invoiceList.size(), 1);
        	invoiceList = WorkWithInvoicesController.getAllInvoices('Unknown', 'null');
        	System.assertEquals(invoiceList.size(), 0);
        	invoiceList = WorkWithInvoicesController.getInvoice(invoice1.Id);
        	System.assertEquals(invoiceList.size(), 1);

        	patientList = WorkWithInvoicesController.getPatientList();
        	System.assertEquals(patientList.size(), 3);

        	Test.stopTest();
        }
	}

	@isTest static void estimatesTest() {
		Contact guarantorContact;
		Contact patientContact;
		User internalUser;
		Encounter__c encounter1;

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
            Username = String.valueOf(System.now().millisecond()) + 'test.user.invoice2@example.com', 
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
	            WHERE name = 'Guarantor'
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
	  		encounter1 = TestUtility.generateEncounter(guarantorContact.Id, 10, Date.today());
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

        System.runAs(internalUser) {
        	Test.startTest();

        	List<WorkWithEstimatesController.EstimateWrapper> estimateList = WorkWithInvoicesController.getAllEstimates('Unpaid', patientContact.Id);
        	System.assertEquals(estimateList.size(), 1);
        	estimateList = WorkWithInvoicesController.getAllEstimates('Paid', 'null');
        	System.assertEquals(estimateList.size(), 0);
        	estimateList = WorkWithInvoicesController.getEstimate(encounter1.Id);
        	System.assertEquals(estimateList.size(), 1);

        	Test.stopTest();
        }
	}
}