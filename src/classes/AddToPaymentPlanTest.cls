/*
* @author Sirono
* @version 1.0.1
* @Date: 05-20-2016
* @ 08-31-2016 AddToPaymentPlanTest Class for the Code Covrege of AddToPaymentPlan class.
*/


@isTest
private class AddToPaymentPlanTest {

    //Code Coverage for pass all the validation
    static testMethod void myPassAllValidation() {
        TestUtility objTestUtility = new TestUtility();

        Contact g = TestUtility.generateguarantorContact();
        insert g;

        Contact p = TestUtility.generatePatientContact();
        insert p;

        test__c t = TestUtility.generatePaymentPlan(g.Id);
        t.Active__c = true;
        insert t;

        Apexpages.currentPage().getParameters().put('guarantorId', g.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId', '121212');
        AddToPaymentPlan ppCon = new AddToPaymentPlan();
        ppCon.submit();

        Invoice__c i = TestUtility.generateInvoice(g.Id, p.Id);
        insert i;

        Charge_Group__c cg = TestUtility.generateChargeGroup(g.Id, null, 121114);
        cg.Invoice__c = i.id;
        cg.Payment_Plan__c = t.Id;
        cg.Charge_Group_External_ID__c = true;
        insert cg;

        Transaction__c transactionObj = TestUtility.generateTransaction(cg, 100, 'Automatic');
        insert transactionObj;

        cg = TestUtility.generateChargeGroup(g.Id, null, 121114);
        cg.Invoice__c = i.id;
        cg.Payment_Plan__c = t.Id;
        cg.Charge_Group_ID__c = 124;
        cg.Charge_Group_External_ID__c = true;
        insert cg;


        transactionObj = TestUtility.generateTransaction(cg, 100, 'Automatic');
        insert transactionObj;

        Apexpages.currentPage().getParameters().put('guarantorId', g.Id);
        ppCon = new AddToPaymentPlan();
        for (ChargeGroupWrapper cgw :ppCon.chrageGroupList) {
            cgw.isSelected = true;
        }
        ppCon.doNext();
        ppCon.submit();
        ppCon.cancel();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Please provide all details')) isError = true;
        }
        System.assertEquals(isError, true);
    }

