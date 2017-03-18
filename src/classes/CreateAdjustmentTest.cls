/**
 * Unit class for the CreateAdjustment class.
 **/

@isTest
private class CreateAdjustmentTest {
    
    /**
     * Coverage the code for the CreateAdjustment constructor, init the global variables,
     * doNext Method and Submit Method for the Validation Message.
     **/
    static testMethod void callDoNextMethod() {
        // Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        // Create Patient Contact record.
        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;

        // Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.id);
        paymentPlan.active__c = true;
        paymentPlan.Delinquent__c = true;
        INSERT paymentPlan;

        // Create object of CreateAdjustment and call the Create Adjustment constructor & submit method.
        CreateAdjustment objCreateAdjustment = new CreateAdjustment(new ApexPages.StandardController(guarantorContact));
        objCreateAdjustment.submit();

        // Create Invoice record.
        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
        INSERT invoice;

        // Create Charge Group record.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Payment_Plan__c = paymentPlan.Id;
        chargeGroup.Charge_Group_External_ID__c = true;
        INSERT chargeGroup;

        // Create Charge Group record with different Sirono_ID__c.
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Payment_Plan__c = paymentPlan.Id;
        chargeGroup.Sirono_ID__c = 124;
        chargeGroup.Charge_Group_External_ID__c = true;
        INSERT chargeGroup;

        // Call Create Adjustment constructor with Selected charge group records and also call doNext, submit methods.
        objCreateAdjustment = new CreateAdjustment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objCreateAdjustment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        
        Test.startTest();

        // check any chargegroup is selected or not.
        // We select all charge groups in above so this method is run successfully and will proceed next step.
        objCreateAdjustment.doNext();

        // We select "Discount Adjustment" as a Adjustment Type from drop down.
        objCreateAdjustment.adjustmentTypeSelected = 'DIS';
        
        // Call Submit method and It will give an error "Please provide all details".
        // beacuse of we can't enter Adjustment Amount.
        // It will cover code coverage of Else part in submit method.
        objCreateAdjustment.submit();
        
        Test.stopTest();

        // Check System Assert.
        // It will give an error "Please provide all details" beacuse of we can't enter Adjustment Amount.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains('Please provide all details.')) isError = true;
        }
        System.assert(isError, 'Missing required details & arithmetic rule violation throws an Exception during create adjustment process.');
    }
    
    /**
     * Coverage the code for the CreateAdjustment constructor, init the global veriables,
     * doNext Method and Submit Method get jwtToken, csrfToken Token value.
     **/
    static testMethod void callEndpointRequestMethod() {
        // Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        // Create Patient Contact record.
        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;

        // Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.id);
        paymentPlan.active__c = true;
        paymentPlan.Delinquent__c = true;
        INSERT paymentPlan;

        // Create User as a System Administrator.
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        string userName = 'adminuser@testorg1212.com.' + UserInfo.getUserName().substringAfterLast('.').toLowerCase();
        User u = new User(Alias = 'admin', Email = 'adminuser@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = userName);

        System.runAs(u) {
            // Create object of CreateAdjustment and call the Create Adjustment constructor.
            CreateAdjustment objCreateAdjustment = new CreateAdjustment(new ApexPages.StandardController(guarantorContact));

            // Create Invoice record.
            Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
            INSERT invoice;

            // Create Charge Group record.
            Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
            chargeGroup.Invoice__c = invoice.id;
            chargeGroup.Payment_Plan__c = paymentPlan.Id;
            chargeGroup.Charge_Group_External_ID__c = true;
            INSERT chargeGroup;

            // Create Charge Group record with different Sirono_ID__c.
            chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
            chargeGroup.Invoice__c = invoice.id;
            chargeGroup.Payment_Plan__c = paymentPlan.Id;
            chargeGroup.Sirono_ID__c = 124;
            chargeGroup.Charge_Group_External_ID__c = true;
            INSERT chargeGroup;

            // Call Create Adjustment constructor with Selected charge group with chargegroupId records and also call doNext, submit methods.
            objCreateAdjustment = new CreateAdjustment(new ApexPages.StandardController(guarantorContact));
            for (ChargeGroupWrapper objChargeGroupWrapper : objCreateAdjustment.chargeGroupList) {
                objChargeGroupWrapper.isSelected = true;
                objCreateAdjustment.chargegroupId = objChargeGroupWrapper.cg.ID;
            }

            Test.startTest();
            // We enter Adjustment Amount value = 10 and Adjustment Type = Auto.
            objCreateAdjustment.amount = '10';
            objCreateAdjustment.adjustmentTypeSelected = 'Auto';
        
            // check any chargegroup is selected or not.
            // We select all charge groups in above so this method is run successfully and will proceed next step.
            objCreateAdjustment.doNext();

            // We select proper value for "Discount Adjustment" as a Adjustment Type from drop down.
            objCreateAdjustment.adjustmentTypeSelected = 'DIS';
        
            // Call Submit method and It will give an error.
            // beacuse of we can't call webservice in this method.
            objCreateAdjustment.submit();
            Test.stopTest();

            // Check System Assert, Exception occures during create adjustment process because missing or bad requires.
            List<ApexPages.Message> msgList = ApexPages.getMessages();
	    Boolean isError = false;
	    for (Apexpages.Message msg: msgList) {
	        if (msg.getDetail().contains('JWT EXCEPTION')) isError = true;
	    }
            System.assert(isError, 'JWT_Token Exception during create adjustment process.');
        }
    }
    
    /**
     * Coverage the code for the CreateAdjustment constructor, init the global veriables,
     * doNext Method,Submit Method with exception and Call createAdjustmetWSCall method
     **/
    static testMethod void CallSubmitMethod() {
        // Create Guarantor Contact record.
        Contact g = TestUtility.generateguarantorContact();
        INSERT g;

        // Create Patient Contact record.
        Contact p = TestUtility.generatePatientContact();
        INSERT p;

        // Create Payment Plan record.
        Payment_Plan__c t = TestUtility.generatePaymentPlan(g.Id);
        t.Active__c = true;
        INSERT t;

        // Create object of CreateAdjustment and call the Create Adjustment constructor & submit method based on Apex Parameter.
        Apexpages.currentPage().getParameters().put('guarantorId', g.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId', '121212');
        CreateAdjustment objCreateAdjustment = new CreateAdjustment(new ApexPages.StandardController(g));
        
        // Call Submit method and It will give an error.
        // beacuse of we can't enter Adjustment Amount and Adjustment Type.
        objCreateAdjustment.submit();

        // Create Invoice record.
        Invoice__c i = TestUtility.generateInvoice(g.Id, p.Id);
        INSERT i;

        // Create Charge Group record.
        Charge_Group__c cg = TestUtility.generateChargeGroup(g.Id, null, 121114);
        cg.Invoice__c = i.id;
        cg.Payment_Plan__c = t.Id;
        cg.Charge_Group_External_ID__c = true;
        INSERT cg;

        // Create Transaction record.
        Transaction__c transactionObj = TestUtility.generateTransaction(cg, 100, 'Automatic');
        INSERT transactionObj;

        // Create Charge Group record with different Sirono_ID__c.
        cg = TestUtility.generateChargeGroup(g.Id, null, 121114);
        cg.Invoice__c = i.id;
        cg.Payment_Plan__c = t.Id;
        cg.Sirono_ID__c = 124;
        cg.Charge_Group_External_ID__c = true;
        INSERT cg;

        // Create Transaction record.
        transactionObj = TestUtility.generateTransaction(cg, 100, 'Automatic');
        INSERT transactionObj;

        // Call Create Adjustment constructor with Selected charge group records and also call doNext methods.
        Apexpages.currentPage().getParameters().put('guarantorId', g.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId', '121212');
        objCreateAdjustment = new CreateAdjustment(new ApexPages.StandardController(g));
        for (ChargeGroupWrapper cgw : objCreateAdjustment.chargeGroupList) {
            cgw.isSelected = true;
        }
        
        // check any chargegroup is selected or not.
        // We select all charge groups in above so this method is run successfully and will proceed next step.
        objCreateAdjustment.doNext();

        // Call Submit Method and createAdjustmetWSCall method.
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        objCreateAdjustment.amount = '10';
        objCreateAdjustment.adjustmentTypeSelected = 'DIS';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        
        // Call Submit method and It will successfully save the record.
        // We set all variables as per requirement to save the record.
        // Set variables for call the Webservice.
        // Set Adjustment Amount and Adjustment Type.
        objCreateAdjustment.submit();
        Test.stopTest();
        
        // Check System Assert.
        // We will received Created Successfully message.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isSuccess = false;
        for (Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains('Created Successfully!')) isSuccess = true;
        }
        System.assert(isSuccess, 'Adjustment got created.');
    }
    
    /**
     * Coverage the code for the CreateAdjustment constructor, init the global veriables,
     * doNext Method,Submit Method with exception and Call createAdjustmetWSCall method with response.
     **/
    static testMethod void submitElse() {
        // Create Guarantor Contact record.
        Contact g = TestUtility.generateguarantorContact();
        INSERT g;

        // Create Patient Contact record.
        Contact p = TestUtility.generatePatientContact();
        INSERT p;

        // Create Payment Plan record.
        Payment_Plan__c t = TestUtility.generatePaymentPlan(g.Id);
        t.Active__c = true;
        INSERT t;

        // Create User as a System Administrator.
        Profile pro = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        String userName = 'adminuser@testorg1212.com.' + UserInfo.getUserName().substringAfterLast('.').toLowerCase();
        User u = new User(Alias = 'admin', Email = 'adminuser@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = pro.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = userName);

        System.runAs(u) {
            // Create object of CreateAdjustment and call the Create Adjustment constructor & submit method based on Apex Parameter.
            Apexpages.currentPage().getParameters().put('guarantorId', g.Id);
            Apexpages.currentPage().getParameters().put('paymentPlanExtId', '121212');
            CreateAdjustment objCreateAdjustment = new CreateAdjustment(new ApexPages.StandardController(g));
        
            // Call Submit method and It will give an error.
            // beacuse of we can't enter Adjustment Amount and Adjustment Type.
            objCreateAdjustment.submit();

            // Create Invoice record.
            Invoice__c i = TestUtility.generateInvoice(g.Id, p.Id);
            INSERT i;

            // Create Charge Group record.
            Charge_Group__c cg = TestUtility.generateChargeGroup(g.Id, null, 121114);
            cg.Invoice__c = i.id;
            cg.Payment_Plan__c = t.Id;
            cg.Charge_Group_External_ID__c = true;
            INSERT cg;

            // Create Transaction record.
            Transaction__c transactionObj = TestUtility.generateTransaction(cg, 100, 'Automatic');
            INSERT transactionObj;

            // Create Charge Group record with different Sirono_ID__c.
            cg = TestUtility.generateChargeGroup(g.Id, null, 121114);
            cg.Invoice__c = i.id;
            cg.Payment_Plan__c = t.Id;
            cg.Sirono_ID__c = 124;
            cg.Charge_Group_External_ID__c = true;
            INSERT cg;

            // Create Transaction record.
            transactionObj = TestUtility.generateTransaction(cg, 100, 'Automatic');
            INSERT transactionObj;

            // Call Create Adjustment constructor with Selected charge group records and also call doNext methods
            Apexpages.currentPage().getParameters().put('guarantorId', g.Id);
            Apexpages.currentPage().getParameters().put('paymentPlanExtId', '121212');
            objCreateAdjustment = new CreateAdjustment(new ApexPages.StandardController(g));
            for (ChargeGroupWrapper cgw : objCreateAdjustment.chargeGroupList) {
                cgw.isSelected = true;
            }
        
            // check any chargegroup is selected or not.
            // We select all charge groups in above so this method is run successfully and will proceed next step.
            objCreateAdjustment.doNext();

            // Call Submit Method and createAdjustmetWSCall method.
            Test.startTest();
            TestUtility.status = 'CREATED';
            TestUtility.statusCode = 202;
            objCreateAdjustment.amount = '10';
            objCreateAdjustment.adjustmentTypeSelected = 'DIS';
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        
            // Call Submit method and It will give an error.
     	    // Beacuse of we set the different parameter for webservice to cover code of Else part in Submit method.
            objCreateAdjustment.submit();
            Test.stopTest();

            // Check system assert, Missing required details & arithmetic rule violation should throw an exception.
	    List<ApexPages.Message> msgList = ApexPages.getMessages();
	    Boolean isError = false;
	    for (Apexpages.Message msg: msgList) {
	        if (msg.getDetail().contains('Please provide all details.')) isError = true;
	    }
	    System.assert(isError, 'Missing required details & arithmetic rule violation throws an Exception during create adjustment process.');
        }
    }
    
    /**
     * Coverage the code for the CreateAdjustment constructor, init the global veriables
     **/
    public static testMethod void checkConstructorLogic() {
        // Setup test data
        // This code runs as the system user
        // Get profile record for System Administrator and create User based on this profile.
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'standt', Email = 'adminuser@testorg1212.com',
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'adminuser@testorg1212.com');

        // Call Create Adjustment constructor as a System Administrator to cover code based on user.
        System.runAs(u) {
            Contact g = TestUtility.generateguarantorContact();
            INSERT g;

            Test.startTest();
            CreateAdjustment objCreateAdjustment = new CreateAdjustment(new ApexPages.StandardController(g));
            Test.stopTest();
        }

        // Check System Assert. We got Error message Amount must be Greater than Zero.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains(System.Label.Adjustment_for_Admin)) {
                isError = true;
            }
        }
        System.assert(!isError, 'We got error message');
   }
}
