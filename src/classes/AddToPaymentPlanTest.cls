/*
* @author Sirono
* @version 1.0.1
* @Date: 05-20-2016
* @ 08-31-2016 AddToPaymentPlanTest Class for the Code Covrege of AddToPaymentPlan class.
*/


@isTest
private class AddToPaymentPlanTest {
        
    //Code Coverage for pass all the validation
    
    /*Coverage the code for the AddToPaymentPlan class and init the variable,
     * call doNext,getActivePaymentPlan,submit,addToPaymentPlanCall,callPaymentPlanRequest
     * and doTesting,parseResponse Method.
     */                
    static testMethod void passAllValidation() {
        /*TestUtility objTestUtility = new TestUtility();
        
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
        
        //Create AddToPaymentPlan object and Call AddToPaymentPlan constructor and submit method.
        Apexpages.currentPage().getParameters().put('guarantorId',g.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId','121212');*/
        AddToPaymentPlan ppCon = new AddToPaymentPlan();
        /*
         /* Call Submit method and It will give an error "Please provide all details".
         * beacuse of we can't enter Charge Group.
         * It will cover code coverage of Else part in submit method.
         *
        ppCon.submit();
        
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
        
        //Create Charge Group record with different Charge Group ID.
        cg = TestUtility.generateChargeGroup(g.Id,null,121114);
        cg.Invoice__c = i.id;
        cg.Payment_Plan__c = t.Id;
        cg.Sirono_ID__c = 124;
        cg.Charge_Group_External_ID__c = true;
        insert cg;        
        
        //Create Transaction record.
        transactionObj = TestUtility.generateTransaction(cg ,100,'Automatic');
        insert transactionObj;
        
        //Create AddToPaymentPlan object and Call AddToPaymentPlan constructor.
        Apexpages.currentPage().getParameters().put('guarantorId',g.Id);
        ppCon = new AddToPaymentPlan();
        for(ChargeGroupWrapper cgw :ppCon.chrageGroupList){
            cgw.isSelected = true;
        }
        
        /* Call doNext method.
         * check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step. 
         *
        ppCon.doNext();
        
         /* Call Submit method and It will give an error "Please provide all details".
         * beacuse of we don not provide Web service releted information.
         * It will cover code coverage of Else part in submit method.
         *
        ppCon.submit();
        
        //Call cancel method.
        ppCon.cancel();
        
        //Check System Assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Please provide all details')) isError  = true;
        }
        System.assertEquals(isError,true);*/
    }
/*    
    //Code Coverage for pass all the validation
    /* Coverage the code for the AddToPaymentPlan class and init the variable,
     * call doNext,submit,addToPaymentPlanCall,callPaymentPlanRequest
     * and doTesting,parseResponse Method
     *                
    static testMethod void submit() {
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
        
        //Create AddToPaymentPlan object and Call AddToPaymentPlan constructor and submit method.
        Apexpages.currentPage().getParameters().put('guarantorId',g.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId','121212');
        AddToPaymentPlan ppCon = new AddToPaymentPlan();
        
        /* Call Submit method and It will give an error "Please provide all details".
         * beacuse of we can't enter Charge Group.
         * It will cover code coverage of Else part in submit method.
         *
        ppCon.submit();
                
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
        
        //Create Charge Group record with different Charge Group Id.
        cg = TestUtility.generateChargeGroup(g.Id,null,121114);
        cg.Invoice__c = i.id;
        cg.Payment_Plan__c = t.Id;
        cg.Sirono_ID__c = 124;
        cg.Charge_Group_External_ID__c = true;
        insert cg;
        
        //Create Transaction record.
        transactionObj = TestUtility.generateTransaction(cg ,100,'Automatic');
        insert transactionObj;
        
        //Create AddToPaymentPlan object and Call AddToPaymentPlan constructor.
        Apexpages.currentPage().getParameters().put('guarantorId',g.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId','121212');
        ppCon = new AddToPaymentPlan();
        for(ChargeGroupWrapper cgw :ppCon.chrageGroupList){
            cgw.isSelected = true;
        }
        
        /* Call doNext method.
         * check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step. 
         *
        ppCon.doNext();
        
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        TestUtility.responsebody =  PaymentPlanJSONParsing.testResponse();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        
        /* Call Submit method and It will successfully save the record.
         * Set variables for call the Webservice.
         * we get response message "Added Successfully".
         *
        ppCon.submit();
        
        //Check System Assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Added Successfully')) isError  = true;
        }
        System.assertEquals(isError,true);        
        Test.stopTest();
        
        //Check reponse we get from webservice and parse it to Json.
        ppCon.doTesting();  
        
    }
    
    //Code Coverage for pass all the validation
    /* Coverage the code for the AddToPaymentPlan class and init the variable,
     * call Cancel Method
     *             
    static testMethod void callPaymentPlanRequest() {
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
        
        //Create AddToPaymentPlan object and Call AddToPaymentPlan constructor.
        Apexpages.currentPage().getParameters().put('guarantorId',g.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId','121212');
        AddToPaymentPlan ppCon = new AddToPaymentPlan();
              
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
        
        //Create Charge Group record with different Charge Group Id.
        cg = TestUtility.generateChargeGroup(g.Id,null,121114);
        cg.Invoice__c = i.id;
        cg.Payment_Plan__c = t.Id;
        cg.Sirono_ID__c = 124;
        cg.Charge_Group_External_ID__c = true;
        insert cg;
        
        //Create Transaction record.        
        transactionObj = TestUtility.generateTransaction(cg ,100,'Automatic');
        insert transactionObj;
        
        //Create AddToPaymentPlan object and Call AddToPaymentPlan constructor.
        Apexpages.currentPage().getParameters().put('guarantorId',g.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId','121212');
        ppCon = new AddToPaymentPlan();
        for(ChargeGroupWrapper cgw :ppCon.chrageGroupList){
            cgw.isSelected = true;
        }
        
        /* Call doNext method.
         * check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step. 
         *
        ppCon.doNext();
        
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        TestUtility.responsebody =  'sadasds';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        
        /* Call Submit method and It will successfully save the record.
         * Set variables for call the Webservice.
         * we get response message "Added Successfully".
         *
        ppCon.submit();  
        
        //Check System Assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Added Successfully')) isError  = true;
        }
        System.assertEquals(isError,false);        
        Test.stopTest();
        
        //Check reponse we get from webservice and parse it to Json.
        ppCon.doTesting();
    }
    
    //Code Coverage for pass all the validation
    /* Coverage the code for the AddToPaymentPlan class and init the variable,
     * call Cancel,doNext,submit,addToPaymentPlanCall,doTesting and parseResponse Method
     *
    static testMethod void webServiceCallout() {
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
        
        //Create AddToPaymentPlan object and Call AddToPaymentPlan constructor and submit method.
        Apexpages.currentPage().getParameters().put('guarantorId',g.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId','121212');
        AddToPaymentPlan ppCon = new AddToPaymentPlan();
        
        /* Call Submit method and It will give an error "Please provide all details".
         * beacuse of we can't enter Charge Group.
         * It will cover code coverage of Else part in submit method.
         *
        ppCon.submit();
        
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
        
        //Create Charge Group record with different Charge Group Id.
        cg = TestUtility.generateChargeGroup(g.Id,null,121114);
        cg.Invoice__c = i.id;
        cg.Payment_Plan__c = t.Id;
        cg.Sirono_ID__c = 124;
        cg.Charge_Group_External_ID__c = true;
        insert cg;
        
        //Create Transaction record.
        transactionObj = TestUtility.generateTransaction(cg ,100,'Automatic');
        insert transactionObj;
        
        //Create AddToPaymentPlan object and Call AddToPaymentPlan constructor.
        Apexpages.currentPage().getParameters().put('guarantorId',g.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId','121212');
        ppCon = new AddToPaymentPlan();
        for(ChargeGroupWrapper cgw :ppCon.chrageGroupList){
            cgw.isSelected = true;
        }
        
        /* Call doNext method.
         * check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step. 
         *
        ppCon.doNext();
        
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        TestUtility.statusCode2 = 201;
        TestUtility.responsebody =  PaymentPlanJSONParsing.testResponse();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        
        /* Call Submit method and It will successfully save the record.
         * Set variables for call the Webservice.
         * we get response message "Added Successfully".
         *
        ppCon.submit();  
        
        //Check System Assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Added Successfully')) isError  = true;
        }
        System.assertEquals(isError,false);        
        Test.stopTest();
        
        //Check reponse we get from webservice and parse it to Json.
        ppCon.doTesting();   
        
    }
    
    //Code Coverage for pass all the validation
    /* Coverage the code for the AddToPaymentPlan class and init the variable,
     * call Cancel Method
     *
    static testMethod void cancel() {
        TestUtility objTestUtility = new TestUtility();
        
        //Create AddToPaymentPlan object and Call AddToPaymentPlan constructor.
        Apexpages.currentPage().getParameters().put('paymentPlanId','121212');
        AddToPaymentPlan ppCon = new AddToPaymentPlan();
        
        //Call cancel method and it will redirect to Contact page.
        PageReference pageRef = ppCon.cancel();
        
        //Check system assert.
        System.assertEquals('/'+ 121212,pageRef.getUrl());
    }
    
    //Code Coverage for pass all the validation
    /* Coverage the code for the AddToPaymentPlan class and init the variable,
     * call Cancel Method else part and 'guarantorRecordId' value not found
     *
    static testMethod void cancelElse() {
        TestUtility objTestUtility = new TestUtility();
        
        //Create AddToPaymentPlan object and Call AddToPaymentPlan constructor.
        AddToPaymentPlan ppCon = new AddToPaymentPlan();
        
        //Call cancel method and it will give an error beacuse of we can't add GuarantorId
        PageReference pageRef = ppCon.cancel();
        
        //Check system assert.
        System.assertEquals('/home/home.jsp',pageRef.getUrl());
    }*/
}