    //Code Coverage for pass all the validation
    static testMethod void submit() {
        TestUtility objTestUtility = new TestUtility();

        Contact g = TestUtility.generateguarantorContact();
        insert g;

        Contact p = TestUtility.generatePatientContact();
        insert p;

        test__c t = TestUtility.generatePaymentPlan(g.Id);
        t.Active__c = true;
        insert t;

        Apexpages.currentPage().getParameters().put('guarantorId', g.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId', '121212');
        AddToPaymentPlan ppCon = new AddToPaymentPlan();
        ppCon.submit();

        Invoice__c i = TestUtility.generateInvoice(g.Id, p.Id);
        insert i;

        Charge_Group__c cg = TestUtility.generateChargeGroup(g.Id, null, 121114);
        cg.Invoice__c = i.id;
        cg.Payment_Plan__c = t.Id;
        cg.Charge_Group_External_ID__c = true;
        insert cg;

        Transaction__c transactionObj = TestUtility.generateTransaction(cg, 100, 'Automatic');
        insert transactionObj;

        cg = TestUtility.generateChargeGroup(g.Id, null, 121114);
        cg.Invoice__c = i.id;
        cg.Payment_Plan__c = t.Id;
        cg.Charge_Group_ID__c = 124;
        cg.Charge_Group_External_ID__c = true;
        insert cg;


        transactionObj = TestUtility.generateTransaction(cg, 100, 'Automatic');
        insert transactionObj;

        Apexpages.currentPage().getParameters().put('guarantorId', g.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId', '121212');
        ppCon = new AddToPaymentPlan();
        for (ChargeGroupWrapper cgw :ppCon.chrageGroupList) {
            cgw.isSelected = true;
        }
        ppCon.doNext();
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        ppCon.submit();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Added Successfully')) isError = true;
        }
        System.assertEquals(isError, true);
        Test.stopTest();

        ppCon.doTesting();

    }

    //Code Coverage for pass all the validation
    static testMethod void submit1() {
        TestUtility objTestUtility = new TestUtility();

        Contact g = TestUtility.generateguarantorContact();
        insert g;

        Contact p = TestUtility.generatePatientContact();
        insert p;

        test__c t = TestUtility.generatePaymentPlan(g.Id);
        t.Active__c = true;
        insert t;

        Apexpages.currentPage().getParameters().put('guarantorId', g.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId', '121212');
        AddToPaymentPlan ppCon = new AddToPaymentPlan();

        Invoice__c i = TestUtility.generateInvoice(g.Id, p.Id);
        insert i;

        Charge_Group__c cg = TestUtility.generateChargeGroup(g.Id, null, 121114);
        cg.Invoice__c = i.id;
        cg.Payment_Plan__c = t.Id;
        cg.Charge_Group_External_ID__c = true;
        insert cg;

        Transaction__c transactionObj = TestUtility.generateTransaction(cg, 100, 'Automatic');
        insert transactionObj;

        cg = TestUtility.generateChargeGroup(g.Id, null, 121114);
        cg.Invoice__c = i.id;
        cg.Payment_Plan__c = t.Id;
        cg.Charge_Group_ID__c = 124;
        cg.Charge_Group_External_ID__c = true;
        insert cg;

        transactionObj = TestUtility.generateTransaction(cg, 100, 'Automatic');
        insert transactionObj;

        Apexpages.currentPage().getParameters().put('guarantorId', g.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId', '121212');
        ppCon = new AddToPaymentPlan();
        for (ChargeGroupWrapper cgw :ppCon.chrageGroupList) {
            cgw.isSelected = true;
        }
        ppCon.doNext();
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        TestUtility.responsebody = 'sadasds';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        ppCon.submit();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Added Successfully')) isError = true;
        }
        System.assertEquals(isError, false);
        Test.stopTest();

        ppCon.doTesting();

    }

    //Code Coverage for pass all the validation
    static testMethod void submit2() {
        TestUtility objTestUtility = new TestUtility();

        Contact g = TestUtility.generateguarantorContact();
        insert g;

        Contact p = TestUtility.generatePatientContact();
        insert p;

        test__c t = TestUtility.generatePaymentPlan(g.Id);
        t.Active__c = true;
        insert t;

        Apexpages.currentPage().getParameters().put('guarantorId', g.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId', '121212');
        AddToPaymentPlan ppCon = new AddToPaymentPlan();
        ppCon.submit();

        Invoice__c i = TestUtility.generateInvoice(g.Id, p.Id);
        insert i;

        Charge_Group__c cg = TestUtility.generateChargeGroup(g.Id, null, 121114);
        cg.Invoice__c = i.id;
        cg.Payment_Plan__c = t.Id;
        cg.Charge_Group_External_ID__c = true;
        insert cg;

        Transaction__c transactionObj = TestUtility.generateTransaction(cg, 100, 'Automatic');
        insert transactionObj;

        cg = TestUtility.generateChargeGroup(g.Id, null, 121114);
        cg.Invoice__c = i.id;
        cg.Payment_Plan__c = t.Id;
        cg.Charge_Group_ID__c = 124;
        cg.Charge_Group_External_ID__c = true;
        insert cg;


        transactionObj = TestUtility.generateTransaction(cg, 100, 'Automatic');
        insert transactionObj;

        Apexpages.currentPage().getParameters().put('guarantorId', g.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanExtId', '121212');
        ppCon = new AddToPaymentPlan();
        for (ChargeGroupWrapper cgw :ppCon.chrageGroupList) {
            cgw.isSelected = true;
        }
        ppCon.doNext();
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        TestUtility.statusCode2 = 201;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        ppCon.submit();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Added Successfully')) isError = true;
        }
        System.assertEquals(isError, false);
        Test.stopTest();

        ppCon.doTesting();

    }

    //Code Coverage for pass all the validation
    static testMethod void cancel() {
        TestUtility objTestUtility = new TestUtility();

        Apexpages.currentPage().getParameters().put('paymentPlanId', '121212');
        AddToPaymentPlan ppCon = new AddToPaymentPlan();
        PageReference pageRef = ppCon.cancel();

        System.assertEquals('/' + 121212, pageRef.getUrl());
    }

    //Code Coverage for pass all the validation
    static testMethod void cancel1() {
        TestUtility objTestUtility = new TestUtility();
        AddToPaymentPlan ppCon = new AddToPaymentPlan();

        PageReference pageRef = ppCon.cancel();
        System.assertEquals('/home/home.jsp', pageRef.getUrl());
    }
}