/*
* @author Sirono
* @version 1.0.1
* @Date: 05-12-2016
* @ Unit class  for the CreateAdjustment class.     
* Do the code coverage for the CreateAdjustment class with TestUtil method.
*/

@isTest
private class CreateAdjustmentTest {
    
    /*Coverage the code for the CreateAdjustment constructor, init the global variables,
     *doNext Method and Submit Method for the Validation Message.
     */
    static testMethod void callDoNextMethod() {
        CreateAdjustment obj = new CreateAdjustment();
        /*TestUtility  objUtility = new TestUtility();
        
        //Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;
        
        //Create Patient Contact record.
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;
        
        //Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.id);
        paymentPlan.active__c = true;
        paymentPlan.Delinquent__c = true;
        insert paymentPlan;
        
        //Create object of CreateAdjustment and call the Create Adjustment constructor & submit method.
        CreateAdjustment objCreateAdjustment = new CreateAdjustment(new ApexPages.StandardController(guarantorContact));
        objCreateAdjustment.submit();
        
        //Create Invoice record.
        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id,patientContact.Id);
        insert invoice;
        
        //Create Charge Group record.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id,null,121114);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Payment_Plan__c = paymentPlan.Id;
        chargeGroup.Charge_Group_External_ID__c = true;
        insert chargeGroup;
        
        //Create Charge Group record with different Sirono_ID__c.
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id,null,121114);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Payment_Plan__c = paymentPlan.Id;
        chargeGroup.Sirono_ID__c = 124;
        chargeGroup.Charge_Group_External_ID__c = true;
        insert chargeGroup;
        
        //Call Create Adjustment constructor with Selected charge group records and also call doNext, submit methods.
        objCreateAdjustment= new CreateAdjustment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objCreateAdjustment.chrageGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        
        /* check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step. 
         *
        objCreateAdjustment.doNext();
        
        //We select "Discount Adjustment" as a Adjustment Type from drop down.
        objCreateAdjustment.adjustmentTypeSelected = 'DIS';
        
        /* Call Submit method and It will give an error "Please provide all details".
         * beacuse of we can't enter Adjustment Amount.
         * It will cover code coverage of Else part in submit method.
         *
        objCreateAdjustment.submit();
        
        /* Check System Assert.
         * It will give an error "Please provide all details" beacuse of we can't enter Adjustment Amount.
         *
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Please provide all details.')) isError  = true;
        }
        System.assertEquals(isError,true);*/
    }
    
