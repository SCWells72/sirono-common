@isTest
private class AddToPaymentPlanLightningTest {

    //Code Coverage for pass all the validation

    /*Coverage the code for the AddToPaymentPlan class and init the variable,
     * call doNext,getActivePaymentPlan,submit,addToPaymentPlanCall,callPaymentPlanRequest
     * and doTesting,parseResponse Method.
     */
    static testMethod void passAllValidation() {
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
        AddToPaymentPlanLightning ppCon = new AddToPaymentPlanLightning(g.Id);

         /* Call Submit method and It will give an error "Please provide all details".
         * beacuse of we can't enter Charge Group.
         * It will cover code coverage of Else part in submit method.
         */
        ppCon.submit();

        //Check System Assert.
        System.assertEquals(ppCon.errorMessage.contains('Please provide all details'), true);

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
        ppCon = new AddToPaymentPlanLightning(g.Id);
        for(ChargeGroupWrapper cgw :ppCon.chargeGroupList){
            cgw.isSelected = true;
        }

        /* Call doNext method.
         * check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step.
         */
        ppCon.doNext();

         /* Call Submit method and It will give an error "Please provide all details".
         * beacuse of we don not provide Web service releted information.
         * It will cover code coverage of Else part in submit method.
         */
        ppCon.submit();

        //Check System Assert.
        System.assertEquals(ppCon.errorMessage.contains('Please provide all details'), false);
    }

    //Code Coverage for pass all the validation
    /* Coverage the code for the AddToPaymentPlan class and init the variable,
     * call doNext,submit,addToPaymentPlanCall,callPaymentPlanRequest
     * and doTesting,parseResponse Method
     */
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
        Apexpages.currentPage().getParameters().put('paymentPlanExtId','121212');
        AddToPaymentPlanLightning ppCon = new AddToPaymentPlanLightning(g.Id);

        /* Call Submit method and It will give an error "Please provide all details".
         * beacuse of we can't enter Charge Group.
         * It will cover code coverage of Else part in submit method.
         */
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
        Apexpages.currentPage().getParameters().put('paymentPlanExtId','121212');
        ppCon = new AddToPaymentPlanLightning(g.Id);
        for(ChargeGroupWrapper cgw :ppCon.chargeGroupList){
            cgw.isSelected = true;
        }

        /* Call doNext method.
         * check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step.
         */
        ppCon.doNext();

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        TestUtility.responsebody =  PaymentPlanJSONParsing.testResponse();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());

        /* Call Submit method and It will successfully save the record.
         * Set variables for call the Webservice.
         * we get response message "Added Successfully".
         */
        ppCon.submit();

        //Check System Assert.
        boolean isError = false;
        if (ppCon.errorMessage.contains('Added Successfully')) isError  = true;
        System.assertEquals(isError,true);
        Test.stopTest();

        //Check reponse we get from webservice and parse it to Json.
        ppCon.doTesting();

    }

    //Code Coverage for pass all the validation
    /* Coverage the code for the AddToPaymentPlan class and init the variable,
     * call Cancel Method
     */
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
        Apexpages.currentPage().getParameters().put('paymentPlanExtId','121212');
        AddToPaymentPlanLightning ppCon = new AddToPaymentPlanLightning(g.Id);

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
        Apexpages.currentPage().getParameters().put('paymentPlanExtId','121212');
        ppCon = new AddToPaymentPlanLightning(g.Id);
        for(ChargeGroupWrapper cgw :ppCon.chargeGroupList){
            cgw.isSelected = true;
        }

        /* Call doNext method.
         * check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step.
         */
        ppCon.doNext();

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        TestUtility.responsebody =  'sadasds';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());

        /* Call Submit method and It will successfully save the record.
         * Set variables for call the Webservice.
         * we get response message "Added Successfully".
         */
        ppCon.submit();

        //Check System Assert.
        boolean isError = false;
        if (ppCon.errorMessage.contains('Added Successfully')) isError  = true;
        System.assertEquals(isError,false);
        Test.stopTest();

        //Check reponse we get from webservice and parse it to Json.
        ppCon.doTesting();
    }

    //Code Coverage for pass all the validation
    /* Coverage the code for the AddToPaymentPlan class and init the variable,
     * call Cancel,doNext,submit,addToPaymentPlanCall,doTesting and parseResponse Method
     */
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
        Apexpages.currentPage().getParameters().put('paymentPlanExtId','121212');
        AddToPaymentPlanLightning ppCon = new AddToPaymentPlanLightning(g.Id);

        /* Call Submit method and It will give an error "Please provide all details".
         * beacuse of we can't enter Charge Group.
         * It will cover code coverage of Else part in submit method.
         */
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
        Apexpages.currentPage().getParameters().put('paymentPlanExtId','121212');
        ppCon = new AddToPaymentPlanLightning(g.Id);
        for(ChargeGroupWrapper cgw :ppCon.chargeGroupList){
            cgw.isSelected = true;
        }

        /* Call doNext method.
         * check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step.
         */
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
         */
        ppCon.submit();

        //Check System Assert.
        boolean isError = false;
        if (ppCon.errorMessage.contains('Added Successfully')) isError  = true;
        System.assertEquals(isError,false);
        Test.stopTest();

        //Check reponse we get from webservice and parse it to Json.
        ppCon.doTesting();

    }
}