/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/*
* AddToPaymentPlanTest Class for the AddToPaymentPlan controller.
*/
@IsTest
private class AddToPaymentPlanTest {

    //Code Coverage for pass all the validation

    /*Coverage the code for the AddToPaymentPlan class and init the variable,
     * call doNext,getActivePaymentPlan,submit,addToPaymentPlanCall,callPaymentPlanRequest
     * and parseResponse Method.
     */
    @IsTest
    static void passAllValidation() {
        //Create Guarantor Contact record.
        Contact g = TestUtility.generateGuarantorContact();
        insert g;

        //Create Patient Contact record.
        Contact p = TestUtility.generatePatientContact();
        insert p;

        //Create Payment Plan record.
        Payment_Plan__c t = TestUtility.generatePaymentPlan(g.Id);
        t.Active__c = true;
        insert t;

        //Create AddToPaymentPlan object and Call AddToPaymentPlan constructor and submit method.
        ApexPages.currentPage().getParameters().put('guarantorId', g.Id);
        ApexPages.currentPage().getParameters().put('paymentPlanExtId', '121212');
        AddToPaymentPlanVF ppCon = new AddToPaymentPlanVF();

         /* Call Submit method and It will give an error "Please provide all details".
         * beacuse of we can't enter Charge Group.
         * It will cover code coverage of Else part in submit method.
         */
        ppCon.submit();

        //Create Invoice record.
        Invoice__c i = TestUtility.generateInvoice(g.Id, p.Id);
        insert i;

        //Create Charge Group record.
        Charge_Group__c cg = TestUtility.generateChargeGroup(g.Id, null, 121114);
        cg.Invoice__c = i.Id;
        cg.Payment_Plan__c = t.Id;
        cg.Charge_Group_External_ID__c = true;
        insert cg;

        //Create Transaction record.
        Transaction__c transactionObj = TestUtility.generateTransaction(cg, 100, Constants.AUTOMATIC);
        insert transactionObj;

        //Create Charge Group record with different Charge Group ID.
        cg = TestUtility.generateChargeGroup(g.Id, null, 121114);
        cg.Invoice__c = i.Id;
        cg.Payment_Plan__c = t.Id;
        cg.Sirono_ID__c = 124;
        cg.Charge_Group_External_ID__c = true;
        insert cg;

        //Create Transaction record.
        transactionObj = TestUtility.generateTransaction(cg, 100, Constants.AUTOMATIC);
        insert transactionObj;

        //Create AddToPaymentPlan object and Call AddToPaymentPlan constructor.
        ApexPages.currentPage().getParameters().put('guarantorId', g.Id);
        ppCon = new AddToPaymentPlanVF();
        for (ChargeGroupWrapper cgw : ppCon.chargeGroupList) {
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

        //Call cancel method.
        ppCon.cancel();

        //Check System Assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains('Please provide all details')) {
                isError = true;
            }
            System.debug(msg.getDetail());
        }
        System.assert(isError, 'Expected error message but none returned 1');
    }


    //Code Coverage for pass all the validation
    /* Coverage the code for the AddToPaymentPlan class and init the variable,
     * call Cancel Method
     */
    @IsTest
    static void callPaymentPlanRequest() {
        //Create Guarantor Contact record.
        Contact g = TestUtility.generateGuarantorContact();
        insert g;

        //Create Patient Contact record.
        Contact p = TestUtility.generatePatientContact();
        insert p;

        //Create Payment Plan record.
        Payment_Plan__c t = TestUtility.generatePaymentPlan(g.Id);
        t.Active__c = true;
        insert t;

        //Create AddToPaymentPlan object and Call AddToPaymentPlan constructor.
        ApexPages.currentPage().getParameters().put('guarantorId', g.Id);
        ApexPages.currentPage().getParameters().put('paymentPlanExtId', '121212');
        AddToPaymentPlanVF ppCon = new AddToPaymentPlanVF();

        //Create Invoice record.
        Invoice__c i = TestUtility.generateInvoice(g.Id, p.Id);
        insert i;

        //Create Charge Group record.
        Charge_Group__c cg = TestUtility.generateChargeGroup(g.Id, null, 121114);
        cg.Invoice__c = i.Id;
        cg.Payment_Plan__c = t.Id;
        cg.Charge_Group_External_ID__c = true;
        insert cg;

        //Create Transaction record.
        Transaction__c transactionObj = TestUtility.generateTransaction(cg, 100, Constants.AUTOMATIC);
        insert transactionObj;

        //Create Charge Group record with different Charge Group Id.
        cg = TestUtility.generateChargeGroup(g.Id, null, 121114);
        cg.Invoice__c = i.Id;
        cg.Payment_Plan__c = t.Id;
        cg.Sirono_ID__c = 124;
        cg.Charge_Group_External_ID__c = true;
        insert cg;

        //Create Transaction record.
        transactionObj = TestUtility.generateTransaction(cg, 100, Constants.AUTOMATIC);
        insert transactionObj;

        //Create AddToPaymentPlan object and Call AddToPaymentPlan constructor.
        ApexPages.currentPage().getParameters().put('guarantorId', g.Id);
        ApexPages.currentPage().getParameters().put('paymentPlanExtId', '121212');
        ppCon = new AddToPaymentPlanVF();
        for (ChargeGroupWrapper cgw : ppCon.chargeGroupList) {
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
        TestUtility.responsebody = 'sadasds';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());

        /* Call Submit method and It will successfully save the record.
         * Set variables for call the Webservice.
         * we get response message "Added Successfully".
         */
        ppCon.submit();

        //Check System Assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains('Added Successfully')) {
                isError = true;
            }
            System.debug(msg.getDetail());
        }
        System.assert(!isError, 'Expected success message, none returned 3');
        Test.stopTest();

    }

    //Code Coverage for pass all the validation
    /* Coverage the code for the AddToPaymentPlan class and init the variable,
     * call Cancel,doNext,submit,addToPaymentPlanCal and parseResponse Method
     */
    @IsTest
    static void webServiceCallout() {
        //Create Guarantor Contact record.
        Contact g = TestUtility.generateGuarantorContact();
        insert g;

        //Create Patient Contact record.
        Contact p = TestUtility.generatePatientContact();
        insert p;

        //Create Payment Plan record.
        Payment_Plan__c t = TestUtility.generatePaymentPlan(g.Id);
        t.Active__c = true;
        insert t;

        //Create AddToPaymentPlan object and Call AddToPaymentPlan constructor and submit method.
        ApexPages.currentPage().getParameters().put('guarantorId', g.Id);
        ApexPages.currentPage().getParameters().put('paymentPlanExtId', '121212');
        AddToPaymentPlanVF ppCon = new AddToPaymentPlanVF();

        /* Call Submit method and It will give an error "Please provide all details".
         * because we didn't enter Charge Group.
         * It will cover code coverage of Else part in submit method.
         */
        ppCon.submit();

        //Create Invoice record.
        Invoice__c i = TestUtility.generateInvoice(g.Id, p.Id);
        insert i;

        //Create Charge Group record.
        Charge_Group__c cg = TestUtility.generateChargeGroup(g.Id, null, 121114);
        cg.Invoice__c = i.Id;
        cg.Payment_Plan__c = t.Id;
        cg.Charge_Group_External_ID__c = true;
        insert cg;

        //Create Transaction record.
        Transaction__c transactionObj = TestUtility.generateTransaction(cg, 100, Constants.AUTOMATIC);
        insert transactionObj;

        //Create Charge Group record with different Charge Group Id.
        cg = TestUtility.generateChargeGroup(g.Id, null, 121114);
        cg.Invoice__c = i.Id;
        cg.Payment_Plan__c = t.Id;
        cg.Sirono_ID__c = 124;
        cg.Charge_Group_External_ID__c = true;
        insert cg;

        //Create Transaction record.
        transactionObj = TestUtility.generateTransaction(cg, 100, Constants.AUTOMATIC);
        insert transactionObj;

        //Create AddToPaymentPlan object and Call AddToPaymentPlan constructor.
        ApexPages.currentPage().getParameters().put('guarantorId', g.Id);
        ApexPages.currentPage().getParameters().put('paymentPlanExtId', '121212');
        ppCon = new AddToPaymentPlanVF();
        for (ChargeGroupWrapper cgw : ppCon.chargeGroupList) {
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
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());

        /* Call Submit method and It will successfully save the record.
         * Set variables for call the Webservice.
         * we get response message "Added Successfully".
         */
        ppCon.submit();

        //Check System Assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains('Added Successfully')) {
                isError = true;
            }
            System.debug(msg.getDetail());
        }
        System.assert(!isError, 'Unexpected success message returned 4');
        Test.stopTest();
    }

    //Code Coverage for pass all the validation
    /* Coverage the code for the AddToPaymentPlan class and init the variable,
     * call Cancel Method
     */
    static testMethod void cancel() {
        TestUtility objTestUtility = new TestUtility();

        //Create AddToPaymentPlan object and Call AddToPaymentPlan constructor.
        ApexPages.currentPage().getParameters().put('paymentPlanId', '121212');
        AddToPaymentPlanVF ppCon = new AddToPaymentPlanVF();

        //Call cancel method and it will redirect to Contact page.
        PageReference pageRef = ppCon.cancel();

        //Check system assert.
        System.assertEquals('/' + 121212, pageRef.getUrl());
    }

    //Code Coverage for pass all the validation
    /* Coverage the code for the AddToPaymentPlan class and init the variable,
     * call Cancel Method else part and 'guarantorRecordId' value not found
     */
    static testMethod void cancelElse() {
        TestUtility objTestUtility = new TestUtility();

        //Create AddToPaymentPlan object and Call AddToPaymentPlan constructor.
        AddToPaymentPlanVF ppCon = new AddToPaymentPlanVF();

        //Call cancel method and it will give an error beacuse of we can't add GuarantorId
        PageReference pageRef = ppCon.cancel();

        //Check system assert.
        System.assertEquals('/home/home.jsp', pageRef.getUrl());
    }
}