    /*Coverage the code for the CreateAdjustment constructor, init the global veriables,
     *doNext Method and Submit Method get jwtToken,csrfToken Token value.
     *            
    static testMethod void callEndpointRequestMethod() {
        TestUtility  objUtility = new TestUtility();
        
        //Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;
        
        //Create Patient Contact record.
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;
        
        //Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.id);
        paymentPlan.active__c = true;
        paymentPlan.Delinquent__c = true;
        insert paymentPlan;
        
        //Create User as a System Administrator.
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        string userName = 'adminuser@testorg1212.com.' + UserInfo.getUserName().substringAfterLast('.').toLowerCase();
        User u = new User(Alias = 'admin', Email='adminuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName=userName);
                
        System.runAs(u) {        
        //Create object of CreateAdjustment and call the Create Adjustment constructor.
        CreateAdjustment objCreateAdjustment = new CreateAdjustment(new ApexPages.StandardController(guarantorContact));
        
        //Create Invoice record.
        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id,patientContact.Id);
        insert invoice;
        
        //Create Charge Group record.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id,null,121114);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Payment_Plan__c = paymentPlan.Id;
        chargeGroup.Charge_Group_External_ID__c = true;
        insert chargeGroup;
        
        //Create Charge Group record with different Sirono_ID__c.
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id,null,121114);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Payment_Plan__c = paymentPlan.Id;
        chargeGroup.Sirono_ID__c = 124;
        chargeGroup.Charge_Group_External_ID__c = true;
        insert chargeGroup;
        
        //Call Create Adjustment constructor with Selected charge group with chargegroupId records and also call doNext, submit methods.
        objCreateAdjustment = new CreateAdjustment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objCreateAdjustment.chrageGroupList) {
            objChargeGroupWrapper.isSelected = true;
            objCreateAdjustment.chargegroupId = objChargeGroupWrapper.cg.ID; 
        }
        
        //We enter Adjustment Amount value = 10 and Adjustment Type = Auto.
        objCreateAdjustment.amount = '10';
        objCreateAdjustment.adjustmentTypeSelected = 'Auto';
        
        /* check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step.
         *
        objCreateAdjustment.doNext();
        
        //We select proper value for "Discount Adjustment" as a Adjustment Type from drop down.
        objCreateAdjustment.adjustmentTypeSelected = 'DIS';
        
        /* Call Submit method and It will give an error.
         * beacuse of we can't call webservice in this method.
         *        
        objCreateAdjustment.submit();
        
        //Check System Assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
	System.debug('msgList log: '+ msgList);
            System.assertEquals(2,msgList.size());
        }
    }
    
    /*Coverage the code for the CreateAdjustment constructor, init the global veriables,
     *doNext Method,Submit Method with exception and Call createAdjustmetWSCall method
     *     
    static testMethod void CallSubmitMethod() {
        TestUtility objTestUtility = new TestUtility();
        
        //Create Guarantor Contact record.
        Contact g = TestUtility.generateguarantorContact();
        insert g;
        
        //Create Patient Contact record.
        Contact p = TestUtility.generatePatientContact();
        insert p;
        
        //Create Payment Plan record.
        Payment_Plan__c t = TestUtility.generatePaymentPlan(g.Id);
        t.Active__c = true;
        insert t;
        
        //Create object of CreateAdjustment and call the Create Adjustment constructor & submit method based on Apex Parameter.
        Apexpages.currentPage().getParameters().put('guarantorId',g.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId','121212');
        CreateAdjustment objCreateAdjustment = new CreateAdjustment(new ApexPages.StandardController(g));
        
        /* Call Submit method and It will give an error.
         * beacuse of we can't enter Adjustment Amount and Adjustment Type.
         *
        objCreateAdjustment.submit();
        
        //Create Invoice record.
        Invoice__c i = TestUtility.generateInvoice(g.Id,p.Id);
        insert i;
        
        //Create Charge Group record.
        Charge_Group__c   cg = TestUtility.generateChargeGroup(g.Id,null,121114);
        cg.Invoice__c = i.id;
        cg.Payment_Plan__c = t.Id;
        cg.Charge_Group_External_ID__c = true;
        insert cg;
        
        //Create Transaction record.
        Transaction__c  transactionObj = TestUtility.generateTransaction(cg ,100,'Automatic');
        insert transactionObj;
        
        //Create Charge Group record with different Sirono_ID__c.
        cg = TestUtility.generateChargeGroup(g.Id,null,121114);
        cg.Invoice__c = i.id;
        cg.Payment_Plan__c = t.Id;
        cg.Sirono_ID__c = 124;
        cg.Charge_Group_External_ID__c = true;
        insert cg;        
        
        //Create Transaction record.
        transactionObj = TestUtility.generateTransaction(cg ,100,'Automatic');
        insert transactionObj;
        
        //Call Create Adjustment constructor with Selected charge group records and also call doNext methods.
        Apexpages.currentPage().getParameters().put('guarantorId',g.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId','121212');
        objCreateAdjustment = new CreateAdjustment(new ApexPages.StandardController(g));
        for(ChargeGroupWrapper cgw : objCreateAdjustment.chrageGroupList){
            cgw.isSelected = true;
        }
        
        /* check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step. 
         *
        objCreateAdjustment.doNext();
        
        //Call Submit Method and createAdjustmetWSCall method.
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        objCreateAdjustment.amount = '10';
        objCreateAdjustment.adjustmentTypeSelected = 'DIS';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        
        /* Call Submit method and It will successfully save the record.
         * We set all variables as per requirement to save the record.
         * Set variables for call the Webservice.
         * Set Adjustment Amount and Adjustment Type.
         *
        objCreateAdjustment.submit();
        
        /* Check System Assert.
         * We will received Created Successfully message.
         *
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Created Successfully!')) isError  = true;
        }
        System.assertEquals(isError,true);
        
        Test.stopTest();
    }
    
    /*Coverage the code for the CreateAdjustment constructor, init the global veriables,
     *doNext Method,Submit Method with exception and Call createAdjustmetWSCall method with response.
     *    
    static testMethod void submitElse() {
        TestUtility objTestUtility = new TestUtility();
        
        //Create Guarantor Contact record.
        Contact g = TestUtility.generateguarantorContact();
        insert g;
        
        //Create Patient Contact record.
        Contact p = TestUtility.generatePatientContact();
        insert p;
        
        //Create Payment Plan record.
        Payment_Plan__c t = TestUtility.generatePaymentPlan(g.Id);
        t.Active__c = true;
        insert t;
        
        //Create User as a System Administrator.
        Profile pro = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        string userName = 'adminuser@testorg1212.com.' + UserInfo.getUserName().substringAfterLast('.').toLowerCase();
        User u = new User(Alias = 'admin', Email='adminuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = pro.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName=userName);
        
        System.runAs(u) {        
        //Create object of CreateAdjustment and call the Create Adjustment constructor & submit method based on Apex Parameter.
        Apexpages.currentPage().getParameters().put('guarantorId',g.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId','121212');
        CreateAdjustment objCreateAdjustment = new CreateAdjustment(new ApexPages.StandardController(g));
        
        /* Call Submit method and It will give an error.
         * beacuse of we can't enter Adjustment Amount and Adjustment Type.
         *
        objCreateAdjustment.submit();

        //Create Invoice record.
        Invoice__c i = TestUtility.generateInvoice(g.Id,p.Id);
        insert i;
        
        //Create Charge Group record.
        Charge_Group__c   cg = TestUtility.generateChargeGroup(g.Id,null,121114);
        cg.Invoice__c = i.id;
        cg.Payment_Plan__c = t.Id;
        cg.Charge_Group_External_ID__c = true;
        insert cg;
        
        //Create Transaction record.
        Transaction__c  transactionObj = TestUtility.generateTransaction(cg ,100,'Automatic');
        insert transactionObj;
        
        //Create Charge Group record with different Sirono_ID__c.
        cg = TestUtility.generateChargeGroup(g.Id,null,121114);
        cg.Invoice__c = i.id;
        cg.Payment_Plan__c = t.Id;
        cg.Sirono_ID__c = 124;
        cg.Charge_Group_External_ID__c = true;
        insert cg;        
        
        //Create Transaction record.
        transactionObj = TestUtility.generateTransaction(cg ,100,'Automatic');
        insert transactionObj;
        
        //Call Create Adjustment constructor with Selected charge group records and also call doNext methods
        Apexpages.currentPage().getParameters().put('guarantorId',g.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId','121212');
        objCreateAdjustment = new CreateAdjustment(new ApexPages.StandardController(g));
        for(ChargeGroupWrapper cgw : objCreateAdjustment.chrageGroupList){
            cgw.isSelected = true;
        }
        
        /* check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step. 
         *
        objCreateAdjustment.doNext();
        
        //Call Submit Method and createAdjustmetWSCall method.
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 202;
        objCreateAdjustment.amount = '10';
        objCreateAdjustment.adjustmentTypeSelected = 'DIS';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        
        /* Call Submit method and It will give an error.
         * Beacuse of we set the different parameter for webservice to cover code of Else part in Submit method.
         *
        objCreateAdjustment.submit();  
        
        //Check System Assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
	System.debug('msgList log: '+ msgList);
            System.assertEquals(4 ,msgList.size());
        
        Test.stopTest();
        }
    }
    
    /*Coverage the code for the CreateAdjustment constructor, init the global veriables*
    public static testMethod void testRunAs() {
        /* Setup test data
         * This code runs as the system user
         * Get profile record for Standard User and create User based on this profile.
         *        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg1212.com');
        
        //Call Create Adjustment constructor as a Standard user to cover code based on user.
        System.runAs(u) {
            Contact g = TestUtility.generateguarantorContact();
            insert g;
        
            CreateAdjustment objCreateAdjustment = new CreateAdjustment(new ApexPages.StandardController(g));
        }
   }*/
}